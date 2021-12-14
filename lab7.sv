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
  logic [3:0] QN;
  
  hc74_reset hc74R3(.c(pb[0]), .d(~QN[2]), .q(right[3]), .rn(pb[16]), .qn(QN[3]));
  hc74_reset hc74R2(.c(pb[0]), .d(~QN[1]), .q(right[2]), .rn(pb[16]), .qn(QN[2]));
  hc74_reset hc74R1(.c(pb[0]), .d(~QN[0]), .q(right[1]), .rn(pb[16]), .qn(QN[1]));
  hc74_set   hc74S1(.c(pb[0]), .d(~QN[3]), .q(right[0]), .sn(pb[16]), .qn(QN[0]));
  
endmodule

// Add more modules down here...

// This is a single D flip-flop with an active-low asynchronous reset (clear).
// It has no asynchronous set because the simulator does not allow it.
// Other than the lack of a set, it is half of a 74HC74 chip.

module hc74_reset(input logic d, c, rn,
                  output logic q, qn);
  assign qn = ~q;
  always_ff @(posedge c, negedge rn)
    if (rn == 1'b0)
      q <= 1'b0;
    else
      q <= d;
endmodule


// This is a single D flip-flop with an active-low asynchronous set (preset).
// It has no asynchronous reset because the simulator does not allow it.
// Other than the lack of a reset, it is half of a 74HC74 chip.

module hc74_set(input logic d, c, sn,
                  output logic q, qn);
  assign qn = ~q;
  always_ff @(posedge c, negedge sn)
    if (sn == 1'b0)
      q <= 1'b1;
    else
      q <= d;
endmodule

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
  hc74_reset hc74R1(.c(pb[0]), .d(pb[1]), .q(right[0]), .rn(pb[16]));
  hc74_set hc74S1(.c(pb[0]), .d(pb[1]), .q(right[1]), .sn(pb[16]));
  
endmodule

// Add more modules down here...

// This is a single D flip-flop with an active-low asynchronous reset (clear).
// It has no asynchronous set because the simulator does not allow it.
// Other than the lack of a set, it is half of a 74HC74 chip.

module hc74_reset(input logic d, c, rn,
                  output logic q, qn);
  assign qn = ~q;
  always_ff @(posedge c, negedge rn)
    if (rn == 1'b0)
      q <= 1'b0;
    else
      q <= d;
endmodule


// This is a single D flip-flop with an active-low asynchronous set (preset).
// It has no asynchronous reset because the simulator does not allow it.
// Other than the lack of a reset, it is half of a 74HC74 chip.

module hc74_set(input logic d, c, sn,
                  output logic q, qn);
  assign qn = ~q;
  always_ff @(posedge c, negedge sn)
    if (sn == 1'b0)
      q <= 1'b1;
    else
      q <= d;
endmodule