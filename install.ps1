# PowerShell Installation Script for FileSwitcher Plugin

param(
    [switch]$Force
)

Write-Host "FileSwitcher Plugin Installer" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

# Detect Notepad++ architecture
$nppPaths = @(
    "${env:ProgramFiles}\Notepad++\notepad++.exe",
    "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe",
    "${env:LOCALAPPDATA}\Programs\Notepad++\notepad++.exe"
)

$nppPath = $null
foreach ($path in $nppPaths) {
    if (Test-Path $path) {
        $nppPath = $path
        break
    }
}

if ($nppPath) {
    $nppVersion = (Get-Item $nppPath).VersionInfo.ProductVersion
    $is64Bit = $nppPath -notmatch "Program Files \(x86\)"
    $nppArch = if ($is64Bit) { "x64" } else { "x86" }
    
    Write-Host "Found Notepad++: $nppVersion ($nppArch)" -ForegroundColor Yellow
} else {
    Write-Host "Warning: Notepad++ not found, assuming x64" -ForegroundColor Yellow
    $nppArch = "x64"
}

# Choose the correct DLL based on architecture
$dllPath = if ($nppArch -eq "x64") {
    "x64\Release\FileSwitcher.dll"
} else {
    "Release\FileSwitcher.dll"
}

if (-not (Test-Path $dllPath)) {
    Write-Host "Plugin DLL not found: $dllPath" -ForegroundColor Red
    Write-Host "Please build the project for $nppArch first:" -ForegroundColor Yellow
    if ($nppArch -eq "x64") {
        Write-Host "msbuild FileSwitcher.sln /p:Configuration=Release /p:Platform=x64" -ForegroundColor White
    } else {
        Write-Host "msbuild FileSwitcher.sln /p:Configuration=Release /p:Platform=x86" -ForegroundColor White
    }
    exit 1
}

# Get Notepad++ plugins directory
$nppPluginsDirs = @(
    (Join-Path $env:APPDATA "Notepad++\plugins"),
    "C:\Program Files\Notepad++\plugins",
    "C:\Program Files (x86)\Notepad++\plugins"
)

$nppPluginsDir = $null
foreach ($dir in $nppPluginsDirs) {
    if (Test-Path $dir) {
        $nppPluginsDir = $dir
        Write-Host "Found plugins directory: $dir" -ForegroundColor Yellow
        break
    }
}

if (-not $nppPluginsDir) {
    Write-Host "Could not find Notepad++ plugins directory!" -ForegroundColor Red
    Write-Host "Trying to create in AppData..." -ForegroundColor Yellow
    $nppPluginsDir = Join-Path $env:APPDATA "Notepad++\plugins"
}

$pluginDir = Join-Path $nppPluginsDir "FileSwitcher"

Write-Host "Source DLL: $dllPath" -ForegroundColor Yellow
Write-Host "Target directory: $pluginDir" -ForegroundColor Yellow

# Create plugins directory if it doesn't exist
if (-not (Test-Path $nppPluginsDir)) {
    Write-Host "Creating Notepad++ plugins directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $nppPluginsDir -Force | Out-Null
}

# Create plugin directory
if (-not (Test-Path $pluginDir)) {
    Write-Host "Creating FileSwitcher plugin directory..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null
} elseif (-not $Force) {
    $response = Read-Host "Plugin directory already exists. Overwrite? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

# Copy the DLL
try {
    Write-Host "Installing plugin..." -ForegroundColor Cyan
    Copy-Item $dllPath $pluginDir -Force
    Write-Host "Plugin installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installation complete!" -ForegroundColor Green
    Write-Host "===================" -ForegroundColor Green
    Write-Host "1. Restart Notepad++ to load the plugin" -ForegroundColor White
    Write-Host "2. The plugin will appear in the Plugins menu as 'File Switcher'" -ForegroundColor White
    Write-Host "3. Use the plugin from Plugins > File Switcher > Show File Switcher" -ForegroundColor White
    Write-Host ""
    Write-Host "To set up a hotkey:" -ForegroundColor Cyan
    Write-Host "- Go to Settings > Shortcut Mapper" -ForegroundColor White
    Write-Host "- Click on 'Plugin commands' tab" -ForegroundColor White
    Write-Host "- Find 'Show File Switcher' and assign your preferred hotkey" -ForegroundColor White
    Write-Host "- Recommended hotkey: Ctrl+Shift+O" -ForegroundColor White
}
catch {
    Write-Host "Failed to install plugin: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
