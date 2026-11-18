#include <iostream>

#include <imgui/imgui.h>
#include <imgui/backends/imgui_impl_glfw.h>
#include <imgui/backends/imgui_impl_opengl3.h>

#include "device.h"

device *g_device = nullptr;

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

void device::tick(void) noexcept {
    glfwPollEvents();

    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();

    ImGui::Begin("Data");
    ImGui::Text("#0 null");
    ImGui::End();

    ImGui::Render();

    int display_width, display_height;
    glfwGetFramebufferSize(this->platform.window, &display_width, &display_height);
    glViewport(0, 0, display_width, display_height);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
    glfwSwapBuffers(this->platform.window);
}

void device::terminate(void) noexcept {
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
    glfwDestroyWindow(this->platform.window);
    glfwTerminate();
}

void _ems_tick(void) {
    if (g_device) {
        g_device->tick();
    }
}

i32 main(void) {
    device device;
    g_device = &device;
    device.initialize();

#ifdef __EMSCRIPTEN__
    emscripten_set_main_loop(_ems_tick, 0, 1);
#else
    while (!glfwWindowShouldClose(device.get_window())) {
        _ems_tick();
    }
#endif

    device.terminate();
    return 0;
}