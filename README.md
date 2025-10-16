[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/sEFmt2_p)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-2e0aaae1b6195c2367325f4f02e2d04e9abb55f0b24a779b69b11b9e10269abc.svg)](https://classroom.github.com/online_ide?assignment_repo_id=21107936&assignment_repo_type=AssignmentRepo)

# Lab02 – Unidad Aritmético-Lógica (ALU) 4-bits

## Integrantes
- Tomás Esteban Cuartas Feliciano
- Salomón Velasco Rueda

## Informe

### Índice
- [Lab02 – Unidad Aritmético-Lógica (ALU) 4-bits](#lab02--unidad-aritmético-lógica-alu-4-bits)
  - [Integrantes](#integrantes)
  - [Informe](#informe)
    - [Índice](#índice)
  - [Diseño implementado](#diseño-implementado)
    - [Descripción](#descripción)
    - [Puertos y codificación de operaciones](#puertos-y-codificación-de-operaciones)
    - [Banderas (`overflow`, `zero`)](#banderas-overflow-zero)
    - [Diagrama (RTL)](#diagrama-rtl)
  - [Simulaciones](#simulaciones)
  - [Implementación en FPGA](#implementación-en-fpga)
    - [Top-level y asignación de pines](#top-level-y-asignación-de-pines)
    - [Mapa de pines y señales](#mapa-de-pines-y-señales)
    - [Flujo en Vivado](#flujo-en-vivado)
    - [Cableado rápido en protoboard](#cableado-rápido-en-protoboard)
  - [Conclusiones](#conclusiones)
  - [Referencias](#referencias)

---

## Diseño implementado

### Descripción
Se implementó una **ALU de 4 bits** con cinco operaciones seleccionables por `op[2:0]`:

- **Suma** (`ADD`)
- **Resta** (`SUB`)
- **Multiplicación** 
- **NOR** (operación lógica asignada)
- **Corrimiento lógico a la izquierda en 1** sobre `a` (`SHL1(a)`)

La ALU entrega además dos banderas:
- `overflow`: indica *carry out* (suma), *préstamo* (resta), desbordamiento por multiplicación (bits altos ≠ 0) o bit expulsado en el corrimiento.
- `zero`: vale 1 si `y == 0`.

> Diseño puramente **combinacional** (sin reloj). Las entradas cambian → la salida y banderas reflejan el resultado conforme a la operación.

### Puertos y codificación de operaciones

**Módulo:** `alu4` (ver `./scr/Alu4.v`)

| Señal | Dir. | Ancho | Descripción |
|------:|:----:|:-----:|-------------|
| `a`   | in   | 4     | Operando A |
| `b`   | in   | 4     | Operando B |
| `op`  | in   | 3     | Selección de operación |
| `y`   | out  | 4     | Resultado (o nibble bajo para `MUL`) |
| `overflow` | out | 1 | Banderas de desbordamiento  |
| `zero` | out | 1 | `1` si `y == 4'h0` |

**Codificación (`op`):**

| `op` (bin) | Operación | Definición de `y` |
|:----------:|-----------|-------------------|
| `000` | **ADD** | `y = a + b` (nibble bajo) |
| `001` | **SUB** | `y = a - b` (en complemento a 2) |
| `010` | **MUL** | `y = (a * b)[3:0]` |
| `011` | **NOR** | `y = ~(a \| b)` |
| `100` | **SHL1(a)** | `y = (a << 1)[3:0]` |
| `101–111` | — | Reservado (produce `y=0`) |

> Nota de diseño: se trabajó en **aritmética sin signo**..

### Banderas (`overflow`, `zero`)

- **ADD (`000`)**: `overflow = carry_out` del sumador de 5 bits.  
- **SUB (`001`)**: `overflow = ¬carry_out` (equivale a **préstamo** en resta sin signo).  
- **MUL (`010`)**: `overflow = OR( (a*b)[7:4] )` (hubo bits altos distintos de cero).  
- **NOR (`011`)**: `overflow = 0`.  
- **SHL1 (`100`)**: `overflow = bit_expulsado = (a<<1)[4]` (el MSB original).  
- **ZERO (todas)**: `zero = (y == 4'h0)`.

### Diagrama (RTL)

El **diagrama RTL** se generó con **Yosys** + **netlistsvg** a partir de `Alu4.v`.

![RTL de la ALU 4-bits](./scr/alu4.svg)

**Comandos usados (Windows + Scoop):**
```powershell
# Dependencias
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
iwr -useb get.scoop.sh | iex
scoop install yosys graphviz nodejs-lts

# Generación netlist y diagrama
mkdir scr
yosys -p "read_verilog -sv Alu4.v; prep -top alu4; write_json scr/alu4.json"
npx -y netlistsvg scr/alu4.json -o scr/alu4.svg
```

---

## Simulaciones

**Herramientas:** Icarus Verilog (iverilog/vvp) + GTKWave.  
**Archivos:** `Alu4.v` (DUT), `tb_alu4.v` (testbench).  
**Salida:** `./scr/alu4_tb.vcd`.

**Comandos ejecutados:**
```powershell
# Compilar y simular (Windows)
"C:\iverilog\bin\iverilog.exe" -g2012 -o simv .\tb_alu4.v .\Alu4.v
& "C:\iverilog\bin\vvp.exe" .\simv

# Mover evidencia a ./scr
mkdir scr 2>$null
Move-Item .\alu4_tb.vcd .\scr\ -Force

# Abrir ondas
& "C:\iverilog\gtkwave\bin\gtkwave.exe" .\scr\alu4_tb.vcd
```


**Casos principales (del testbench):**

| `op` | Descripción | `a` | `b` | `y` esperado | `overflow` | `zero` |
|:---:|-------------|:---:|:---:|:------------:|:----------:|:------:|
| 000 | ADD | 3 | 4 | 7 | 0 | 0 |
| 000 | ADD (wrap) | 15 | 1 | 0 | 1 | 1 |
| 001 | SUB | 7 | 2 | 5 | 0 | 0 |
| 001 | SUB (préstamo) | 0 | 1 | 15 | 1 | 0 |
| 010 | MUL | 3 | 3 | 9 | 0 | 0 |
| 010 | MUL (desborde alto) | 15 | 15 | 1 | 1 | 0 |
| 011 | NOR | 0 | 0 | 15 | 0 | 0 |
| 100 | SHL1 | 7 | X | 14 | 0 | 0 |
| 100 | SHL1 (expulsa MSB) | 8 | X | 0 | 1 | 1 |

_Evidencia:_ `./scr/alu4_tb.vcd` (ondas).  
> En `MUL` se reporta `overflow=1` si el nibble alto del producto (`[7:4]`) es distinto de cero.

---

## Implementación en FPGA

### Top-level y asignación de pines
Se creó un envoltorio `top_pmod_alu4.v` para cablear directamente a **PMODs**:

```verilog
module top_pmod_alu4(
  input  wire [3:0] A,        // Entradas A[3:0] (switches)
  input  wire [3:0] B,        // Entradas B[3:0] (switches)
  input  wire [2:0] OP,       // Selección de operación (switches)
  output wire [3:0] Y_led,    // LEDs resultado
  output wire       ZERO_led, // LED zero
  output wire       OF_led    // LED overflow
);
  wire [3:0] Y; wire Z, OF;
  alu4 u_alu(.a(A), .b(B), .op(OP), .y(Y), .overflow(OF), .zero(Z));
  assign Y_led = Y; assign ZERO_led = Z; assign OF_led = OF;
endmodule
```

**Restricciones (extracto `./scr/Alu.xdc`)** – ejemplo de mapeo a PMODs con *PULLDOWN* en entradas y LEDs en salidas.

### Mapa de pines y señales

| Señal (top) | Función | Pin FPGA | Conector |
|---|---|---:|---|
| `A[0]..A[3]` | Operando A (switches) | T14, T15, P14, R14 | JD1..JD4 |
| `B[0]..B[3]` | Operando B (switches) | U14, U15, V17, V18 | JD7..JD10 |
| `OP[0]..OP[2]` | Operación | V12, W16, J15 | JE1..JE3 |
| `Y_led[0]..[3]` | Resultado (LSB→MSB) | V15, W15, T11, T10 | JC1..JC4 |
| `OF_led` | Overflow | W14 | JC7 |
| `ZERO_led` | Zero | Y14 | JC8 |


### Flujo en Vivado
1. Crear proyecto → agregar `Alu4.v` como **Design Source** y `top_pmod_alu4.v` como **Top**.  
2. Agregar `Alu.xdc` en **Constraints**.  
3. **Run Synthesis** → revisar `report_io`.  
4. **Run Implementation**.  
5. **Generate Bitstream**.  
6. **Program Device** (Hardware Manager).

### Cableado rápido en protoboard
- Switches a 3V3 (con *PULLDOWN* externo).  
- PMOD JD: `A[3:0]` (JD1..4) y `B[3:0]` (JD7..10).  
- PMOD JE: `OP[2:0]` (JE1..JE3).  
- PMOD JC: `Y_led[3:0]`, `OF_led` (JC7), `ZERO_led` (JC8).  
- GND común a la barra negativa de protoboard.

---

## Conclusiones
- La **ALU 4-bits** cumple las operaciones solicitadas (suma, resta, multiplicación, NOR y corrimiento).  
- La definición de **`overflow`** se ajustó al caso **sin signo** por operación (carry/borrow, desbordes de multiplicación y bit expulsado en corrimiento), lo cual simplifica la verificación en hardware con LEDs.  
- Las **simulaciones** validan los casos de borde (wrap en `ADD`, préstamo en `SUB`, desborde en `MUL`, expulsión de MSB en `SHL1`) y coinciden con el VCD.  
- La separación **ALU (combinacional)** + **top de placa** facilitó la síntesis/implementación y el mapeo a PMODs.

---

## Referencias
- **Yosys** + **netlistsvg** para RTL.  
- **Icarus Verilog** (iverilog/vvp) + **GTKWave** para simulación.  
- Notas de clase sobre ALUs (banderas, operaciones y multiplexación de resultados).

---

### Anexos y evidencias (carpeta `./scr/`)
- `Alu4.v` (fuente de la ALU)  
- `tb_alu4.v` (testbench)  
- `alu4.svg` (diagrama RTL)  
- `alu4.json` (netlist Yosys)  
- `alu4_tb.vcd` (ondas de simulación)  
- `top_pmod_alu4.v` (top de placa)  
- `Alu.xdc` (restricciones)

### Video demostrativo
👉 _([Video demostrativo compuerta NOR](https://drive.google.com/file/d/1szVL1N6i17yJwdutKgA7Yp8RVx7QkrTI/view?usp=sharing))_

👉 _([Video Demostrativo Suma, multiplicación, resta...](https://drive.google.com/file/d/1KCkB0F74mGmHZ7mYBU5U8f-fUVsJ_pKq/view?usp=sharing))_

