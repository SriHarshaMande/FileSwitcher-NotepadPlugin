#include "../include/FileSwitcherDialog.h"
#include "../include/FileSwitcher.h"
#include "../include/resource.h"
#include <algorithm>
#include <cctype>
#include <commctrl.h>

extern HINSTANCE g_hInstance;
extern HWND g_nppHandle;

FileSwitcherDialog* FileSwitcherDialog::s_instance = nullptr;

FileSwitcherDialog::FileSwitcherDialog() 
    : m_hDialog(nullptr), m_hListBox(nullptr), m_hSearchEdit(nullptr) {
    s_instance = this;
}

FileSwitcherDialog::~FileSwitcherDialog() {
    if (m_hDialog) {
        DestroyWindow(m_hDialog);
    }
    s_instance = nullptr;
}

void FileSwitcherDialog::show() {
    if (!m_hDialog) {
        m_hDialog = CreateDialog(g_hInstance, MAKEINTRESOURCE(IDD_FILE_SWITCHER), 
                                g_nppHandle, dialogProc);
        if (!m_hDialog) {
            return;
        }
    }
    
    // Refresh file list
    updateFileList();
    
    // Show dialog
    ShowWindow(m_hDialog, SW_SHOW);
    SetForegroundWindow(m_hDialog);
    
    // Focus on search edit
    if (m_hSearchEdit) {
        SetFocus(m_hSearchEdit);
        SetWindowText(m_hSearchEdit, L"");
    }
}

void FileSwitcherDialog::hide() {
    if (m_hDialog) {
        ShowWindow(m_hDialog, SW_HIDE);
    }
}

bool FileSwitcherDialog::isVisible() const {
    return m_hDialog && IsWindowVisible(m_hDialog);
}

INT_PTR CALLBACK FileSwitcherDialog::dialogProc(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam) {
    if (!s_instance) {
        return FALSE;
    }
    
    switch (message) {
    case WM_INITDIALOG:
        s_instance->initializeDialog(hDlg);
        return TRUE;
        
    case WM_COMMAND:
        switch (LOWORD(wParam)) {
        case IDC_SEARCH_EDIT:
            if (HIWORD(wParam) == EN_CHANGE) {
                s_instance->onSearchTextChanged();
            }
            break;
            
        case IDC_FILE_LIST:
            if (HIWORD(wParam) == LBN_DBLCLK) {
                s_instance->onFileSelected();
            }
            break;
            
        case IDOK:
            s_instance->onFileSelected();
            break;
            
        case IDCANCEL:
            s_instance->hide();
            break;
        }
        break;
        
    case WM_KEYDOWN:
        return s_instance->onKeyDown(wParam);
        
    case WM_CLOSE:
        s_instance->hide();
        return TRUE;
    }
    
    return FALSE;
}

void FileSwitcherDialog::initializeDialog(HWND hDlg) {
    m_hDialog = hDlg;
    m_hListBox = GetDlgItem(hDlg, IDC_FILE_LIST);
    m_hSearchEdit = GetDlgItem(hDlg, IDC_SEARCH_EDIT);
    
    // Center dialog on parent window
    RECT parentRect, dialogRect;
    GetWindowRect(g_nppHandle, &parentRect);
    GetWindowRect(hDlg, &dialogRect);
    
    int x = parentRect.left + (parentRect.right - parentRect.left - (dialogRect.right - dialogRect.left)) / 2;
    int y = parentRect.top + (parentRect.bottom - parentRect.top - (dialogRect.bottom - dialogRect.top)) / 2;
    
    SetWindowPos(hDlg, HWND_TOP, x, y, 0, 0, SWP_NOSIZE);
    
    // Subclass the search edit to handle key navigation
    SetWindowSubclass(m_hSearchEdit, [](HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam, UINT_PTR uIdSubclass, DWORD_PTR dwRefData) -> LRESULT {
        if (uMsg == WM_KEYDOWN) {
            if (wParam == VK_UP || wParam == VK_DOWN || wParam == VK_RETURN || wParam == VK_ESCAPE) {
                // Forward navigation keys to dialog
                return SendMessage(GetParent(hWnd), WM_KEYDOWN, wParam, lParam);
            }
        }
        return DefSubclassProc(hWnd, uMsg, wParam, lParam);
    }, 1, 0);
}

