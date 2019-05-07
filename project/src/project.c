

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "ultrasonic_sensor.h"
#include"xil_io.h"
#include "xparameters.h"

int main()
{
    init_platform();
    int ones;
    int tens;
    int ResultOfSensor;
    int servo_status;

    print("Hello World\n\r");

        while(1){
        	ones = ULTRASONIC_SENSOR_mReadReg(0x43C00000, 0);
        	tens = ULTRASONIC_SENSOR_mReadReg(0x43C00000, 4);

        	ResultOfSensor = tens*10 + ones ;

        	xil_printf("The values that comes from sensor:");
        	xil_printf("Distance: %d\n\r", ResultOfSensor);

        	sleep(1);
        	ULTRASONIC_SENSOR_mWriteReg(0x43C00000, 12, 0); //(BaseAddress, RegOffset, Data)
        	sleep(1);
        	ULTRASONIC_SENSOR_mWriteReg(0x43C00000, 12, 40); // 40 --> ?? degree
        	sleep(1);
        	ULTRASONIC_SENSOR_mWriteReg(0x43C00000, 12, 80); //
        	sleep(1);
        	ULTRASONIC_SENSOR_mWriteReg(0x43C00000, 12, 120);
        	sleep(1);

        	sleep(0.1);

        	servo_status = ULTRASONIC_SENSOR_mReadReg(0x43C00000, 8);
        	xil_printf("Servo trig. status %d\n\r", servo_status);
        }

    cleanup_platform();
    return 0;
}
