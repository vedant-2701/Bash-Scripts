#!/bin/bash

# Get the current directory where the script is run
FOLDER_PATH="$(pwd)"

# Check if the folder exists (it should, since we're in it)
if [ -d "$FOLDER_PATH" ]; then
    # Open VS Code in the current folder
    code .
else
    echo "Error: Unable to determine current folder"
    exit 1
fi

# Exit the script to close the terminal
exit 0