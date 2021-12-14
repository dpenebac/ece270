Post-Lab Submission 11
Due: Mon, 15 Nov 2021 16:30:00 (approximately 28 days ago)
[Score: 70 / 70 points possible]
Upload the Verilog code you, personally, wrote for Lab 11.


Academic Honesty Statement [0 ... -100 points]
By typing my name, below, I hereby certify that the work on this experiment is my own and that I have not copied the work of any other student (past or present) while completing it. I understand that if I fail to honor this agreement, I will receive a score of ZERO for the lab, a one letter drop in my final course grade, and be subject to possible disciplinary action.

Dorien Penebacker


Step (1) [30 points]
Upload the Verilog code you wrote for step 1 of this lab.


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
  logic [4:0] keycode;
  logic strobe;
  scankey sk1 (.clk(hz100), .rst(reset), .in(pb[19:0]), .strobe(strobe), .out(keycode));
  logic [31:0] data;
  digits d1 (.in(keycode), .out(data), .clk(strobe), .reset(reset));
  ssdec s0(.in(data[3:0]),   .out(ss0[6:0]), .enable(1'b1));
  ssdec s1(.in(data[7:4]),   .out(ss1[6:0]), .enable(|data[31:4]));
  ssdec s2(.in(data[11:8]),  .out(ss2[6:0]), .enable(|data[31:8]));
  ssdec s3(.in(data[15:12]), .out(ss3[6:0]), .enable(|data[31:12]));
  ssdec s4(.in(data[19:16]), .out(ss4[6:0]), .enable(|data[31:16]));
  ssdec s5(.in(data[23:20]), .out(ss5[6:0]), .enable(|data[31:20]));
  ssdec s6(.in(data[27:24]), .out(ss6[6:0]), .enable(|data[31:24]));
  ssdec s7(.in(data[31:28]), .out(ss7[6:0]), .enable(|data[31:28]));
  
endmodule

module digits(input logic [4:0] in, input logic clk, reset, output logic [31:0] out);

  logic [31:0] current;
  assign out = current;
  logic [31:0] save;
  logic [3:0] op;
  logic [31:0] result;
  
  always_ff @(posedge clk, posedge reset)
    if (reset)
      begin
      current <= 0;
      save <= 0;
      op <= 0;
      end
    else
      case (in)
        5'b0????: current <= {current[27:0], in[3:0]};
        5'b10001: current <= {4'b0, current[31:4]};
        5'b10010: 
                  begin
                  op <= 0;
                  save <= current;
                  end
        5'b10011: 
                  begin
                  op <= 1;
                  save <= current;
                  end
        5'b10000: current <= result;
      endcase
  math m(.op(op), .a(save), .b(current), .r(result));
endmodule


Step (2) [20 points]
Upload the Verilog code you wrote for step 2 of this lab.


module digits(input logic [4:0] in, input logic clk, reset, output logic [31:0] out);

  logic [31:0] current;
  logic [31:0] save;
  logic [3:0] op;
  logic [31:0] result;
  
  always_ff @(posedge clk, posedge reset)
    if (reset)
      begin
      current <= 0;
      save <= 0;
      op <= 0;
      show <= 0;
      end
    else
      case (in)
        5'b0????: 
                  begin
                  if (show == 1)
                    begin
                    current <= {28'b0, in[3:0]};
                    show <= 0;
                    end
                  else
                    begin
                    current <= {current[27:0], in[3:0]};
                    end
                  end
        
        5'b10001: current <= {4'b0, current[31:4]};
        
        5'b10010: 
                  begin
                  op <= 0;
                  if (show == 0)
                    save <= current;
                  current <= 0;
                  show <= 1;
                  end

        5'b10011: 
                  begin
                  op <= 1;
                  if (show == 0)
                    save <= current;
                  current <= 0;
                  show <= 1;
                  end

        5'b10000: 
                  begin
                  save <= result;
                  show <= 1;
                  end
      endcase
  math m(.op(op), .a(save), .b(current), .r(result));
  
  logic show;
  
  assign out = (show) ? save : current;


endmodule


Step (3) [20 points]
Upload the Verilog code you wrote for step 3 of this lab.


module digits(input logic [4:0] in, input logic clk, reset, output logic [31:0] out);

  logic [31:0] current;
  logic [31:0] save;
  logic [3:0] op;
  logic [31:0] result;
  
  always_ff @(posedge clk, posedge reset)
    if (reset)
      begin
      current <= 0;
      save <= 0;
      op <= 0;
      show <= 0;
      full <= 0;
      end
    else
      case (in)
        5'b0????: 
                  begin
                  if (show == 1)
                    begin
                      current <= {28'b0, in[3:0]};
                      show <= 0;
                      if (current != 0)
                        full <= 8'b00000001;
                    end
                  else
                    begin
                      if (full != 8'b11111111)
                        begin
                          current <= {current[27:0], in[3:0]};
                          if (full[0] == 1 || in != 5'b00000)
                            full <= {full[6:0],1'b1};
                        end
                    end
                  
                  
                    
                    //last thing to do
                  end
        
        5'b10001: 
                  begin
                  if (full != 0)
                  begin
                    full <= {1'b0, full[7:1]};
                    current <= {4'b0, current[31:4]};
                  end
                  end
        
        5'b10010: 
                  begin
                  op <= 0;
                  if (show == 0)
                    save <= current;
                  current <= 0;
                  show <= 1;
                  full <= 0;
                  end

        5'b10011: 
                  begin
                  op <= 1;
                  if (show == 0)
                    save <= current;
                  current <= 0;
                  show <= 1;
                  full <= 0;
                  end

        5'b10000: 
                  begin
                  save <= result;
                  show <= 1;
                  full <= 0;
                  end
      endcase
  math m(.op(op), .a(save), .b(current), .r(result));
  
  logic show;
  
  assign out = (show) ? save : current;

  logic [7:0] full;

endmodule

module digits(input logic [4:0] in, input logic clk, reset, output logic [31:0] out);

  logic [31:0] current;
  logic [31:0] save;
  logic [3:0] op;
  logic [31:0] result;
  
  always_ff @(posedge clk, posedge reset)
    if (reset)
      begin
      current <= 0;
      save <= 0;
      op <= 0;
      show <= 0;
      end
    else
      case (in)
        5'b0????: 
                  begin
                  if (show == 1)
                    begin
                    current <= {28'b0, in[3:0]};
                    show <= 0;
                    end
                  else
                    begin
                    current <= {current[27:0], in[3:0]};
                    end
                  end
        
        5'b10001: current <= {4'b0, current[31:4]};
        
        5'b10010: 
                  begin
                  op <= 0;
                  if (show == 0)
                    save <= current;
                  current <= 0;
                  show <= 1;
                  end

        5'b10011: 
                  begin
                  op <= 1;
                  if (show == 0)
                    save <= current;
                  current <= 0;
                  show <= 1;
                  end

        5'b10000: 
                  begin
                  save <= result;
                  show <= 1;
                  end
      endcase
  math m(.op(op), .a(save), .b(current), .r(result));
  
  logic show;
  
  assign out = (show) ? save : current;


endmodule

module digits(input logic [4:0] in, input logic clk, reset, output logic [31:0] out);

  logic [31:0] current;
  logic [31:0] save;
  logic [3:0] op;
  logic [31:0] result;
  
  always_ff @(posedge clk, posedge reset)
    if (reset)
      begin
      current <= 0;
      save <= 0;
      op <= 0;
      show <= 0;
      full <= 0;
      end
    else
      case (in)
        5'b0????: 
                  begin
                  if (show == 1)
                    begin
                      current <= {28'b0, in[3:0]};
                      show <= 0;
                      if (current != 0)
                        full <= 8'b00000001;
                    end
                  else
                    begin
                      if (full != 8'b11111111)
                        begin
                          current <= {current[27:0], in[3:0]};
                          if (full[0] == 1 || in != 5'b00000)
                            full <= {full[6:0],1'b1};
                        end
                    end
                  
                  
                    
                    //last thing to do
                  end
        
        5'b10001: 
                  begin
                  if (full != 0)
                  begin
                    full <= {1'b0, full[7:1]};
                    current <= {4'b0, current[31:4]};
                  end
                  end
        
        5'b10010: 
                  begin
                  op <= 0;
                  if (show == 0)
                    save <= current;
                  current <= 0;
                  show <= 1;
                  full <= 0;
                  end

        5'b10011: 
                  begin
                  op <= 1;
                  if (show == 0)
                    save <= current;
                  current <= 0;
                  show <= 1;
                  full <= 0;
                  end

        5'b10000: 
                  begin
                  save <= result;
                  show <= 1;
                  full <= 0;
                  end
      endcase
  math m(.op(op), .a(save), .b(current), .r(result));
  
  logic show;
  
  assign out = (show) ? save : current;

  logic [7:0] full;

endmodule
