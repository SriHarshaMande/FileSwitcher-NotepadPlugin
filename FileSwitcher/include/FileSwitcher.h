#pragma once

#include <windows.h>
#include <string>
#include <vector>

// Notepad++ interface structures
struct NppData {
    HWND _nppHandle;
    HWND _scintillaMainHandle;
    HWND _scintillaSecondHandle;
};

struct FuncItem {
    wchar_t _itemName[64];
    void (*_pFunc)();
    int _cmdID;
    bool _init2Check;
    void* _pShKey;
};

// Shortcut key structure
struct ShortcutKey {
    bool _isCtrl;
    bool _isAlt;
    bool _isShift;
    unsigned char _key;
};

// Menu commands
enum MenuCommand {
    CMD_SHOW_FILE_SWITCHER = 0,
    CMD_COUNT
};

// Function declarations
void initializePlugin();
void cleanupPlugin();
std::vector<std::wstring> getOpenFilenames();
void switchToFile(const std::wstring& filename);

extern NppData g_nppData;
