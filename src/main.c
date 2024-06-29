/**
 * @file main.c
 * @brief LVGL Demo ILI9341.
 * 
 * @copyright Copyright (c) 2023
 * 
 */

/**
 * @file {File Name}
 * @brief If required.
 * 
 * Detailed info if required.
 * @copyright Copyright (c) 2023
 * 
 */

// NOTE: Remember to add your source to your project file!

/* INCLUDES *******************************************************************/

#include <stdio.h>
#include "pico/stdio.h"
#include "perf_counter.h"

/* DEFINES ********************************************************************/

/* TYPEDEF/STRUCTURES *********************************************************/

/* STATIC PROTOTYPES **********************************************************/

static void system_init(void);

/* STATIC VARIABLES  **********************************************************/

/* MACROS *********************************************************************/

/* FUNCTIONS ******************************************************************/

void SysTick_Handler(void)
{

}



int main() {
    system_init(); 
    printf("hello world!");
    while(1) {
    }

    return 0;
}

/* STATIC FUNCTIONS ***********************************************************/

/** Sets up cortex SysTick. Required for using perf_counter to port LVGL. */
static void system_init(void)
{
    // SysTick.
    extern void SystemCoreClockUpdate();
    SystemCoreClockUpdate();
    init_cycle_counter(false);

#ifdef PICO_DEFAULT_LED_PIN
    gpio_set_dir(PICO_DEFAULT_LED_PIN, GPIO_OUT); // LED pin pico board.
    // redefine if alternative board with alternative pin (or undefine if none)
#endif
#ifdef DEBUG
    stdio_init_all();       // Debug on UART or USB. Not relevant to SWD debug.
#endif
}