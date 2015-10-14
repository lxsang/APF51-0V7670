target = "xilinx" 
action = "synthesis" 

syn_device = "xc6slx9" 
syn_grade = "-2" 
syn_package = "csg225" 
syn_top = "top_level" 
syn_project = "wb_com_ex.xise" 

files = "top_level.ucf" 

modules = {
  "local" : "../" 
}
