#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 <project-name> --framework <framework> --lang <language> [options]"
    echo ""
    echo "Arguments:"
    echo "  <project-name>          Name of the project directory (mandatory)"
    echo "  --framework <framework> Framework to use (react, vue, svelte, preact, solid)"
    echo "  --lang <language>       Language to use (js, ts)"
    echo ""
    echo "Options:"
    echo "  --start                Automatically start the development server"
    echo "  --dir <path>           Custom directory for project creation (default: current directory)"
    echo "  --pm <package-manager> Package manager to use (npm, yarn, pnpm; default: npm)"
    echo "  --help                 Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 my-project --framework react --lang ts --start"
    echo "  $0 my-app --framework vue --lang js --pm yarn --dir ~/projects"
    exit 1
}

# Function to validate command existence
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is not installed. Please install it and try again."
        exit 1
    fi
}

# Function to validate project directory
check_project_dir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        echo "Directory $dir already exists."
        read -p "Do you want to overwrite it? (y/N) " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm -rf "$dir" || { echo "Error: Failed to remove existing directory"; exit 1; }
        else
            echo "Aborting project creation."
            exit 1
        fi
    fi
}

# Default values
PACKAGE_MANAGER="npm"
PROJECT_DIR="$(pwd)"
START_SERVER=false

# Parse arguments
PROJECT_NAME=""
FRAMEWORK=""
LANGUAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --framework)
            FRAMEWORK="$2"
            shift 2
            ;;
        --lang)
            LANGUAGE="$2"
            shift 2
            ;;
        --dir)
            PROJECT_DIR="$2"
            shift 2
            ;;
        --pm)
            PACKAGE_MANAGER="$2"
            shift 2
            ;;
        --start)
            START_SERVER=true
            shift
            ;;
        --help)
            show_help
            ;;
        -*)
            echo "Error: Unknown option $1"
            show_help
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
            else
                echo "Error: Multiple project names provided"
                show_help
            fi
            shift
            ;;
    esac
done

# Validate mandatory arguments
if [ -z "$PROJECT_NAME" ]; then
    echo "Error: Project name is required"
    show_help
fi

if [ -z "$FRAMEWORK" ]; then
    echo "Error: --framework is required"
    show_help
fi

if [ -z "$LANGUAGE" ]; then
    echo "Error: --lang is required"
    show_help
fi

# Validate framework
case "$FRAMEWORK" in
    react|vue|svelte|preact|solid)
        ;;
    *)
        echo "Error: Unsupported framework '$FRAMEWORK'. Supported: react, vue, svelte, preact, solid"
        exit 1
        ;;
esac

# Validate language
case "$LANGUAGE" in
    js|ts)
        ;;
    *)
        echo "Error: Unsupported language '$LANGUAGE'. Supported: js, ts"
        exit 1
        ;;
esac

# Validate package manager
case "$PACKAGE_MANAGER" in
    npm|yarn|pnpm)
        ;;
    *)
        echo "Error: Unsupported package manager '$PACKAGE_MANAGER'. Supported: npm, yarn, pnpm"
        exit 1
        ;;
esac

# Check for Node.js
check_command node

# Check for package manager
check_command "$PACKAGE_MANAGER"

# Construct full project path
FULL_PROJECT_PATH="$PROJECT_DIR/$PROJECT_NAME"

# Check if project directory already exists
check_project_dir "$FULL_PROJECT_PATH"

# Create project
echo "Creating project '$PROJECT_NAME' with $FRAMEWORK ($LANGUAGE) using $PACKAGE_MANAGER..."

# Map language to Vite template suffix
if [ "$LANGUAGE" = "ts" ]; then
    VITE_TEMPLATE="$FRAMEWORK-$LANGUAGE"
else
    VITE_TEMPLATE="$FRAMEWORK"
fi

# Run Vite create command
case "$PACKAGE_MANAGER" in
    npm)
        npm create vite@latest "$PROJECT_NAME" -- --template "$VITE_TEMPLATE" --yes || {
            echo "Error: Failed to create project with Vite"
            exit 1
        }
        ;;
    yarn)
        yarn create vite "$PROJECT_NAME" --template "$VITE_TEMPLATE" || {
            echo "Error: Failed to create project with Vite"
            exit 1
        }
        ;;
    pnpm)
        pnpm create vite "$PROJECT_NAME" --template "$VITE_TEMPLATE" || {
            echo "Error: Failed to create project with Vite"
            exit 1
        }
        ;;
esac

# Move project to custom directory if specified
if [ "$PROJECT_DIR" != "$(pwd)" ]; then
    mv "$PROJECT_NAME" "$FULL_PROJECT_PATH" || {
        echo "Error: Failed to move project to $PROJECT_DIR"
        exit 1
    }
fi

# Navigate to project directory
cd "$FULL_PROJECT_PATH" || {
    echo "Error: Failed to navigate to project directory"
    exit 1
}

# Install dependencies
echo "Installing dependencies..."
case "$PACKAGE_MANAGER" in
    npm)
        npm install || {
            echo "Error: Failed to install dependencies"
            exit 1
        }
        ;;
    yarn)
        yarn install || {
            echo "Error: Failed to install dependencies"
            exit 1
        }
        ;;
    pnpm)
        pnpm install || {
            echo "Error: Failed to install dependencies"
            exit 1
        }
        ;;
esac

# Display project structure
echo "Project created successfully at $FULL_PROJECT_PATH"
echo "Project structure:"
tree -L 2 || ls -l

# Start development server if requested
if [ "$START_SERVER" = true ]; then
    echo "Starting development server..."
    case "$PACKAGE_MANAGER" in
        npm)
            npm run dev &
            ;;
        yarn)
            yarn dev &
            ;;
        pnpm)
            pnpm dev &
            ;;
    esac
    echo "Development server started. Check your terminal for the server URL."
else
    echo "To start the development server, run:"
    echo "  cd $FULL_PROJECT_PATH"
    echo "  $PACKAGE_MANAGER run dev"
fi

# Post-setup instructions
echo ""
echo "Project setup complete!"
echo "Summary:"
echo "  Project Name: $PROJECT_NAME"
echo "  Framework: $FRAMEWORK"
echo "  Language: $LANGUAGE"
echo "  Package Manager: $PACKAGE_MANAGER"
echo "  Location: $FULL_PROJECT_PATH"
echo ""
echo "Next steps:"
echo "  Navigate to the project: cd $FULL_PROJECT_PATH"
echo "  Start the server (if not already running): $PACKAGE_MANAGER run dev"
echo "  Build for production: $PACKAGE_MANAGER run build"
echo "  Preview production build: $PACKAGE_MANAGER run preview"

exit 0