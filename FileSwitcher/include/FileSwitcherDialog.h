#pragma once

#include <windows.h>
#include <string>
#include <vector>

#define IDD_FILE_SWITCHER 1000
#define IDC_FILE_LIST 1001
#define IDC_SEARCH_EDIT 1002

class FileSwitcherDialog {
public:
    FileSwitcherDialog();
    ~FileSwitcherDialog();

    void show();
    void hide();
    bool isVisible() const;

private:
    static INT_PTR CALLBACK dialogProc(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam);
    
    void initializeDialog(HWND hDlg);
    void updateFileList(const std::wstring& filter = L"");
    void onSearchTextChanged();
    void onFileSelected();
    bool onKeyDown(WPARAM wParam);
    
    bool matchesFilter(const std::wstring& filename, const std::wstring& filter);
    std::wstring extractFilename(const std::wstring& fullPath);
    
    HWND m_hDialog;
    HWND m_hListBox;
    HWND m_hSearchEdit;
    std::vector<std::wstring> m_allFiles;
    std::vector<std::wstring> m_filteredFiles;
    
    static FileSwitcherDialog* s_instance;
};
