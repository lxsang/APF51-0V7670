all:
	ghdl -a ../imx51_wb16_wrapper.vhd
	ghdl -a ../interface_mngr.vhd
	ghdl -a ../default.vhd
	ghdl -a ../led.vhd
	ghdl -a ../rstgen_syscon.vhd
	ghdl -a ../top_level.vhd
	ghdl -a test.vhdl
	ghdl -e wb_test
	ghdl -r wb_test --vcd=test.vcd
