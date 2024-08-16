// wudsn.cpp : Defines the entry point for the application.
//

#include "framework.h"
#include "wudsn.h"
#include <cstdlib>
#include <iostream>
#include <sstream>
#include "fstream"

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
    _In_opt_ HINSTANCE hPrevInstance,
    _In_ LPWSTR    lpCmdLine,
    _In_ int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);
    
    std::cout.flush();
    
    std::ofstream script("wudsn.bat");
    script << "exit /b 1";
    script.close();
 
    std::wstringstream commandStream;
    commandStream << L"%ComSpec% /C wudsn.bat " << lpCmdLine;
    auto command = commandStream.str();
    int exitCode = _wsystem(command.c_str());
    if (exitCode != 0) {
        std::wstringstream errorStream;
        errorStream << "Execution of \"" << command << "\" failed with exit code " << exitCode << ".";
        MessageBox(NULL, errorStream.str().c_str(), L"WUDSN IDE", MB_ICONEXCLAMATION || MB_OK);
    }
    return exitCode;

}
