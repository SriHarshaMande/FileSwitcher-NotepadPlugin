@echo off
echo Setting up Visual Studio build environment...

REM Try to find Visual Studio 2022 first
set "VS2022_PATH=C:\Program Files\Microsoft Visual Studio\2022"

REM Look for different VS2022 editions
if exist "%VS2022_PATH%\Enterprise\VC\Auxiliary\Build\vcvars64.bat" (
    echo Found Visual Studio 2022 Enterprise
    call "%VS2022_PATH%\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
    goto :build
)
if exist "%VS2022_PATH%\Professional\VC\Auxiliary\Build\vcvars64.bat" (
    echo Found Visual Studio 2022 Professional
    call "%VS2022_PATH%\Professional\VC\Auxiliary\Build\vcvars64.bat"
    goto :build
)
if exist "%VS2022_PATH%\Community\VC\Auxiliary\Build\vcvars64.bat" (
    echo Found Visual Studio 2022 Community
    call "%VS2022_PATH%\Community\VC\Auxiliary\Build\vcvars64.bat"
    goto :build
)
if exist "%VS2022_PATH%\BuildTools\VC\Auxiliary\Build\vcvars64.bat" (
    echo Found Visual Studio 2022 BuildTools
    call "%VS2022_PATH%\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
    goto :build
)

REM If VS2022 not found, try VS2019
set "VS2019_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019"

REM Look for different VS2019 editions
if exist "%VS2019_PATH%\Enterprise\VC\Auxiliary\Build\vcvars64.bat" (
    echo Found Visual Studio 2019 Enterprise
    call "%VS2019_PATH%\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
    goto :build
)
if exist "%VS2019_PATH%\Professional\VC\Auxiliary\Build\vcvars64.bat" (
    echo Found Visual Studio 2019 Professional
    call "%VS2019_PATH%\Professional\VC\Auxiliary\Build\vcvars64.bat"
    goto :build
)
if exist "%VS2019_PATH%\Community\VC\Auxiliary\Build\vcvars64.bat" (
    echo Found Visual Studio 2019 Community
    call "%VS2019_PATH%\Community\VC\Auxiliary\Build\vcvars64.bat"
    goto :build
)
if exist "%VS2019_PATH%\BuildTools\VC\Auxiliary\Build\vcvars64.bat" (
    echo Found Visual Studio 2019 BuildTools
    call "%VS2019_PATH%\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
    goto :build
)

echo Visual Studio 2022 or 2019 build tools not found!
echo Please install Visual Studio 2022 or 2019 with C++ development tools.
pause
exit /b 1

:build
echo Building FileSwitcher plugin...
msbuild FileSwitcher.sln /p:Configuration=Release /p:Platform=x64 /m

if %ERRORLEVEL% == 0 (
    echo.
    echo Build successful!
    echo Plugin DLL location: x64\Release\FileSwitcher.dll
    echo.
    echo To install the plugin:
    echo 1. Create folder: %%APPDATA%%\Notepad++\plugins\FileSwitcher\
    echo 2. Copy FileSwitcher.dll to the created folder
    echo 3. Restart Notepad++
) else (
    echo.
    echo Build failed with error code %ERRORLEVEL%
)

pause
