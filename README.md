# Bash Scripts 🚀

Welcome to *Bash Scripts*! A collection of Bash scripts to streamline your development workflow across a wide range of programming languages and frameworks, including Vite-based projects (React, Vue, Svelte, Preact, Solid), Python, Java, and more. These scripts are designed for seamless use on Windows (via Git Bash or PowerShell), Linux, macOS, and Unix-like systems. Modular, extensible, and developer-friendly! ✨

![GitHub](https://img.shields.io/github/license/vedant-2701/Bash-Scripts)
![GitHub stars](https://img.shields.io/github/stars/vedant-2701/Bash-Scripts?style=social)

## Table of Contents
- [Overview](#overview-)
- [Installation](#installation-)
- [Usage](#usage-)
  - [Running Scripts](#running-scripts)
  - [Available Scripts](#available-scripts)
- [Scripts Documentation](#scripts-documentation)
  - [setup-tailwind.sh](#vite-setup-tailwindsh)
  - [vite-create-project.sh](#vite-create-projectsh)
  - [dev-open-vscode.sh](#dev-open-vscodesh)
<!-- - [Contributing](#contributing)
- [Future Plans](#future-plans)
- [License](#license) -->

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
| [`setup-tailwind.sh`](#setup-tailwind.sh)             | Sets up Tailwind CSS in a Vite React project |
| [`vite-create-project.sh`](#vite-create-project.sh)   | Creates a new Vite project (React, Vue, etc.)|
| [`open-vscode.sh` ](#open-vscode.sh)                  | Opens current folder in VS Code              |
