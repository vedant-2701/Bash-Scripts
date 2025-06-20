# Bash Scripts 🚀

Welcome to *Bash Scripts*! A collection of Bash scripts to streamline your development workflow across a wide range of programming languages and frameworks, including Vite-based projects (React, Vue, Svelte, Preact, Solid), Python, Java, and more. These scripts are designed for seamless use on Windows (via Git Bash or PowerShell), Linux, macOS, and Unix-like systems. Modular, extensible, and developer-friendly! ✨

<!-- ![GitHub](https://img.shields.io/github/license/vedant-2701/Bash-Scripts) -->
![GitHub stars](https://img.shields.io/github/stars/vedant-2701/Bash-Scripts?style=social)

## Table of Contents
- [Overview](#overview-)
- [Installation](#installation-%EF%B8%8F)
- [Usage](#usage-)
  - [Running Scripts](#running-scripts-)
  - [Available Scripts](#available-scripts-)
- [Scripts Documentation](#scripts-documentation-)


## Overview 📖
This repository provides a set of reusable Bash scripts to automate common tasks. The scripts are designed to be modular, allowing you to add more functionality as needed 🖥️

## Installation 🛠️

1. **Clone the Repository**:

  ```bash
  git clone <https://github.com/vedant-2701/Bash-Scripts.git>
  cd Bash-Scripts
  ```

<br />

2. **Add PATH**: <br />


- **For Unix-Based System**:
  <br />

  -  **Add Path**:
  <br />

    ```bash
    mkdir -p ~/scripts
    mv *.sh ~/scripts/
    echo 'export PATH=$PATH:$HOME/scripts' >> ~/.bashrc
    source ~/.bashrc
    ```

  <br />

  -  **Set Permissions**:
  <br />

    ```bash
    chmod +x ~/scripts/*.sh
    ```

<br />

- **For Windows(powershell)**:
  <br />

  -  **Create Scripts Folder**:
  <br />

    ```bash
    New-Item -Path "$HOME\scripts" -ItemType Directory -Force
    Move-Item -Path *.sh -Destination "$HOME\scripts"
    ```

  <br />

  -  **Add Folder to Path**:
  <br />

    ```bash
    $ScriptsPath = "$HOME\scripts"
    $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $CurrentPath.Contains($ScriptsPath)) {
        [Environment]::SetEnvironmentVariable("Path", "$CurrentPath;$ScriptsPath", "User")
    }
  ```

  <br />

  -  **Adding Permission**:
  <br />

    ```bash
    if (Test-Path "C:\Program Files\Git\bin\bash.exe") {
        & "C:\Program Files\Git\bin\bash.exe" -c "chmod +x $ScriptsFolder/*.sh"
        Write-Host "Execution permissions set for all .sh files in $ScriptsFolder"
    } else {
        Write-Error "Git Bash not found. Install it from https://git-scm.com/"
    }
    ```
  -  **Note: Make sure Git Bash is installed and its path is correct.**

  <br />

## Usage 🎮

### Running Scripts ⚡


- **Using Bash-compatible terminal**:

    ```bash
    script-name.sh [arguments]
    ```


- **Using Powershell**:

  To run .sh scripts in VS Code’s integrated PowerShell terminal:

  -  **Open Powershell in VS Code**

  <br />

  -  **Create or edit your PowerShell profile** (Your PowerShell profile is typically located at $PROFILE. If it doesn’t exist, create it)
  <br />

    ```bash
    if (!(Test-Path -Path $PROFILE)) {
      New-Item -ItemType File -Path $PROFILE -Force
    }
    notepad $PROFILE
    ```

  <br />

  -  **Add following to the profile**

  <br />

    ```bash
    $ExecutionContext.InvokeCommand.CommandNotFoundAction = {
        param($commandName, $commandLookupEventArgs)

        # Check if the command ends with '.sh'
        if ($commandName -like '*.sh') {
            # Check if WSL is available
            if (Get-Command wsl -ErrorAction SilentlyContinue) {
                Write-Host "Running $commandName in WSL Ubuntu..."
                wsl -d Ubuntu bash "$commandName"
            }
            # Check if Git Bash is installed
            elseif (Test-Path "C:\Program Files\Git\bin\bash.exe") {
                Write-Host "Running $commandName in Git Bash..."
                & "C:\Program Files\Git\bin\bash.exe" "$commandName"
            }
            else {
                Write-Error "Error: Neither WSL Ubuntu nor Git Bash is installed."
            }
            # Stop PowerShell from further command lookup
            $commandLookupEventArgs.StopSearch = $true
        }
    }
    ```

  **Note**: Change path of WSL or Git Bash if needed.

  <br />

  -  **Save the file**

  <br />

  -  **Reload the profile**

  <br />

    ```bash
    . $PROFILE
    ```

  <br />

  -  **Run scripts by typing their names in the PowerShell terminal**

  <br />

    ```bash
    script-name.sh [arguments]
    ```

<br />

### Available Scripts 📜

| Script                                                | Purpose                                      |
|-------------------------------------------------------|----------------------------------------------|
| [`open-vscode.sh` ](#1-open-vscodesh)                  | Opens current folder in VS Code              |
| [`vite-create-project.sh`](#2-vite-create-projectsh)   | Creates a new Vite project (React, Vue, etc.)|
| [`setup-tailwind.sh`](#3-setup-tailwindsh)             | Sets up Tailwind CSS in a Vite React project |


<br />

## Scripts Documentation 📄

<br />

### 1. **open-vscode.sh**

**Purpose**: Opens the current directory in Visual Studio Code.

**Arguments**:
- None (Operates on the current working directory).

**What it does**:
- Checks if the `code` command (VS Code CLI) is available.
- Opens the current directory in VS Code using the `code` command.
- Provides feedback if VS Code is not installed or the command fails.

**How to run**:

1. Navigate to the desired directory.

2. Run the script in address bar of the folder:

   ```bash
   open-vscode.sh
   ```

**Notes**:
- Requires Visual Studio Code to be installed with the `code` command available in the PATH.

<br />

### 2. **vite-create-project.sh**

**Purpose**: Creates a new Vite project with the specified framework (React, Vue, Svelte, Preact, or Solid) and specified language (js, ts).

**Arguments**:
- `-n <project-name>` or `--name <project-name>`: Specifies the project name. **Required** 
- `-f <framework>` or `--framework <framework>`: Specifies the framework (react, vue, svelte, preact, solid). **Required**
- `-l <language>` or `--lang <language>`: Specifies the language (js, ts). **Required**
- `-s` or `--start`: Starts the development server. **Optional**
- `--dir`: Specifies the project directory to create the project. **Optional**
- `--pm`: Specifies the package manager (npm, pnpm, yarn). **Optional**
- `--help`: Shows the available flags.

**What it does**:
- Validates the provided framework and project name.
- Creates a new Vite project with the specified framework.
- Installs project dependencies.
- Provides feedback on the creation process and next steps.

**How to run**:

   ```bash
   vite-create-project.sh -n <project-name> -f <framework> -l <language> [-s] [--dir <path>] [--pm <package-manager-name>]
   ```

  or
 
   ```bash
   vite-create-project.sh --name <project-name> --framework <framework> --lang <language> [--start] [--dir <path>] [--pm <package-manager-name>]
   ```

**Notes**:
- Requires Node.js and specified package manager to be installed. If package manager is not specified it by default takes `npm`.
- The script checks for valid framework options, valid language and valid package manager and exits with an error if an invalid framework or language or package manager is provided.

<br />

### 3. **setup-tailwind.sh**

**Purpose**: Automates the setup of Tailwind CSS in a Vite-based React project by installing dependencies and configuring necessary files.

**Arguments**:
- None (Assumes the script is run from the root of a Vite React project).

**What it does**:
- Prompts the way to install the tailwind (vite, postcss).
- Checks if `node` and `npm` is installed.
- Installs `tailwindcss` and other libraries according to the specification via npm.
- Initializes Tailwind CSS configuration.
- Updates the project's main CSS file to include Tailwind directives.
- Updates the `App.jsx` or `App.tsx` file for sample tailwindcss code.
- Provides feedback on success or failure.

**How to run**:

1. Navigate to the root of your Vite React project.

2. Run the script:

   ```bash
   setup-tailwind.sh
   ```

**Notes**:
- Ensure `package.json` exists in the project directory.
- Requires Node.js and npm to be installed.
- If Tailwind is already installed, the script will skip redundant installations.