void FileSwitcherDialog::updateFileList(const std::wstring& filter) {
    if (!m_hListBox) return;
    
    // Clear list
    SendMessage(m_hListBox, LB_RESETCONTENT, 0, 0);
    
    // Get all open files
    m_allFiles = getOpenFilenames();
    m_filteredFiles.clear();
    
    // Filter files and add to both filtered list and listbox
    for (const auto& filepath : m_allFiles) {
        std::wstring filename = extractFilename(filepath);
        if (filter.empty() || matchesFilter(filename, filter)) {
            // Add to filtered files list (full path)
            m_filteredFiles.push_back(filepath);
            
            // Add filename to listbox
            SendMessage(m_hListBox, LB_ADDSTRING, 0, 
                       reinterpret_cast<LPARAM>(filename.c_str()));
        }
    }
    
    // Select first item if any
    if (!m_filteredFiles.empty()) {
        SendMessage(m_hListBox, LB_SETCURSEL, 0, 0);
    }
}

void FileSwitcherDialog::onSearchTextChanged() {
    if (!m_hSearchEdit) return;
    
    wchar_t searchText[256];
    GetWindowText(m_hSearchEdit, searchText, 256);
    
    updateFileList(std::wstring(searchText));
}

void FileSwitcherDialog::onFileSelected() {
    if (!m_hListBox) return;
    
    int selectedIndex = static_cast<int>(SendMessage(m_hListBox, LB_GETCURSEL, 0, 0));
    if (selectedIndex >= 0 && selectedIndex < static_cast<int>(m_filteredFiles.size())) {
        const std::wstring& selectedFile = m_filteredFiles[selectedIndex];
        switchToFile(selectedFile);
        hide();
    }
}

bool FileSwitcherDialog::onKeyDown(WPARAM wParam) {
    switch (wParam) {
    case VK_ESCAPE:
        hide();
        return true;
        
    case VK_RETURN:
        onFileSelected();
        return true;
        
    case VK_UP:
        if (m_hListBox) {
            int currentSel = static_cast<int>(SendMessage(m_hListBox, LB_GETCURSEL, 0, 0));
            if (currentSel > 0) {
                SendMessage(m_hListBox, LB_SETCURSEL, currentSel - 1, 0);
            } else if (currentSel == LB_ERR || currentSel == 0) {
                // If nothing is selected or first item is selected, select the last item
                int itemCount = static_cast<int>(SendMessage(m_hListBox, LB_GETCOUNT, 0, 0));
                if (itemCount > 0) {
                    SendMessage(m_hListBox, LB_SETCURSEL, itemCount - 1, 0);
                }
            }
            return true;
        }
        break;
        
    case VK_DOWN:
        if (m_hListBox) {
            int currentSel = static_cast<int>(SendMessage(m_hListBox, LB_GETCURSEL, 0, 0));
            int itemCount = static_cast<int>(SendMessage(m_hListBox, LB_GETCOUNT, 0, 0));
            if (currentSel == LB_ERR) {
                // Nothing selected, select first item
                if (itemCount > 0) {
                    SendMessage(m_hListBox, LB_SETCURSEL, 0, 0);
                }
            } else if (currentSel < itemCount - 1) {
                SendMessage(m_hListBox, LB_SETCURSEL, currentSel + 1, 0);
            } else {
                // Last item selected, go to first
                SendMessage(m_hListBox, LB_SETCURSEL, 0, 0);
            }
            return true;
        }
        break;
    }
    return false;
}

bool FileSwitcherDialog::matchesFilter(const std::wstring& filename, const std::wstring& filter) {
    if (filter.empty()) return true;
    
    // Convert to lowercase for case-insensitive matching
    std::wstring lowerFilename = filename;
    std::wstring lowerFilter = filter;
    
    std::transform(lowerFilename.begin(), lowerFilename.end(), lowerFilename.begin(), ::towlower);
    std::transform(lowerFilter.begin(), lowerFilter.end(), lowerFilter.begin(), ::towlower);
    
    // Simple substring matching
    return lowerFilename.find(lowerFilter) != std::wstring::npos;
}

std::wstring FileSwitcherDialog::extractFilename(const std::wstring& fullPath) {
    size_t lastSlash = fullPath.find_last_of(L"\\/");
    if (lastSlash != std::wstring::npos && lastSlash < fullPath.length() - 1) {
        return fullPath.substr(lastSlash + 1);
    }
    return fullPath;
}
