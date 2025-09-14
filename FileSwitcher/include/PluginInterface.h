#pragma once

#include <windows.h>

// Plugin Interface for Notepad++
extern "C" __declspec(dllexport) void setInfo(void* notePadPlusData);
extern "C" __declspec(dllexport) const wchar_t* getName();
extern "C" __declspec(dllexport) void* getFuncsArray(int* nbF);
extern "C" __declspec(dllexport) void beNotified(void* notifyCode);
extern "C" __declspec(dllexport) LRESULT messageProc(UINT Message, WPARAM wParam, LPARAM lParam);
extern "C" __declspec(dllexport) BOOL isUnicode();

// Plugin functions
void showFileSwitcher();
void pluginInit(HANDLE hModule);
void pluginCleanUp();

// Global variables
extern HINSTANCE g_hInstance;
extern HWND g_nppHandle;
