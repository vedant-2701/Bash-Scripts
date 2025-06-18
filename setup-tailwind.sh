#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --help                 Display this help message"
    echo ""
    echo "Description:"
    echo "  Adds Tailwind CSS to an existing Vite React project. Prompts for configuration method (Vite or PostCSS)."
    echo "  Run from the root of your Vite React project."
    echo ""
    echo "Example:"
    echo "  $0"
    exit 0
}

# Function to validate command existence
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is not installed. Please install it and try again."
        exit 1
    fi
}

# Check for help flag
while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            show_help
            ;;
        -*)
            echo "Error: Unknown option $1"
            show_help
            ;;
        *)
            shift
            ;;
    esac
done

# Check if in a Vite project
if [ ! -f "vite.config.js" ] && [ ! -f "vite.config.ts" ]; then
    echo "Error: This does not appear to be a Vite project. Please run from the project root containing vite.config.js or vite.config.ts."
    exit 1
fi

# Check for Node.js and package manager
check_command node
check_command npm

# Prompt for configuration method
echo "Choose Tailwind CSS configuration method:"
echo "1) Vite plugin (recommended for Vite projects)"
echo "2) PostCSS"
read -p "Enter choice (1 or 2): " method

echo "Installing Tailwind CSS and dependencies..."

case $method in
    1)
        CONFIG_METHOD="vite"
        npm install tailwindcss @tailwindcss/vite || {
            echo "Error: Failed to install Tailwind CSS dependencies"
            exit 1
        }
        ;;
    2)
        CONFIG_METHOD="postcss"
        npm install tailwindcss @tailwindcss/postcss postcss || {
            echo "Error: Failed to install Tailwind CSS dependencies"
            exit 1
        }
        ;;
    *)
        echo "Error: Invalid choice. Please enter vite or postcss."
        exit 1
        ;;
esac


# Initialize Tailwind CSS
echo "Initializing Tailwind CSS configuration..."


# # Configure tailwind.config.js
# echo "Configuring tailwind.config.js..."
# cat > tailwind.config.js <<EOL
# /** @type {import('tailwindcss').Config} */
# export default {
#   content: [
#     "./index.html",
#     "./src/**/*.{js,ts,jsx,tsx}",
#   ],
#   theme: {
#     extend: {},
#   },
#   plugins: [],
# }
# EOL

# Configure based on method
case $CONFIG_METHOD in
    vite)
        echo "Configuring Vite plugin..."
        # Check if vite.config.js or vite.config.ts exists and update
        VITE_CONFIG="vite.config.js"
        if [ -f "vite.config.ts" ]; then
            VITE_CONFIG="vite.config.ts"
        fi
        if ! grep -q "tailwindcss" "$VITE_CONFIG"; then
            # sed -i '/import { defineConfig } from "vite"/a import tailwindcss from "tailwindcss/vite";' "$VITE_CONFIG"
            sed -i.bak -e '/import { defineConfig } from ["'\'']vite["'\'']/a import tailwindcss from "@tailwindcss/vite";' "$VITE_CONFIG" && \
            sed -i 's/plugins: \[/plugins: [tailwindcss(),/' "$VITE_CONFIG" && \
            echo "Updated $VITE_CONFIG with Tailwind Vite plugin."
        else
            echo "Tailwind Vite plugin already configured in $VITE_CONFIG."
        fi
        ;;
    postcss)
        echo "Configuring PostCSS..."
        if [ ! -f "postcss.config.js" ]; then
            cat > postcss.config.js <<EOL
export default {
  plugins: {
    "@tailwindcss/postcss": {},
  },
}
EOL
            echo "Created postcss.config.js with Tailwind and Autoprefixer."
        else
            if ! grep -q "tailwindcss" postcss.config.js; then
                sed -i '/plugins: {/a\
    "@tailwindcss/postcss": {},' postcss.config.js
                echo "Updated postcss.config.js with Tailwind and Autoprefixer."
            else
                echo "Tailwind already configured in postcss.config.js."
            fi
        fi
        ;;
esac

# Add Tailwind directives to CSS
echo "Adding Tailwind directives to CSS..."
CSS_FILE="src/index.css"
if [ ! -f "$CSS_FILE" ]; then
    touch "$CSS_FILE"
fi
cat > "$CSS_FILE" <<EOL
@import "tailwindcss";
EOL
echo "Updated $CSS_FILE with Tailwind directives."

# Update main app file with Tailwind example
echo "Updating src/App.jsx or src/App.tsx with Tailwind example..."
MAIN_FILE="src/App.jsx"
if [ -f "src/App.tsx" ]; then
    MAIN_FILE="src/App.tsx"
fi
cat > "$MAIN_FILE" <<EOL
import React from 'react';
import './index.css';

function App() {
  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      <h1 className="text-4xl font-bold text-blue-600">
        Welcome to React with Tailwind CSS!
      </h1>
    </div>
  );
}

export default App;
EOL
echo "Updated $MAIN_FILE with a Tailwind-styled component."

# Install project dependencies if not already done
echo "Installing project dependencies..."
npm install || {
    echo "Error: Failed to install dependencies"
    exit 1
}

# Display project structure
echo "Project updated successfully at $(pwd)"
echo "Project structure:"
tree -L 2 || ls -l

# Start development server if requested
if [ -t 0 ]; then
    read -p "Do you want to start the development server? (y/N) " start_response
    if [[ "$start_response" =~ ^[Yy]$ ]]; then
        echo "Starting development server..."
        npm run dev &
        echo "Development server started. Check your terminal for the server URL."
    else
        echo "To start the development server, run:"
        echo "  npm run dev"
    fi
fi

# Post-setup instructions
echo ""
echo "Tailwind CSS setup complete!"
echo "Summary:"
echo "  Configuration Method: $CONFIG_METHOD"
echo "  Location: $(pwd)"
echo ""
echo "Next steps:"
echo "  Start the server: npm run dev"
echo "  Build for production: npm run build"
echo "  Preview production build: npm run preview"
echo "  Explore Tailwind CSS: Modify $MAIN_FILE and $CSS_FILE"

exit 0