# FileSwitcher Plugin Troubleshooting Script

Write-Host "FileSwitcher Plugin Troubleshooting" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Check Notepad++ installation
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
    Write-Host "Found Notepad++: $nppPath" -ForegroundColor Yellow
    Write-Host "Version: $nppVersion" -ForegroundColor Yellow
    
    # Check architecture
    $nppArchitecture = if ([System.Environment]::Is64BitOperatingSystem) {
        if ((Get-Item $nppPath).VersionInfo.FileDescription -match "64") { "x64" } else { "x86" }
    } else {
        "x86"
    }
    Write-Host "Architecture: $nppArchitecture" -ForegroundColor Yellow
} else {
    Write-Host "Notepad++ not found in standard locations" -ForegroundColor Red
}

# Check plugin installation
$pluginPath = "$env:APPDATA\Notepad++\plugins\FileSwitcher\FileSwitcher.dll"
Write-Host ""
if (Test-Path $pluginPath) {
    $pluginInfo = Get-Item $pluginPath
    Write-Host "Plugin DLL found: $pluginPath" -ForegroundColor Green
    Write-Host "Size: $($pluginInfo.Length) bytes" -ForegroundColor Yellow
    Write-Host "Created: $($pluginInfo.CreationTime)" -ForegroundColor Yellow
    Write-Host "Modified: $($pluginInfo.LastWriteTime)" -ForegroundColor Yellow
    
    # Check if it's the right architecture
    Write-Host ""
    Write-Host "Plugin architecture: x64 (as built)" -ForegroundColor Yellow
    if ($nppArchitecture -eq "x86") {
        Write-Host "WARNING: Architecture mismatch!" -ForegroundColor Red
        Write-Host "Notepad++ is 32-bit but plugin is 64-bit" -ForegroundColor Red
        Write-Host "You need to rebuild the plugin for x86" -ForegroundColor Red
    }
} else {
    Write-Host "Plugin DLL not found at expected location" -ForegroundColor Red
}

# Check for alternative plugin locations
Write-Host ""
Write-Host "Checking alternative plugin locations..." -ForegroundColor Cyan

$altPaths = @(
    "${env:ProgramFiles}\Notepad++\plugins\FileSwitcher\",
    "${env:ProgramFiles(x86)}\Notepad++\plugins\FileSwitcher\",
    "${env:APPDATA}\Notepad++\plugins\"
)

foreach ($path in $altPaths) {
    if (Test-Path $path) {
        Write-Host "Found plugin directory: $path" -ForegroundColor Yellow
        Get-ChildItem $path -Filter "*.dll" | ForEach-Object {
            Write-Host "  - $($_.Name)" -ForegroundColor White
        }
    }
}

Write-Host ""
Write-Host "Troubleshooting Steps:" -ForegroundColor Cyan
Write-Host "1. Make sure Notepad++ is completely closed" -ForegroundColor White
Write-Host "2. Verify plugin is in correct directory for your Notepad++ version" -ForegroundColor White
Write-Host "3. Check architecture matches (32-bit vs 64-bit)" -ForegroundColor White
Write-Host "4. Try restarting Notepad++ as administrator" -ForegroundColor White
Write-Host "5. Check Windows Event Viewer for any DLL loading errors" -ForegroundColor White

if ($nppArchitecture -eq "x86") {
    Write-Host ""
    Write-Host "To build 32-bit version:" -ForegroundColor Cyan
    Write-Host "msbuild FileSwitcher.sln /p:Configuration=Release /p:Platform=Win32" -ForegroundColor White
}
