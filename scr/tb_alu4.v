`timescale 1ns/1ps
// Testbench para alu4.v — genera VCD para GTKWave
module tb_alu4;
  // Entradas
  reg  [3:0] a;
  reg  [3:0] b;
  reg  [2:0] op;
  // Salidas
  wire [3:0] y;
  wire       overflow;
  wire       zero;

  // DUT
  alu4 dut (
    .a(a),
    .b(b),
    .op(op),
    .y(y),
    .overflow(overflow),
    .zero(zero)
  );

  // Dump para GTKWave
  initial begin
    $dumpfile("alu4_tb.vcd");
    $dumpvars(0, tb_alu4);
  end

  // Estímulos
  task drive(input [3:0] aa, input [3:0] bb, input [2:0] oo);
    begin
      a  = aa;
      b  = bb;
      op = oo;
      #5; // tiempo de propagación
      $display("%0t ns | op=%b a=%h b=%h -> y=%h of=%b z=%b",
               $time, op, a, b, y, overflow, zero);
    end
  endtask

  initial begin
    a = 0; b = 0; op = 0;
    #1;

    // 000: ADD
    drive(4'h3, 4'h4, 3'b000); // 3 + 4 = 7
    drive(4'hF, 4'h1, 3'b000); // 15 + 1 = 0 con overflow

    // 001: SUB
    drive(4'h7, 4'h2, 3'b001); // 7 - 2 = 5
    drive(4'h0, 4'h1, 3'b001); // 0 - 1 = 15 con "préstamo" en overflow 

    // 010: MUL
    drive(4'h3, 4'h3, 3'b010); // 9
    drive(4'hF, 4'hF, 3'b010); // 

    // 011: NOR
    drive(4'h0, 4'h0, 3'b011); // NOR = 1111
    drive(4'hA, 4'h5, 3'b011); // NOR diversas combinaciones

    // 100: SHL1(a)
    drive(4'h7, 4'hX, 3'b100); // 0111<<1 = 1110
    drive(4'h8, 4'hX, 3'b100); // 1000<<1 = 0000 con overflow=1

    // Valores aleatorios
    repeat (10) begin
      drive($random, $random, $urandom_range(0,4)); // sólo ops definidas
    end

    #10;
    $finish;
  end
endmodule
