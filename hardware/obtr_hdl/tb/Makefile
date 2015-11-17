all:
	ghdl -a ../../wb_irq/imx51_wb16_wrapper.vhd
	ghdl -a ../interface_mngr.vhd
	ghdl -a ../rw_counter.vhd
	ghdl -a ../../wb_irq/irq_mngr.vhd
	ghdl -a ../../wb_irq/debounce.vhd
	ghdl -a ../../ov7670_interface/dual_port_dual_clock.vhd
	ghdl -a ../buffer_ctrl.vhd
	ghdl -a ../../wb_irq/rstgen_syscon.vhd
	ghdl -a ../top_level.vhd
	ghdl -a test.vhdl
	ghdl -e wb_test
	ghdl -r wb_test --vcd=test.vcd

mult:
	ghdl -a ../mult9x9.vhd
	ghdl -a mult_test.vhd
	ghdl -e mult_test
	ghdl -r mult_test --vcd=mult_test.vcd

fifo:
	ghdl -a ../../ov7670_interface/dual_port_dual_clock.vhd
	ghdl -a ../FIFO_dual_clock.vhd
	ghdl -a fifo_test.vhd
	ghdl -e fifo_test
	ghdl -r fifo_test --vcd=fifo_test.vcd

hsv:
	ghdl -a ../mult9x9.vhd
	ghdl -a ../hsvfilter.vhd
	ghdl -a hsvfilter_test.vhd
	ghdl -e hsvfilter_test
	ghdl -r hsvfilter_test --vcd=hsvfilter_test.vcd
	
com:
	ghdl -a ../center_of_mass.vhd
	ghdl -a center_of_mass_test.vhd
	ghdl -e center_of_mass_test
	ghdl -r center_of_mass_test --vcd=center_of_mass_test.vcd
	
fsync:
	ghdl -a ../flag_sync.vhd
	ghdl -a flag_sync_test.vhd
	ghdl -e flag_sync_test
	ghdl -r flag_sync_test --vcd=flag_sync_test.vcd