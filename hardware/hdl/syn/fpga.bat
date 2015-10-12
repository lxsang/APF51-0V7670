setMode -bs
setCable -port xsvf -file ../c/top_level.xsvf
addDevice -p 1 -file top_level.bit
addDevice -p 2 -file /opt/Xilinx/14.7/ISE_DS/ISE/xcf/data/xcf04s.bsd
program -p 1
quit