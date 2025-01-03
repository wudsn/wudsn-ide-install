//
// WUDSN IDE Installer
//
// Creates the "wudsn.bat" file in the folder where the "wudsn.exe" is located.
// The the "wudsn.bat" file is started using %ComSpec%, passing the parameters from the command line.

#include "framework.h"
#include "wudsn.h"
#include "wudsn.bat.h"
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <sstream>
#include <filesystem> 
#pragma comment(lib, "urlmon.lib")

using  std::filesystem::path;
using std::wstring;
using  std::wstringstream;

std::wstring GetExecutableFolder()
{
    using namespace std;

    WCHAR buffer[MAX_PATH];

    GetModuleFileName(NULL, buffer, MAX_PATH);

    wstring::size_type pos = wstring(buffer).find_last_of(L"\\/");

    if (pos == string::npos)
    {
        return L"";
    }
    else
    {
        return wstring(buffer).substr(0, pos);
    }
}

//bool FileExists(const path& filePath) {
//    std::error_code ec; // For noexcept overload usage.
//    return std::filesystem::exists(filePath, ec);
//}

void ShowErrorMessage(const wstringstream& message) {
    MessageBox(NULL, message.str().c_str(), L"WUDSN IDE", MB_ICONEXCLAMATION || MB_OK);
}

void ShowErrorMessage(LPCWSTR message) {
    MessageBox(NULL, message, L"WUDSN IDE", MB_ICONEXCLAMATION || MB_OK);
}

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
    _In_opt_ HINSTANCE hPrevInstance,
    _In_ LPWSTR    lpCmdLine,
    _In_ int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

    std::cout.flush();

    path exeFolderPath(GetExecutableFolder());
    path batFileName("wudsn.bat");
    path batFilePath = exeFolderPath;

    std::filesystem::current_path(exeFolderPath);

    batFilePath /= batFileName;

    std::ofstream script(batFilePath);
    script.write((const char*)___wudsn_bat, ___wudsn_bat_len);
    script.close();


    wstringstream commandStream;
    commandStream << L"%ComSpec% /C " << batFileName.wstring() << " " << lpCmdLine;
    auto command = commandStream.str();

    int exitCode = _wsystem(command.c_str());
    if (exitCode != 0) {
        wstringstream errorStream;
        errorStream << "Execution of \"" << command << "\" failed with exit code " << exitCode << ".";
        ShowErrorMessage(errorStream);
    }
    return exitCode;

}
