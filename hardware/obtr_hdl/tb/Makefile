all:
	ghdl -a ../../wb_irq/imx51_wb16_wrapper.vhd
	ghdl -a ../interface_mngr.vhd
	ghdl -a ../rw_counter.vhd
	ghdl -a ../../wb_irq/irq_mngr.vhd
	ghdl -a ../../wb_irq/debounce.vhd
	ghdl -a ../dual_port_dual_clock.vhd
	ghdl -a ../buffer_ctrl.vhd
	ghdl -a ../../wb_irq/rstgen_syscon.vhd
	ghdl -a ../top_level.vhd
	ghdl -a test.vhdl
	ghdl -e wb_test
	ghdl -r wb_test --vcd=test.vcd
