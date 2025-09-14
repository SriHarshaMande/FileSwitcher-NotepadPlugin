#include "../include/FileSwitcher.h"

// Notepad++ message constants
#define NPPMSG (WM_USER + 1000)
#define NPPM_GETNBOPENFILES (NPPMSG + 7)
#define NPPM_GETOPENFILENAMES (NPPMSG + 8)
#define NPPM_SWITCHTOFILE (NPPMSG + 37)

// File access modes
#define ALL_OPEN_FILES 0
#define PRIMARY_VIEW 1
#define SECOND_VIEW 2

// External declaration - defined in PluginInterface.cpp
extern NppData g_nppData;

void initializePlugin() {
    // Plugin initialization if needed
}

void cleanupPlugin() {
    // Plugin cleanup if needed
}

std::vector<std::wstring> getOpenFilenames() {
    std::vector<std::wstring> filenames;
    
    // Get number of open files
    int fileCount = static_cast<int>(::SendMessage(g_nppData._nppHandle, NPPM_GETNBOPENFILES, 0, ALL_OPEN_FILES));
    
    if (fileCount > 0) {
        // Allocate buffer for filenames
        wchar_t** fileNames = new wchar_t*[fileCount];
        for (int i = 0; i < fileCount; i++) {
            fileNames[i] = new wchar_t[MAX_PATH];
        }
        
        // Get the filenames
        ::SendMessage(g_nppData._nppHandle, NPPM_GETOPENFILENAMES, 
                     reinterpret_cast<WPARAM>(fileNames), fileCount);
        
        // Copy to vector
        for (int i = 0; i < fileCount; i++) {
            filenames.push_back(std::wstring(fileNames[i]));
            delete[] fileNames[i];
        }
        delete[] fileNames;
    }
    
    return filenames;
}

void switchToFile(const std::wstring& filename) {
    // Try to switch to the specified file using the full path
    LRESULT result = ::SendMessage(g_nppData._nppHandle, NPPM_SWITCHTOFILE, 0, 
                                  reinterpret_cast<LPARAM>(filename.c_str()));
    
    // If that didn't work, we could try other approaches here
    // For now, we'll stick with the simple approach
}
