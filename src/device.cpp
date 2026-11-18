#include <iostream>

#include "device.h"

device_status device::initialize(void) noexcept {
    return device_status::SUCCESS;
}

void device::terminate(void) noexcept {}

void _ems_tick(void) {}

i32 main(void) {
    std::cout << "v" << std::endl;
    return 0;
}