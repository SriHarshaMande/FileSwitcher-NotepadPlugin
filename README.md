# File Switcher Plugin for Notepad++

A Notepad++ plugin that provides quick file switching with dynamic search functionality, similar to the "Quick Open" feature in Visual Studio Code.

## Features

- **Quick File Switcher**: Press a configurable hotkey to open the file switcher dialog
- **Dynamic Search**: Type to filter open files by filename in real-time
- **Instant Navigation**: Select a file from the list to switch to it immediately
- **Fuzzy Matching**: Find files even with partial matches
- **Keyboard Navigation**: Use arrow keys to navigate the file list
- **Clean Interface**: Simple, focused dialog that doesn't get in your way

## Installation

### Option 1: Automatic Installation (Recommended)

1. Build the plugin (see Building section below)
2. Run the installation script:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File install.ps1
   ```
3. Restart Notepad++

### Option 2: Manual Installation

1. Build the plugin to generate `FileSwitcher.dll`
2. Create the plugin directory:
   ```
   %APPDATA%\Notepad++\plugins\FileSwitcher\
   ```
3. Copy `FileSwitcher.dll` to the created directory
4. Restart Notepad++

## Usage

1. Open multiple files in Notepad++
2. Access the file switcher via:
   - **Plugins** menu → **File Switcher** → **Show File Switcher**
   - Or use your configured hotkey (see Setup section)
3. Start typing to filter the file list
4. Use arrow keys or mouse to select a file
5. Press **Enter** or **double-click** to switch to the selected file
6. Press **Escape** to close the dialog without switching

## Setup

### Configuring the Hotkey

1. Open Notepad++
2. Go to **Settings** → **Shortcut Mapper**
3. Click on the **Plugin commands** tab
4. Find **"Show File Switcher"** in the list
5. Double-click to assign your preferred hotkey (recommended: `Ctrl+Shift+O`)

## Building from Source

### Requirements

- **Visual Studio 2019** or later with C++ development tools
- **Windows SDK**
- **PowerShell** (for build scripts)

### Build Steps

#### Using VS Code (Recommended)

1. Open this project in VS Code
2. Press `Ctrl+Shift+P` and select **Tasks: Run Task**
3. Choose **"Build FileSwitcher Plugin"**
4. The plugin DLL will be generated in `x64\Release\FileSwitcher.dll`

#### Using PowerShell

```powershell
# Build the plugin
powershell.exe -ExecutionPolicy Bypass -File build.ps1

# Install the plugin (optional)
powershell.exe -ExecutionPolicy Bypass -File install.ps1
```

#### Using Command Line

```cmd
# Set up Visual Studio environment and build
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat"
msbuild FileSwitcher.sln /p:Configuration=Release /p:Platform=x64
```

### Build Output

- **Release DLL**: `x64\Release\FileSwitcher.dll`
- **Debug DLL**: `x64\Debug\FileSwitcher.dll`

## Project Structure

```
FileSwitcher/
├── include/
│   ├── FileSwitcher.h          # Main plugin interface
│   ├── FileSwitcherDialog.h    # Dialog implementation
│   ├── PluginInterface.h       # Notepad++ plugin interface
│   └── resource.h              # Resource definitions
├── src/
│   ├── FileSwitcher.cpp        # Core functionality
│   ├── FileSwitcherDialog.cpp  # Dialog logic and UI
│   └── PluginInterface.cpp     # Plugin entry points
├── FileSwitcher.rc             # UI resources
├── FileSwitcher.def            # DLL exports
└── FileSwitcher.vcxproj        # Visual Studio project
```

## Technical Details

### Plugin Architecture

- **Plugin Interface**: Implements the standard Notepad++ plugin interface
- **File Management**: Uses Notepad++ API to get list of open files and switch between them
- **UI Components**: Custom Windows dialog with search edit box and file list
- **Search Algorithm**: Real-time filtering with case-insensitive substring matching

### Notepad++ API Usage

- `NPPM_GETNBOPENFILES`: Get count of open files
- `NPPM_GETOPENFILENAMES`: Retrieve list of open file paths
- `NPPM_SWITCHTOFILE`: Switch to a specific file

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the plugin thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Troubleshooting

### Build Issues

- **"msbuild not found"**: Make sure Visual Studio 2019+ is installed with C++ development tools
- **"vcvars64.bat not found"**: Update the path in `build.ps1` to match your Visual Studio installation

### Plugin Issues

- **Plugin not appearing**: Verify the DLL is in the correct folder and Notepad++ was restarted
- **Dialog not showing**: Check if the hotkey is properly configured or use the Plugins menu
- **No files in list**: Make sure you have multiple files open in Notepad++

## Changelog

### Version 1.0.0

- Initial release
- Basic file switching functionality
- Dynamic search filtering
- Keyboard navigation support
- Automatic installation script
