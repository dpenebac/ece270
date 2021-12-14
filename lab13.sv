`default_nettype none
// Empty top module

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

  // Your code goes here...
  support13 sup (.clk (hz100), .reset (reset), .in (pb), .out7 (ss7), .out6 (ss6), .out5 (ss5), .out4 (ss4), .out3 (ss3), .out2 (ss2), .out1 (ss1), .out0 (ss0));
  
endmodule

// Add more modules down here...
module alu (
  input logic clk, rst,         // clk and rst for handling flag updation
  input logic [31:0] in1, in2,  // the operands the ALU will act on,
  input logic fue,              // the Flag Update Enable, which, if high, 
                                // allows fout to be updated on rising edge of clk
  input logic [4:0] op,         // the current operation,
  output logic [31:0] out,      // the result of the current operation,
  output logic [3:0] fout       // the flags of the current operation.
);

  logic Ncur, Zcur, Ccur, Vcur;
  
  assign Ncur = fout[3];
  assign Zcur = fout[2];
  assign Ccur = fout[1];
  assign Vcur = fout[0];
  
  logic N,Z,C,V;
  
  assign N = out[31];
  assign Z = ~(|out);
  
  always_comb
  begin
  if (op == ALU_ADD || op == ALU_ADC)
    begin 
      //C
      if (
          (in1[31] == 1 && in2[31] == 1) ||
          (in1[31] == 1 && out[31] == 0) ||
          (in2[31] == 1 && out[31] == 0)
          )
        C = 1;
      else
        C = 0;
      
      //V
      if (
          (in1[31] == 1 && in2[31] == 1) &&
          (out[31] == 0 || in1[31] == 0 && in2[31] == 0)
          )
        V = 1;
      else
        V = 0;
    end
  else if (op == ALU_SUB || op == ALU_SBC)
    begin
      //C
      if (
          (in1[31] == 1 && in2[31] == 0) ||
          (in1[31] == 1 && out[31] == 0) ||
          (in2[31] == 0 && out[31] == 0)
          )
        C = 1;
      else
        C = 0;
      
      //V
      if (
          (in1[31] == 1 && ~in2[31] == 1) &&
          (out[31] == 0 || in1[31] == 0 && ~in2[31] == 0)
          )
        V = 1;
      else
        V = 0;
    end
  else
    begin
    C = 0;
    V = 0;
    end
  end
  
  always_ff @(posedge clk, posedge rst)
    if (rst == 1)
      fout <= 0;
    else if (fue == 1)
      fout <= nfout;
  
  logic [3:0] nfout;
  
  always_comb
  begin
    case(op)
      ALU_CMP: begin out = in1 - in2; nfout = {N,Z,C,V}; end
      
      ALU_NEG: begin out = 0 - in2; nfout = {N,Z,C,V}; end 
      
      ALU_ADD: begin out = in1 + in2;  nfout = {N,Z,C,V}; end
      
      ALU_ADC: begin out = in1 + in2 + {31'd0,Ccur}; nfout = {N,Z,C,V}; end 
      
      ALU_SUB: begin out = in1 - in2; nfout = {N,Z,C,V}; end 
      
      ALU_SBC: begin out = in1 - in2 + {31'd0,Ccur}; nfout = {N,Z,C,V}; end 
      
      ALU_NOT: begin out = ~in2; nfout = {N,Z,Ccur,Vcur}; end 
      
      ALU_OR: begin out = in1 | in2; nfout = {N,Z,Ccur,Vcur}; end
      
      ALU_AND: begin out = in1 & in2; nfout = {N,Z,Ccur,Vcur}; end
      
      ALU_BIC: begin out = in1 & ~in2; nfout = {N,Z,Ccur,Vcur}; end
      
      ALU_XOR: begin out = in1 ^ in2; nfout = {N,Z,Ccur,Vcur}; end
      
      ALU_CPY: begin out = in2; nfout = {N,Z,Ccur,Vcur}; end
      
      default: begin out = 0; nfout = {Ncur, Zcur, Ccur, Vcur}; end
      
      endcase
  end



endmodule

module scankey (input logic clk, input logic rst, input logic [19:0] in, output logic strobe, output logic [4:0] out);
  //strobe output delayed by a two flip flop synchronizer
  
  assign out[0] = in[1] | in[3] | in[5] | in[7] | in[9] | in[11] | in[13] | in[15] | in[17] | in[19];
  assign out[1] = |in[3:2] | |in[7:6] | |in[11:10] | |in[15:14] | |in[19:18];
  assign out[2] = |in[7:4] | |in[15:12];
  assign out[3] = |in[15:8];
  assign out[4] = |in[19:16];
  
  logic delay;
  always_ff @(posedge clk, posedge rst)
  if (rst == 1)
    delay <= 0;
  else
    delay <= |in[19:0];

  always_ff @(posedge clk, posedge rst)
  if (rst == 1)
    strobe <= 0;
  else
    strobe <= delay;
  
endmodule


module ssdec(input logic [3:0] in, input logic enable, output logic [6:0] out);
  assign out = {in, enable} == 5'b00001 ? 7'b0111111: //0
               {in, enable} == 5'b00011 ? 7'b0000110: //1
               {in, enable} == 5'b00101 ? 7'b1011011: //2
               {in, enable} == 5'b00111 ? 7'b1001111: //3
               {in, enable} == 5'b01001 ? 7'b1100110: //4
               {in, enable} == 5'b01011 ? 7'b1101101: //5
               {in, enable} == 5'b01101 ? 7'b1111101: //6
               {in, enable} == 5'b01111 ? 7'b0000111: //7
               {in, enable} == 5'b10001 ? 7'b1111111: //8
               {in, enable} == 5'b10011 ? 7'b1100111: //9
               {in, enable} == 5'b10101 ? 7'b1110111: //A
               {in, enable} == 5'b10111 ? 7'b1111100: //B
               {in, enable} == 5'b11001 ? 7'b0111001: //C
               {in, enable} == 5'b11011 ? 7'b1011110: //D
               {in, enable} == 5'b11101 ? 7'b1111001: //E
               {in, enable} == 5'b11111 ? 7'b1110001: //F
               7'b0;
endmodule