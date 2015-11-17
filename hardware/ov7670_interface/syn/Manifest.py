target = "xilinx" 
action = "synthesis" 

syn_device = "xc6slx9" 
syn_grade = "-2" 
syn_package = "csg225" 
syn_top = "top_level" 
syn_project = "obtr_prj.xise" 

files = "top_level.ucf" 

modules = {
  "local" : "../" 
}
