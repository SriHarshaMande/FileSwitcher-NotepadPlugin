#include "../include/PluginInterface.h"
#include "../include/FileSwitcher.h"
#include "../include/FileSwitcherDialog.h"
#include <cstring>

HINSTANCE g_hInstance = NULL;
HWND g_nppHandle = NULL;
NppData g_nppData;
FileSwitcherDialog* g_fileSwitcherDialog = nullptr;

// Function items for the plugin menu
FuncItem g_funcItems[CMD_COUNT];

// Default shortcut: Ctrl+Shift+O
ShortcutKey g_shortcutKey = { true, false, true, 'O' };

extern "C" __declspec(dllexport) void setInfo(void* notePadPlusData) {
    g_nppData = *static_cast<NppData*>(notePadPlusData);
    g_nppHandle = g_nppData._nppHandle;
}

extern "C" __declspec(dllexport) const wchar_t* getName() {
    return L"FileSwitcher";
}

extern "C" __declspec(dllexport) void* getFuncsArray(int* nbF) {
    *nbF = CMD_COUNT;
    
    // Initialize all function items to zero first
    memset(g_funcItems, 0, sizeof(g_funcItems));
    
    // Initialize menu items
    wcscpy_s(g_funcItems[CMD_SHOW_FILE_SWITCHER]._itemName, 64, L"Show File Switcher");
    g_funcItems[CMD_SHOW_FILE_SWITCHER]._pFunc = showFileSwitcher;
    g_funcItems[CMD_SHOW_FILE_SWITCHER]._init2Check = false;
    g_funcItems[CMD_SHOW_FILE_SWITCHER]._pShKey = &g_shortcutKey;
    g_funcItems[CMD_SHOW_FILE_SWITCHER]._cmdID = 0;
    
    return g_funcItems;
}

extern "C" __declspec(dllexport) void beNotified(void* notifyCode) {
    // Handle notifications from Notepad++
    // This is called when Notepad++ sends notifications to the plugin
}

extern "C" __declspec(dllexport) LRESULT messageProc(UINT Message, WPARAM wParam, LPARAM lParam) {
    return TRUE;
}

extern "C" __declspec(dllexport) BOOL isUnicode() {
    return TRUE;
}

void showFileSwitcher() {
    if (!g_fileSwitcherDialog) {
        g_fileSwitcherDialog = new FileSwitcherDialog();
    }
    g_fileSwitcherDialog->show();
}

void pluginInit(HANDLE hModule) {
    g_hInstance = static_cast<HINSTANCE>(hModule);
}

void pluginCleanUp() {
    if (g_fileSwitcherDialog) {
        delete g_fileSwitcherDialog;
        g_fileSwitcherDialog = nullptr;
    }
}

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
    case DLL_PROCESS_ATTACH:
        pluginInit(hModule);
        break;
    case DLL_PROCESS_DETACH:
        pluginCleanUp();
        break;
    }
    return TRUE;
}
