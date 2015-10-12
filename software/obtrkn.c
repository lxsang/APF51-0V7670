#include "obtrkn.h"

MODULE_LICENSE("GPL");     
MODULE_AUTHOR("LE Xuan Sang");
MODULE_DESCRIPTION("OBTR : Object detecting kernel module with APF51 & 0V7670."); 
MODULE_VERSION("0.1");

// interrup number
static unsigned int irq_number; 
// button pressed times
static unsigned int no_presses = 0;

/**
 * The iRQ handler
 */
static irq_handler_t obtrkn_bt_handler(unsigned int irq, void* dev_id, struct ptr_regs* regs)
{
	printk(KERN_INFO "OBTR: Interrupt (button state is%d)\n",gpio_get_value(IMX_BT));
	no_presses++;
	return (irq_handler_t) IRQ_HANDLED;
}

/**
 * Init the kernel module
 * This function will set up the switch, register an IRQ
 * to the kernel
 */
static int __init obtrkn_init(void)
{
	int result = 0;
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

	printk(KERN_INFO "OBTR: the interrupt request result is %d\n", result);
	return result;
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
	printk(KERN_INFO "OBTR: Good bye");
	gpio_unexport(IMX_BT);
	gpio_free(IMX_BT);
}



module_init(obtrkn_init);
module_exit(obtrkn_exit);
