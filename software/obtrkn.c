#include <linux/init.h>    
#include <linux/module.h>  
#include <linux/kernel.h>  
 
MODULE_LICENSE("MIT");     
MODULE_AUTHOR("LE Xuan Sang");
MODULE_DESCRIPTION("A simple Linux driver for for accessing \ 
filter result from FPGA using the image provided by the 0V7670 capter."); 
MODULE_VERSION("0.1");
 
static char *name = "world";
module_param(name, charp, S_IRUGO); 
MODULE_PARM_DESC(name, "The name to display in /var/log/kern.log");

static int __init obtrkn_init(void){
  printk(KERN_INFO "Object Tracking : Hello %s \
from the Object Tracking LKM!\n", name);
  return 0;
}
 
static void __exit obtrkn_exit(void){
  printk(KERN_INFO "Object tracking: Goodbye %s from the Object tracking LKM!\n", name);
}
 

module_init(obtrkn_init);
module_exit(obtrkn_exit);
