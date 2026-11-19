@echo off
setlocal

set "vcpkg=D:\vcpkg\installed\x64-windows"
set "mode=%1"
set "target=%2"

if "%mode%"=="dev" goto dev
if "%mode%"=="release" goto release

echo BUILD OPTIONS: dev, release
exit /b 1

:dev
set "flags=/Zi /Od /MDd /W4"
goto config

:release
set "flags=/O2 /MD /W4"
goto config

:config
if "%target%"=="web" goto web
set "libs=-lglfw3 -lopengl32"
@REM  set "output=build\device.exe"
goto compile

:web
set "libs=-s USE_GLFW=3 -s MIN_WEBGL_VERSION=2 -s MAX_WEBGL_VERSION=2"
@REM  set "output=build\index.html"
goto compile

:compile
if exist build rmdir /s /q build
if not exist bin mkdir bin
mkdir build

if "%target%"=="web" (
    em++ %flags% ^
        -I./lib ^
        -I./lib/imgui ^
        -I./lib/imgui/backends ^
        src\*.cpp ^
        lib\imgui\*.cpp ^
        lib\imgui\backends\imgui_impl_glfw.cpp ^
        lib\imgui\backends\imgui_impl_opengl3.cpp ^
        %libs% ^
        -o build\index.html
) else (
    cl.exe /nologo /std:c++17 %flags% ^
        /I"%vcpkg%\include" ^
        /I.\lib ^
        /I.\lib\imgui ^
        /I.\lib\imgui\backends ^
        src\*.cpp ^
        lib\imgui\*.cpp ^
        lib\imgui\backends\imgui_impl_glfw.cpp ^
        lib\imgui\backends\imgui_impl_opengl3.cpp ^
        /Fo"build\\" ^
        /Fd"build\vc.pdb" ^
        /Febuild\device.exe ^
        /link ^
        /LIBPATH:"%vcpkg%\lib" ^
        glfw3dll.lib glew32.lib opengl32.lib gdi32.lib user32.lib shell32.lib
)

if %errorlevel% neq 0 goto error
if "%target%"=="web" goto done

copy /y "%vcpkg%\bin\glew32.dll" bin\ >nul
copy /y "%vcpkg%\bin\glfw3.dll" bin\ >nul

copy /y build\device.exe bin\ >nul

if "%mode%"=="release" goto copy

if exist res mklink /J bin\res res >nul
goto done

:copy
if exist res (
    if exist bin\res rmdir /s /q bin\res
    xcopy res bin\res /E /I /Y >nul
)
goto done

:error
echo BUILD ERROR
exit /b 1

:done
echo BUILD COMPLETE

:eof
endlocal
