all: system

system:
	ghdl -a ../../wb_irq/imx51_wb16_wrapper.vhd
	ghdl -a ../interface_mngr.vhd
	ghdl -a ../rw_counter.vhd
	ghdl -a ..//irq_mngr.vhd
	ghdl -a ../../wb_irq/debounce.vhd
	ghdl -a ../frame.vhd
	ghdl -a ../sobel.vhd
	ghdl -a ../filter.vhd
	ghdl -a ../buffer_ctrl.vhd
	ghdl -a ../../wb_irq/rstgen_syscon.vhd
	ghdl -a ../top_level.vhd
	ghdl -a imx_in.vhd
	ghdl -a imx_in_4x4.vhd
	ghdl -a sobel_test.vhd
	ghdl -e sobel_test
	ghdl -r sobel_test --vcd=sobel_test.vcd

sqrt:
	ghdl -a ../sqrt.vhd
	ghdl -a test_sqrt.vhd
	ghdl -e sqrt_test
	ghdl -r sqrt_test --vcd=sqrt_test.vcd

mult:
	ghdl -a ../mult8x8.vhd
	ghdl -a mult_test.vhd
	ghdl -e mult_test
	ghdl -r mult_test --vcd=mult_test.vcd

sobel:
#	ghdl -a matrix.vhd
#	ghdl -a dst_frame.vhd
#	ghdl -a ../sobel.vhd
#	ghdl -a ../filter.vhd
	ghdl -a imx_in.vhd
	ghdl -a sobel_test.vhd
	ghdl -e sobel_test
	ghdl -r sobel_test --vcd=sobel_test.vcd
