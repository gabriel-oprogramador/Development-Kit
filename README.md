
## Support and Commands
![Windows](https://img.shields.io/badge/Windows-OK-green)
![Windows](https://img.shields.io/badge/mkdir-green)
![Windows](https://img.shields.io/badge/rmdir-green)
![Windows](https://img.shields.io/badge/cp-green)
![Windows](https://img.shields.io/badge/mv-green)
![Windows](https://img.shields.io/badge/rm-green)
![Windows](https://img.shields.io/badge/touch-green)
  
![Linux](https://img.shields.io/badge/Linux-OK-green)
![Linux](https://img.shields.io/badge/mkdir-green)
![Linux](https://img.shields.io/badge/rmdir-green)
![Linux](https://img.shields.io/badge/cp-green)
![Linux](https://img.shields.io/badge/mv-green)
![Linux](https://img.shields.io/badge/rm-green)
![Linux](https://img.shields.io/badge/touch-green)

## Development-Kit
Game development toolkit Made in C with lua scripts.  
Toolkit to Create, Generate, Manipulate and compile projects in C/C++. 
This tool automatically generates project files based on a TargetRules.lua file located in the root directory. It supports various development environments and provides automated configurations for debugging and Intellisense. Below is an overview of its features:

Features
Visual Studio 2019 and 2022 Compatibility
Automatically generates solution (.sln) and project files compatible with Visual Studio 2019 and 2022.

Makefile Support
Creates Makefile for compiling the project in Linux or Windows environments using make.

Automated Intellisense and Debugging
Configures essential files for a seamless development experience in the following tools:

Visual Studio Code (VS Code): Full support for Intellisense and debugging through tailored configurations.
Vim and Neovim: Generates the necessary setup for these editors, including support for autocompletion, debugging, and other features.
Versatility Across Environments
The system is designed to support multiple development tools, such as:

Visual Studio (2019 and 2022).
Visual Studio Code.
Vim and Neovim (via plugins and automated setups).
Objective
The main goal of this tool is to provide an easy-to-use and functional integration across different IDEs and editors. Developers can choose their preferred environment, while the system handles most of the configuration automatically, reducing manual effort.

## Instructions
Have a GCC or Clang compiler available via the terminal.  
Compile the binary with the "Programs/Setup" command for your platform.  
Run the commands by calling "DK" in the project root folder.  
Note: In Windows use ./DK.exe! Linux ./DK

## Commands
./DK mkdir Build/Debug  
./DK rmdir Build/Debug  
./DK cp Build/Debug Package  
./DK mv Build/Debug Package  
./DK rm MyFile.txt NewFile.txt  
./DK touch NewFile.txt  
./DK touch NewFile.txt "File Content"  
./DK touch NewFile.txt "File Content" append  
