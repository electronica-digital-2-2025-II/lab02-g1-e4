`timescale 1ns/1ps
module alu4(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire [2:0] op,   // 000 add, 001 sub, 010 mul, 011 NOR, 100 shl1(a)
  output reg  [3:0] y,
  output reg        overflow,
  output wire       zero
);
  wire [4:0] add5  = {1'b0,a} + {1'b0,b};
  wire [4:0] sub5  = {1'b0,a} + {1'b0,~b} + 5'b00001; // a - b = a + (~b + 1)
  wire [7:0] mul8  = a * b;
  wire [4:0] shl5a = {1'b0,a} << 1;

  always @* begin
    y = 4'h0;
    overflow = 1'b0;
    case (op)
      3'b000: begin // ADD
        y = add5[3:0];
        overflow = add5[4]; // carry
      end
      3'b001: begin // SUB (a - b)
        y = sub5[3:0];
        overflow = ~sub5[4]; // borrow
      end
      3'b010: begin // MUL
        y = mul8[3:0];
        overflow = |mul8[7:4];
      end
      3'b011: begin // NOR
        y = ~(a | b);
        overflow = 1'b0;
      end
      3'b100: begin // SHL1(a)
        y = shl5a[3:0];
        overflow = shl5a[4]; // bit expulsado
      end
      default: begin
        y = 4'h0;
        overflow = 1'b0;
      end
    endcase
  end

  assign zero = (y == 4'h0);

endmodule