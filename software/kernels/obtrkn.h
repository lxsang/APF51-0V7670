
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/gpio.h> // Required for the GPIO functions
#include <linux/interrupt.h> // Required for the IRQ code
// header for uio support
#include <linux/slab.h>
#include <linux/device.h>
#include <linux/uio_driver.h>

#include <linux/ioport.h> // read write
#include <asm/io.h>

/*
 *  Define the APF51 base
 */ 
#define APF51_FPGA_BASE 0xB8000000
#define APF51_FPGA_MAP_SIZE 0x10000


//This will be reused in use-space
#define IRQ_MNGR 0
#define IRQ_MASK 0
#define IRQ_ACK 2
#define IRQ_PEND 2
#define IRQ_ID 4
#define LED 0x8


/**
 * 	The switch GPIO on the iMX5 (APF51) is GPIO1_3
 * 	to convert to linux gpio number, we apply :
 * 		((bank_number-1)*32) + pin_number
 * 	So for the switch, the gpio is : (0x32)+3 = 3
 */
#define	 GPIO(B,P) (((B-1)*32) + P)
 // The FPGA_BUTTON at GPIO4_11
#define	IMX_IRQ GPIO(4,11)
