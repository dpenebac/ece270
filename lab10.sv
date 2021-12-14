Post-Lab Submission 10
Due: Fri, 05 Nov 2021 13:20:00 (approximately 39 days ago)
[Score: 0 / 0 points possible]
Upload the Verilog code you, personally, wrote for Lab 10.


Academic Honesty Statement [0 ... -100 points]
By typing my name, below, I hereby certify that the work on this experiment is my own and that I have not copied the work of any other student (past or present) while completing it. I understand that if I fail to honor this agreement, I will receive a score of ZERO for the lab, a one letter drop in my final course grade, and be subject to possible disciplinary action.

Dorien Penebacker


Your Verilog code [0 ... -100 points]
Upload the Verilog code you wrote for step 4 of this lab, including your top and count8du modules.

`default_nettype none
typedef enum logic { RDY, ENT } simonstate_t; //RDY == 0 ENT == 1

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

  /*
  logic hz1;
  clock_1hz cldiv (.hz100(hz100), .reset(reset), .hz1(hz1));
  
  logic [7:0] ctr;
  count8du_init c8di1 (.CLK(hz1), .RST(reset), .DIR(1'b0), .E(ctr != 0), .INIT(8'd5), .Q(ctr));
  
  ssdec ssd1 (.in(ctr[3:0]), .enable(ctr != 0), .out(ss0[6:0]));
  */
 
  /*
  logic [7:0] ctr1, ctr2, ctr3, ctr4;
  count8du_init flashnum1 (.CLK(hz100), .RST(reset), .DIR(1'b0), .E(ctr1 != 0), .INIT(8'h99), .Q(ctr1));
  count8du_init flashnum2 (.CLK(hz100), .RST(reset), .DIR(1'b0), .E(ctr2 != 0), .INIT(8'hAB), .Q(ctr2));
  count8du_init flashnum3 (.CLK(hz100), .RST(reset), .DIR(1'b0), .E(ctr3 != 0), .INIT(8'hCD), .Q(ctr3));
  count8du_init flashnum4 (.CLK(hz100), .RST(reset), .DIR(1'b0), .E(ctr4 != 0), .INIT(8'hEF), .Q(ctr4));
  display_32_bit show_entry (.in({ctr1, ctr2, ctr3, ctr4}), .out({ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0}));
  */
  
  simon game (.clk(hz100), .reset(reset), .in(pb[19:0]), .left(left), .right(right), .ss({ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0}), .win(green), .lose(red));
   
endmodule

module display_32_bit (input logic [31:0] in, output logic [63:0] out);

//0-7 8-15 16-23 24-   32-  40-  48-  56- 
    
  ssdec ssd1 (.in(in[3:0]), .enable(1'b1), .out(out[6:0]));
  ssdec ssd2 (.in(in[7:4]), .enable(|in[31:4]), .out(out[14:8]));
  ssdec ssd3 (.in(in[11:8]), .enable(|in[31:8]), .out(out[22:16]));
  ssdec ssd4 (.in(in[15:12]), .enable(|in[31:12]), .out(out[30:24]));
  ssdec ssd5 (.in(in[19:16]), .enable(|in[31:16]), .out(out[38:32]));
  ssdec ssd6 (.in(in[23:20]), .enable(|in[31:20]), .out(out[46:40]));
  ssdec ssd7 (.in(in[27:24]), .enable(|in[31:24]), .out(out[54:48]));
  ssdec ssd8 (.in(in[31:28]), .enable(|in[31:28]), .out(out[62:56]));
  
  assign out[7] = 0;
  assign out[15] = 0;
  assign out[23] = 0;
  assign out[31] = 0;
  assign out[39] = 0;
  assign out[47] = 0;
  assign out[55] = 0;
  assign out[63] = 0;

endmodule

module  count8du_init(input logic CLK, input logic RST, output logic [7:0] Q, input logic DIR, input logic E, input logic [7:0] INIT);
  logic [7:0] next_Q;
  
  always_ff @(posedge CLK, posedge RST) begin
    if (RST == 1'b1)
      Q <= INIT;
    else if (E == 1'b1)
        Q <= next_Q;
  end
  
  always_comb begin
    if (DIR == 1'b1)
    begin
        if (Q == INIT)
            next_Q = 8'd0;
        else
            begin
            next_Q[0] = ~Q[0];
            next_Q[1] = Q[1] ^ Q[0];
            next_Q[2] = Q[2] ^ (&Q[1:0]);
            next_Q[3] = Q[3] ^ (&Q[2:0]);
            next_Q[4] = Q[4] ^ (&Q[3:0]);
            next_Q[5] = Q[5] ^ (&Q[4:0]);
            next_Q[6] = Q[6] ^ (&Q[5:0]);
            next_Q[7] = Q[7] ^ (&Q[6:0]);
            end
    end
    else
        if (Q == 0)
            next_Q = INIT;
        else
            begin
            next_Q[0] = ~Q[0];
            next_Q[1] = Q[1] ^ ~Q[0];
            next_Q[2] = Q[2] ^ &(~Q[1:0]);
            next_Q[3] = Q[3] ^ &(~Q[2:0]);
            next_Q[4] = Q[4] ^ &(~Q[3:0]);
            next_Q[5] = Q[5] ^ &(~Q[4:0]);
            next_Q[6] = Q[6] ^ &(~Q[5:0]);
            next_Q[7] = Q[7] ^ &(~Q[6:0]);
            end
  end
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

module clock_1hz(input logic hz100, input logic reset, output logic hz1);

  always_ff @(posedge hz100, posedge reset)
    if (reset == 1'b1)
      hz1 <= 0;
    else if (on == 8'd49)
      hz1 <= ~hz1;

  always_ff @(posedge hz100, posedge reset)
    if (reset == 1'b1)
        on <= 8'd0;
    else if (on == 8'd49)
        on <= 8'd0;
    else
        on <= next_on;
  
  logic [7:0] on;
  logic [7:0] next_on;
  
  always_comb begin
      begin
      next_on[0] = ~on[0];
      next_on[1] = on[1] ^ on[0];
      next_on[2] = on[2] ^ (&on[1:0]);
      next_on[3] = on[3] ^ (&on[2:0]);
      next_on[4] = on[4] ^ (&on[3:0]);
      next_on[5] = on[5] ^ (&on[4:0]);
      next_on[6] = on[6] ^ (&on[5:0]);
      next_on[7] = on[7] ^ (&on[6:0]);
      end
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

module numentry (input logic clk, input logic rst, input logic en, input logic [4:0] in, output logic [31:0] out, input logic clr);
  //clr synch reset
  //rst asynch reset
  
  logic [31:0] next_out;
  
  always_ff @(posedge clk, posedge rst)
    if (rst == 1)
      out <= 32'd0;
    else if (clr == 1)
      out <= 32'd0;
    else if (en == 1)
      out <= next_out;
    else
      out <= out;
  
  always_comb 
  begin
    if ((~in[4] & ~in[3]) || (~in[4] & in[3] & ~in[2] & ~in[1] & ~in[0]) || (~in[4] & in[3] & ~in[2] & ~in[1] & in[0]))
      if (out == 32'd0)
        next_out = {28'd0,in[3:0]};
      else
        next_out = (out << 4) | {28'd0,in[3:0]};
    else
      next_out = out;
  end
  
endmodule

module simonctl (input logic clk, input logic rst, input logic lvlmax, input logic win, input logic lose, output logic state);
  //typedef enum logic { RDY, ENT } simonstate_t; //RDY == 0 ENT == 1
  logic next_state;
  
  always_ff @(posedge clk, posedge rst)
  if (rst == 1)
    state <= RDY;
  else
    state <= next_state;
  
  always_comb
  begin
    if ((lose == 1) | (~lvlmax & win))
      next_state = RDY;
    else if (~lvlmax)
      next_state = ENT;
    else
      next_state = state;
  end
  
endmodule

