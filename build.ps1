# PowerShell Build Script for FileSwitcher Plugin

Write-Host "FileSwitcher Plugin Build Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green

# Define Visual Studio paths for both 2022 and 2019
$VS2022_PATH = "C:\Program Files\Microsoft Visual Studio\2022"
$VS2019_PATH = "C:\Program Files (x86)\Microsoft Visual Studio\2019"
$vcvarsPath = $null

# Look for different Visual Studio editions
$editions = @("Enterprise", "Professional", "Community", "BuildTools")

# First try Visual Studio 2022
foreach ($edition in $editions) {
    $testPath = Join-Path $VS2022_PATH "$edition\VC\Auxiliary\Build\vcvars64.bat"
    if (Test-Path $testPath) {
        $vcvarsPath = $testPath
        Write-Host "Found Visual Studio 2022 $edition" -ForegroundColor Yellow
        break
    }
}

# If 2022 not found, try 2019
if (-not $vcvarsPath) {
    foreach ($edition in $editions) {
        $testPath = Join-Path $VS2019_PATH "$edition\VC\Auxiliary\Build\vcvars64.bat"
        if (Test-Path $testPath) {
            $vcvarsPath = $testPath
            Write-Host "Found Visual Studio 2019 $edition" -ForegroundColor Yellow
            break
        }
    }
}

if (-not $vcvarsPath) {
    Write-Host "Visual Studio 2022 or 2019 build tools not found!" -ForegroundColor Red
    Write-Host "Please install Visual Studio 2022 or 2019 with C++ development tools." -ForegroundColor Red
    exit 1
}

Write-Host "Building FileSwitcher plugin..." -ForegroundColor Green

# Use cmd to execute both vcvars and msbuild in the same shell
$buildCommand = "`"$vcvarsPath`" && msbuild FileSwitcher.sln /p:Configuration=Release /p:Platform=x64 /v:minimal"

$process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $buildCommand -Wait -PassThru -NoNewWindow

if ($process.ExitCode -eq 0) {
    Write-Host ""
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host "==================" -ForegroundColor Green
    
    $dllPath = "x64\Release\FileSwitcher.dll"
    if (Test-Path $dllPath) {
        $fileInfo = Get-Item $dllPath
        Write-Host "Plugin DLL: $dllPath" -ForegroundColor Yellow
        Write-Host "Size: $($fileInfo.Length) bytes" -ForegroundColor Yellow
        Write-Host "Created: $($fileInfo.CreationTime)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Installation Instructions:" -ForegroundColor Cyan
    Write-Host "1. Run: powershell.exe -ExecutionPolicy Bypass -File install.ps1" -ForegroundColor White
    Write-Host "   OR manually:" -ForegroundColor White
    Write-Host "2. Create folder: %APPDATA%\Notepad++\plugins\FileSwitcher\" -ForegroundColor White
    Write-Host "3. Copy FileSwitcher.dll to the created folder" -ForegroundColor White
    Write-Host "4. Restart Notepad++" -ForegroundColor White
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host "- The plugin will appear in Plugins > File Switcher menu" -ForegroundColor White
    Write-Host "- Set up a hotkey in Settings > Shortcut Mapper > Plugin commands" -ForegroundColor White
    Write-Host "- Recommended hotkey: Ctrl+Shift+O" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "Build failed with error code $($process.ExitCode)" -ForegroundColor Red
    Write-Host "Check the output above for details." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
