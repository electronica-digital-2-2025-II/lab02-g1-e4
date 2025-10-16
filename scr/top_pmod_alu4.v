`timescale 1ns/1ps
module top_pmod_alu4(
  input  wire [3:0] A,        // JD1..JD4  (switches -> 3V3, pulldown en XDC)
  input  wire [3:0] B,        // JD7..JD10 (switches -> 3V3, pulldown en XDC)
  input  wire [2:0] OP,       // JE1..JE3  (switches -> 3V3, pulldown en XDC)
  output wire [3:0] Y_led,    // JC1..JC4  (LEDs externos con resistor a GND)
  output wire       ZERO_led, // JC8       (LED externo)
  output wire       OF_led    // JC7       (LED externo)
);
  wire [3:0] Y;
  wire Z, OF;

  alu4 u_alu(.a(A), .b(B), .op(OP), .y(Y), .overflow(OF), .zero(Z));

  assign Y_led    = Y;
  assign ZERO_led = Z;
  assign OF_led   = OF;
endmodule