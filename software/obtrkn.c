#include "obtrkn.h"

MODULE_LICENSE("GPL");     
MODULE_AUTHOR("LE Xuan Sang");
MODULE_DESCRIPTION("OBTR : Object detecting kernel module with APF51 & 0V7670."); 
MODULE_VERSION("0.1");


// interrup number
static unsigned int irq_number; 
// button pressed times
static unsigned int no_presses = 0;

static void * ptr_fpga = NULL;


static void print_irq_status(void)
{
    u16 data;
    // now try to read the interrupt manager paramerter
    data = (u16)ioread16(ptr_fpga+IRQ_MNGR+IRQ_ID);
    printk(KERN_INFO "OBTR: The interrupt manager id is %d \n",data);
    data = (u16)ioread16(ptr_fpga+IRQ_MNGR+IRQ_MASK);
    //data  = *(unsigned short*)(ptr_fpga+(8));
    printk(KERN_INFO "OBTR: The interrupt mask is %x \n",data);
    data = (u16)ioread16(ptr_fpga+IRQ_MNGR+IRQ_PEND);
    printk(KERN_INFO "OBTR: The pending interrupts is %d \n",data);
 }


/**
 * The iRQ handler
 */
static irq_handler_t obtrkn_bt_handler(unsigned int irq, void* dev_id, struct ptr_regs* regs)
{
	printk(KERN_INFO "OBTR: Interrupt (button state is%d)\n",gpio_get_value(IMX_BT));
	no_presses++;
    print_irq_status();
    // reset the ack
    iowrite16(1, ptr_fpga+IRQ_MNGR+IRQ_ACK);
    print_irq_status();
	return (irq_handler_t) IRQ_HANDLED;
}

static void free_all(void)
{
	free_irq(irq_number,NULL);
	gpio_unexport(IMX_BT);
	gpio_free(IMX_BT);
    release_mem_region(APF51_FPGA_BASE,APF51_FPGA_MAP_SIZE);
}


/**
 * Init the kernel module
 * This function will set up the switch, register an IRQ
 * to the kernel
 */
 static int __init obtrkn_init(void)
{
	int result = 0;
    u16 data;
    printk(KERN_INFO "OBTR : Init the module with the switch %d\n", IMX_BT);
	// set up the gpio for the switch
	gpio_request(IMX_BT,"sysfs");
	gpio_direction_input(IMX_BT);
	gpio_set_debounce(IMX_BT,200);
	gpio_export(IMX_BT,false);

    
	printk(KERN_INFO "OBTR: The imx button state is %d \n",gpio_get_value(IMX_BT));

	// register the interrupt to the kernel
	// First, map the GPIO number to the interrupt number
	irq_number = gpio_to_irq(IMX_BT);
	printk(KERN_INFO "OBTR: The interrupt number is %d\n", irq_number);
	//request an interrupt line
	result = request_irq(irq_number,
						(irq_handler_t) obtrkn_bt_handler,
                         IRQF_TRIGGER_RISING,
						"button_interrupt",
						NULL);

    if ( result < 0) {
        printk(KERN_INFO "OBTR: Cannot request the interrupt, error:  %d\n", result);
        goto error;
    }
    printk(KERN_INFO "OBTR : Interrupt request sucessful\n");

    // memory allocation an mapping
    ptr_fpga = request_mem_region(APF51_FPGA_BASE,APF51_FPGA_MAP_SIZE,
                                  "apf51_fpga_map");
    if (!ptr_fpga) {
        printk(KERN_INFO "OBTR : cannot allocate memory region for mapping");
        goto error;
    }
    // remap to phisical
    ptr_fpga = ioremap(APF51_FPGA_BASE,APF51_FPGA_MAP_SIZE);
    if (!ptr_fpga) {
        printk(KERN_INFO "OBTR: cannot remap the region to the physical address");
        goto error;
    }

    // reset the mask to enable the irq at button
    data = 1;
    iowrite16(data,ptr_fpga+IRQ_MNGR+IRQ_MASK);
    // reset the pending by set the ack flag
    iowrite16(data, ptr_fpga+IRQ_MNGR+IRQ_ACK);

    // now try to read the interrupt manager paramerter
    print_irq_status();
    printk(KERN_INFO "OBTR inserted \n");
;
    return 0;

error:
    printk(KERN_ERR "OBTR not inserted\n");
    free_all();
    return -1;
}

/**
 * Exit the module
 * Unexport the GPIO and free the IRQ
 */

static void __exit obtrkn_exit(void)
{
	printk(KERN_INFO "OBTR: The current button state is %d\n", gpio_get_value(IMX_BT));
	printk(KERN_INFO "OBTR: The button was pressed %d times\n",no_presses);
	free_irq(irq_number,NULL);
    release_mem_region(APF51_FPGA_BASE,APF51_FPGA_MAP_SIZE);
	printk(KERN_INFO "OBTR: Good bye");
	gpio_unexport(IMX_BT);
	gpio_free(IMX_BT);
}



module_init(obtrkn_init);
module_exit(obtrkn_exit);
