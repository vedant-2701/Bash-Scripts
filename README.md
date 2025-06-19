# Bash Scripts 🚀

Welcome to *Bash Scripts*! A collection of Bash scripts to streamline your development workflow across a wide range of programming languages and frameworks, including Vite-based projects (React, Vue, Svelte, Preact, Solid), Python, Java, and more. These scripts are designed for seamless use on Windows (via Git Bash or PowerShell), Linux, macOS, and Unix-like systems. Modular, extensible, and developer-friendly! ✨

![GitHub](https://img.shields.io/github/license/vedant-2701/Bash-Scripts)
![GitHub stars](https://img.shields.io/github/stars/vedant-2701/Bash-Scripts?style=social)

## Table of Contents
- [Overview](#overview-)
- [Installation](#installation-)
- [Usage](#usage)
  - [Available Scripts](#available-scripts)
  - [Running Scripts](#running-scripts)
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
    cd bash-scripts
  ```

2. **Add PATH**:

- **For Unix-Based System**:

  -  **Add Path**:
  <br />

  ```bash
    mkdir -p ~/scripts
    mv *.sh ~/scripts/
    echo 'export PATH=$PATH:$HOME/scripts' >> ~/.bashrc
    source ~/.bashrc
  ```

  -  **Set Permissions**:
  <br />

  ```bash
    chmod +x ~/scripts/*.sh
  ```

- **For Windows(powershell)**:

  -  **Create Scripts Folder**:
  <br />

  ```bash
    New-Item -Path "$HOME\scripts" -ItemType Directory -Force
    Move-Item -Path *.sh -Destination "$HOME\scripts"
  ```
  -  **Add Folder to Path**:
  <br />

  ```bash
    $ScriptsPath = "$HOME\scripts"
    $CurrentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not $CurrentPath.Contains($ScriptsPath)) {
        [Environment]::SetEnvironmentVariable("Path", "$CurrentPath;$ScriptsPath", "User")
    }
  ```
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




