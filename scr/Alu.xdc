## ---- Entradas A[3:0] en PMOD JD (switches con pulldown interno)
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { A[0] }] ; # JD1
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { A[1] }] ; # JD2
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { A[2] }] ; # JD3
set_property -dict { PACKAGE_PIN R14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { A[3] }] ; # JD4

## ---- Entradas B[3:0] en PMOD JD
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { B[0] }] ; # JD7
set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { B[1] }] ; # JD8
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { B[2] }] ; # JD9
set_property -dict { PACKAGE_PIN V18 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { B[3] }] ; # JD10

## ---- Entradas OP[2:0] en PMOD JE
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { OP[0] }] ; # JE1
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { OP[1] }] ; # JE2
set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 PULLDOWN true } [get_ports { OP[2] }] ; # JE3

## ---- Salidas Y[3:0] y banderas en PMOD JC (LEDs con resistor a GND)
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports { Y_led[0] }] ; # JC1
set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33 } [get_ports { Y_led[1] }] ; # JC2
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { Y_led[2] }] ; # JC3
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { Y_led[3] }] ; # JC4

## Mapeo solicitado: OF -> JC7, ZERO -> JC8 (los dos inferiores de la derecha)
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports OF_led]    ; # JC7
set_property -dict { PACKAGE_PIN Y14 IOSTANDARD LVCMOS33 } [get_ports ZERO_led]  ; # JC8