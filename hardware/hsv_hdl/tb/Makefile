all: 
	ghdl -a ../../obtr_hdl/mult9x9.vhd
	ghdl -a ../../obtr_hdl/hsvfilter.vhd
	ghdl -a ../filter.vhd
	ghdl -a ../interface_mngr.vhd
	ghdl -a ../irq_mngr.vhd
	ghdl -a ../top_level.vhd
	ghdl -a test.vhd
	ghdl -e wb_test
	ghdl -r wb_test --vcd=wb_test.vcd
