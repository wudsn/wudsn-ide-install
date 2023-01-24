# WUDSN IDE Installer

The WUDSN IDE installer is the simplest way to install [WUDSN IDE](https://github.com/peterdell/wudsn-ide).</br>
Create a folder where you want to put the IDE.
Make sure the folder path contains no spaces or whitespaces.

On Windows (64-bit Intel), download "wudsn.bat" or "wudsn.exe" to the folder and run it.
- https://github.com/peterdell/wudsn-ide-install/raw/main/wudsn.bat or
- https://github.com/peterdell/wudsn-ide-install/raw/main/wudsn.exe<br>
  The executable "wudsn.exe" is the same as "wudsn.bat", but with icons and the option to link it with file associations.<br>
  Note: Currently Windows Defender may complain upon the first launch of "wudsn.exe".
        To exclude it from checks open the Windows settings and follow the path
        Virus & threat protection settings / Manage Settings / Exclusions / Add or remove exclusions / Add an exclusion" <br>
  
On macOS (64-bit Intel or ARM/M1) an Linux, download "wudsn.sh" to the folder and run it.
- https://github.com/peterdell/wudsn-ide-install/raw/main/wudsn.sh
 
The file will create and populate the following subfolders via downloads:
- Install - the cache folder where all downloads are stored
- Tools - the IDE and all related command line programs
- Projects - the platform specific project folders with sample source code
- Workspace - the workspace where the IDE stores data that is no source code
![Folders](images/wudsn-installer-folders.png)

Upon the first start you can import projects for the platform you'd like to work with into the workspace.
Click "File / Open Projecs from File System" and select the platform folder from the "Projects" folder.
![Import Project](images/wudsn-installer-import-project.png)

The path to the assemblers/compilers/emulators in the Tools folder must be set once manually.
I plan to improve this in future releases of the IDE.

In case of problems check the "wudsn.log" file in the folder.
You can also run "wudsn.exe" from the command line with the parameter --install.
This will display the installer menu with options to reinstall or update the IDE.
![Installer Menu](images/wudsn-installer-menu.png)
