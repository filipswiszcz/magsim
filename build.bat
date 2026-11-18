@echo off
setlocal

set "mode=%1"
set "target=%2"

if "%mode%"=="dev" goto dev
if "%mode%"=="release" goto release

echo BUILD OPTIONS: dev, release
exit /b 1

:dev
set "flags=-g -O0 -Wall -Wextra -std=c++17"
goto configure

:release
set "flags=-O3 -Wall -Wextra -std=c++17"
goto configure

:configure
if "%target%"=="web" goto web
set "compiler=g++"
set "libs=-lglfw3 -lopengl32"
set "output=build\device.exe"
goto compile

:web
set "compiler=em++"
set "libs=-s USE_GLFW=3 -s MIN_WEBGL_VERSION=2 -s MAX_WEBGL_VERSION=2"
set "output=build\index.html"
goto compile

:compile
if exist build rmdir /s /q build
if not exist bin mkdir bin
mkdir build

%compiler% %flags% ^
    -I./lib ^
    -I./lib/imgui ^
    -I./lib/imgui/backends ^
    src\*.cpp ^
    lib\imgui\*.cpp ^
    lib\imgui\backends\imgui_impl_glfw.cpp ^
    lib\imgui\backends\imgui_impl_opengl3.cpp ^
    %libs% ^
    -o %output%

if %errorlevel% neq 0 goto error
if "%target%"=="web" goto web_done

copy /y build\device.exe bin\ >nul

if "%mode%"=="release" goto release_resources

if exist res mklink /J bin\res res >nul
goto done

:release_resources
if exist res (
    if exist bin\res rmdir /s /q bin\res
    xcopy res bin\res /E /I /Y >nul
)
goto done

:web_done
echo WEB BUILD COMPLETE
goto eof

:error
echo BUILD ERROR
exit /b 1

:done
echo BUILD COMPLETE

:eof
endlocal
