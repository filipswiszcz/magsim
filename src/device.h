#ifndef MS_DEVICE_H
#define MS_DEVICE_H

#ifdef __APPLE__
    #define GL_SILENCE_DEPRECATION
    #define GLFW_INCLUDE_GLCOREARB
    #include <GLFW/glfw3.h>
#else
    #include <GL/glew.h>
    #include <GLFW/glfw3.h>
#endif

#include "common.h"

typedef struct {
    GLFWwindow *window;
    u32 width, height;
    char *name;
} platform_t;

enum class device_status : u8 {
    SUCCESS = 0
};

class device final {
public:
    [[nodiscard]] device_status initialize(void) noexcept;
    void terminate(void) noexcept;
private:
    platform_t platform;

    void _ems_tick(void);
};

#endif // !MS_DEVICE_H