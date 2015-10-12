#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/gpio.h> // Required for the GPIO functions
#include <linux/interrupt.h> // Required for the IRQ code
/**
 * 	The switch GPIO on the iMX5 (APF51) is GPIO1_3
 * 	to convert to linux gpio number, we apply :
 * 		((bank_number-1)*32) + pin_number
 * 	So for the switch, the gpio is : (0x32)+3 = 3
 */
#define	 GPIO(B,P) (((B-1)*32) + P)
 // The FPGA_BUTTON at GPIO4_11
#define	IMX_BT GPIO(4,11)