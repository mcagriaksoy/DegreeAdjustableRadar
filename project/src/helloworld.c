#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "sensor.h"
#include"xil_io.h"
#include "xparameters.h"
#include "xgpio.h"

XGpio push_buttons;

int main()
{
	print("Started...\n\r");
	int ones;
	int tens;
	int ResultOfSensor;

	int chk;
	int status;

	status = XGpio_Initialize(&push_buttons, XPAR_BUTTONS_DEVICE_ID);
	if (status != XST_SUCCESS)
	        	return XST_FAILURE;

	XGpio_SetDataDirection(&push_buttons, 1, 0xffffffff);
	init_platform();

    print("Started...\n\r");
    chk = 0;
    int r;

    while(1){
    	chk = XGpio_DiscreteRead(&push_buttons, 1);
    	xil_printf("Push Buttons Status %x\r\n", chk);

    	for(int i=10; i<230; i=i+20){
    		ones = SENSOR_mReadReg(0x43C00000, 0);
    		tens = SENSOR_mReadReg(0x43C00000, 4);
    		ResultOfSensor = tens*10 + ones;
    		xil_printf("Distance: %d\n\r", ResultOfSensor);

    		SENSOR_mWriteReg(0x43C00000, 8, i);
    	    r = SENSOR_mReadReg(0x43C00000, 12);
    		xil_printf("res: %d\n\r", r);
    		sleep(2);
    	}

        sleep(1);
}

    cleanup_platform();
    return 0;
}
