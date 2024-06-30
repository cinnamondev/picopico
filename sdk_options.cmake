#Pico SDK Configuration

pico_enable_stdio_usb(${TARGET} 0)
pico_enable_stdio_uart(${TARGET} 1) 

target_link_libraries(${TARGET} pico_stdlib)

#pico_add_extra_outputs(${TARGET})