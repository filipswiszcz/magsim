#include <iostream>

#include <imgui/imgui.h>
#include <imgui/backends/imgui_impl_glfw.h>
#include <imgui/backends/imgui_impl_opengl3.h>

#include "device.h"

device *DEVICE = nullptr;

device_status device::initialize(void) noexcept {
    if (!MS_ASSERT(glfwInit())) {
        // do smth to stop this madness
        return device_status::GLFW_INIT_ERROR;
    }

#ifdef __EMSCRIPTEN__
    const char *glsl_version = "#version 300 es";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
#elif __APPLE__
    const char *glsl_version = "#version 150";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#else
    const char *glsl_version = "#version 130";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
#endif

    this->platform.width = 800;
    this->platform.height = 600;
    this->platform.name = (char*) "MS (build 0.0.1)";

    this->platform.window = glfwCreateWindow(this->platform.width, this->platform.height, this->platform.name, NULL, NULL);
    if (!this->platform.window) {
        return device_status::GLFW_WINDOW_ERROR;
    }

    glfwMakeContextCurrent(this->platform.window);
    glfwSwapInterval(1);

#ifndef __EMSCRIPTEN__
#ifndef __APPLE__
    glewExperimental = 1;
    if (glewInit() != GLEW_OK) {
        // do smth here as well
        return device_status::GLEW_INIT_ERROR;
    }
#endif
#endif

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGui::StyleColorsDark();
    ImGui_ImplGlfw_InitForOpenGL(this->platform.window, true);
    ImGui_ImplOpenGL3_Init(glsl_version);

    return device_status::SUCCESS;
}

void device::terminate(void) noexcept {}

void _ems_tick(void) {}

i32 main(void) {
    std::cout << "v" << std::endl;
    return 0;
}