#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options for creating a new project:"
    echo "  --name,-n <project-name>     Name of the project directory"
    echo "  --package,-p <package-name>  Package name (e.g., com.example.demo)"
    echo "  --dir,-d <path>             Custom directory for project creation (default: current directory)"
    echo "  --java,-j <version>         Java version to use (e.g., 17, 21, default: 17)"
    echo "  --build,-b <tool>           Build tool to use (maven, gradle; default: maven)"
    echo "  --dependencies,-dep <list>  Comma-separated Spring Boot dependencies (e.g., web,devtools)"
    echo "  --start,-s                  Attempt to start the development server using wrapper"
    echo "  --open-vscode               Open the project in VS Code"
    echo ""
    echo "Options for adding dependencies to an existing project:"
    echo "  --dependencies,-dep <list>  Add dependencies to the current project's pom.xml"
    echo ""
    echo "Other options:"
    echo "  --help,-h                   Display this help message"
    echo ""
    echo "Examples:"
    echo "  Create a new project: $0 --name my-project --package com.example.myapp --start"
    echo "  Create with custom options: $0 -n my-app -p com.example.app -j 21 -b gradle -dep web,devtools -d ~/projects --open-vscode"
    echo "  Add dependencies to existing project: $0 --dependencies security,actuator"
    echo "  Interactive mode: $0"
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

# Function to check if the current directory is a Spring Boot project
is_spring_boot_project() {
    if [ -f "pom.xml" ]; then
        return 0
    else
        return 1
    fi
}

# Function to add dependencies to an existing pom.xml
add_dependencies_to_pom() {
    local dependencies="$1"
    local pom_file="pom.xml"
    if [ ! -f "$pom_file" ]; then
        echo "Error: pom.xml not found in the current directory."
        exit 1
    fi

    # Split dependencies by comma
    IFS=',' read -ra deps <<< "$dependencies"
    for dep in "${deps[@]}"; do
        dep_artifact="spring-boot-starter-$dep"
        # Check if the dependency already exists
        if grep -q "<artifactId>$dep_artifact</artifactId>" "$pom_file"; then
            echo "Dependency '$dep' already exists in pom.xml."
        else
            # Add the dependency before the closing </dependencies> tag
            sed -i "/<\/dependencies>/i \        <dependency>\n            <groupId>org.springframework.boot</groupId>\n            <artifactId>$dep_artifact</artifactId>\n        </dependency>" "$pom_file"
            echo "Added dependency: $dep"
        fi
    done
}

# Function to create a new Spring Boot project
create_new_project() {
    local project_name="$1"
    local package_name="$2"
    local java_version="$3"
    local dependencies="$4"
    local project_dir="$5"
    local build_tool="$6"

    # Validate package name format
    if ! echo "$package_name" | grep -qE '^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$'; then
        echo "Error: Invalid package name format. Use format like 'com.example.demo'"
        exit 1
    fi

    # Validate build tool
    case "$build_tool" in
        maven|gradle)
            ;;
        *)
            echo "Error: Unsupported build tool '$build_tool'. Supported: maven, gradle"
            exit 1
            ;;
    esac

    # Validate Java version
    case "$java_version" in
        17|21)
            ;;
        *)
            echo "Error: Unsupported Java version '$java_version'. Supported: 17, 21"
            exit 1
            ;;
    esac

    # Check for required commands
    check_command java
    check_command curl
    check_command unzip

    # Construct full project path
    local full_project_path="$project_dir/$project_name"

    # Check if project directory already exists
    check_project_dir "$full_project_path"

    # Create project using Spring Initializr API
    echo "Creating Spring Boot project '$project_name' with package '$package_name' using $build_tool..."

    SPRING_URL="https://start.spring.io/starter.zip"
    SPRING_URL="$SPRING_URL?type=$build_tool-project"
    SPRING_URL="$SPRING_URL&language=java"
    SPRING_URL="$SPRING_URL&javaVersion=$java_version"
    SPRING_URL="$SPRING_URL&packaging=jar"
    SPRING_URL="$SPRING_URL&groupId=$package_name"
    SPRING_URL="$SPRING_URL&artifactId=$project_name"
    SPRING_URL="$SPRING_URL&name=$project_name"
    SPRING_URL="$SPRING_URL&version=0.0.1-SNAPSHOT"
    SPRING_URL="$SPRING_URL&packageName=$package_name"
    SPRING_URL="$SPRING_URL&dependencies=$dependencies"

    # Download and unzip the project
    curl -s -o temp.zip "$SPRING_URL" || {
        echo "Error: Failed to download project from Spring Initializr"
        exit 1
    }
    mkdir -p "$full_project_path"
    unzip -q temp.zip -d "$full_project_path" || {
        echo "Error: Failed to unzip project"
        rm temp.zip
        exit 1
    }
    rm temp.zip

    # Navigate to project directory
    cd "$full_project_path" || {
        echo "Error: Failed to navigate to project directory"
        exit 1
    }

    # Create .gitignore
    cat > .gitignore << 'EOL'
target/
*.class
*.log
*.iml
.idea/
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar
.mvn/
.gradle/
build/
EOL

    # Create README.md
    cat > README.md << EOL
# $project_name

A Spring Boot project created with \`$0\`.

## Setup
- **Java Version**: $java_version
- **Build Tool**: $build_tool
- **Dependencies**: $dependencies
- **Package**: $package_name

## Prerequisites
- Ensure Java $java_version is installed.
- No need to install Maven or Gradle; the project includes a wrapper.

## Getting Started
1. Navigate to the project: \`cd $full_project_path\`
2. Run the application:
   - For Maven: \`./mvnw spring-boot:run\`
   - For Gradle: \`./gradlew bootRun\`
3. Access the application at: \`http://localhost:8080\`

## Build
- For Maven: \`./mvnw clean install\`
- For Gradle: \`./gradlew build\`

## VS Code
- Open the project in VS Code: \`code .\`
- Install the **Java Extension Pack** and **Spring Boot Extension Pack** for optimal development.
EOL

    # Make build scripts executable (for Gradle)
    if [ "$build_tool" = "gradle" ]; then
        chmod +x gradlew
    fi
}

# Default values
BUILD_TOOL="maven"
JAVA_VERSION="17"
PROJECT_DIR="$(pwd)"
START_SERVER=false
OPEN_VSCODE=false
DEPENDENCIES=""
PROJECT_NAME=""
PACKAGE_NAME=""

# Interactive mode if no arguments provided
if [ $# -eq 0 ]; then
    echo "No flags provided. Entering interactive mode to create a new Spring Boot project."
    read -p "Project name: " PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]; then
        echo "Error: Project name is required"
        exit 1
    fi
    read -p "Package name (e.g., com.example.demo): " PACKAGE_NAME
    if [ -z "$PACKAGE_NAME" ]; then
        echo "Error: Package name is required"
        exit 1
    fi
    read -p "Java version (default: 17): " JAVA_VERSION
    if [ -z "$JAVA_VERSION" ]; then JAVA_VERSION=17; fi
    read -p "Build tool (maven/gradle, default: maven): " BUILD_TOOL
    if [ -z "$BUILD_TOOL" ]; then BUILD_TOOL=maven; fi
    read -p "Dependencies (comma-separated, e.g., web,devtools, default: web): " DEPENDENCIES
    if [ -z "$DEPENDENCIES" ]; then DEPENDENCIES=web; fi
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name|-n)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$2"
                shift 2
            else
                echo "Error: Multiple project names provided"
                show_help
            fi
            ;;
        --package|-p)
            if [ -z "$PACKAGE_NAME" ]; then
                PACKAGE_NAME="$2"
                shift 2
            else
                echo "Error: Multiple package names provided"
                show_help
            fi
            ;;
        --dir|-d)
            PROJECT_DIR="$2"
            shift 2
            ;;
        --java|-j)
            JAVA_VERSION="$2"
            shift 2
            ;;
        --build|-b)
            BUILD_TOOL="$2"
            shift 2
            ;;
        --dependencies|-dep)
            DEPENDENCIES="$2"
            shift 2
            ;;
        --start|-s)
            START_SERVER=true
            shift
            ;;
        --open-vscode)
            OPEN_VSCODE=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        --get-cd-command)
            echo "cd $2/$3"
            exit 0
            ;;
        -*)
            echo "Error: Unknown option $1"
            show_help
            ;;
    esac
done

# Main logic
if is_spring_boot_project; then
    # Inside a Spring Boot project directory
    if [ -n "$DEPENDENCIES" ]; then
        add_dependencies_to_pom "$DEPENDENCIES"
        echo "Dependencies added successfully to the existing project."
    else
        echo "Error: Please specify dependencies to add using --dependencies or -dep."
        show_help
    fi
else
    # Not in a Spring Boot project directory
    if [ -n "$PROJECT_NAME" ] && [ -n "$PACKAGE_NAME" ]; then
        # Directly create a new project if --name and --package are provided
        create_new_project "$PROJECT_NAME" "$PACKAGE_NAME" "$JAVA_VERSION" "$DEPENDENCIES" "$PROJECT_DIR" "$BUILD_TOOL"
        echo "New Spring Boot project '$PROJECT_NAME' created successfully."
        if [ "$OPEN_VSCODE" = true ]; then
            if command -v code &> /dev/null; then
                cd "$PROJECT_DIR/$PROJECT_NAME" || exit
                code .
                echo "Opening project in VS Code..."
            else
                echo "Warning: VS Code is not installed. Please open the project manually."
            fi
        fi
        if [ "$START_SERVER" = true ]; then
            cd "$PROJECT_DIR/$PROJECT_NAME" || exit
            echo "Starting development server using wrapper..."
            if [ "$BUILD_TOOL" = "maven" ]; then
                ./mvnw spring-boot:run &
            else
                ./gradlew bootRun &
            fi
            echo "Development server started. Access it at http://localhost:8080"
        fi
        # Post-setup instructions
        echo ""
        echo "Spring Boot project setup complete!"
        echo "Summary:"
        echo "  Project Name: $PROJECT_NAME"
        echo "  Package Name: $PACKAGE_NAME"
        echo "  Java Version: $JAVA_VERSION"
        echo "  Build Tool: $BUILD_TOOL"
        echo "  Dependencies: $DEPENDENCIES"
        echo "  Location: $PROJECT_DIR/$PROJECT_NAME"
        echo ""
        echo "Next steps:"
        echo "  Navigate to the project: cd $PROJECT_DIR/$PROJECT_NAME"
        echo "  Start the server (if not already running):"
        if [ "$BUILD_TOOL" = "maven" ]; then
            echo "    ./mvnw spring-boot:run"
        else
            echo "    ./gradlew bootRun"
        fi
        echo "  Build the project:"
        if [ "$BUILD_TOOL" = "maven" ]; then
            echo "    ./mvnw clean install"
        else
            echo "    ./gradlew build"
        fi
        echo "  Access the application: http://localhost:8080"
        echo ""
        echo "To open in VS Code:"
        echo "  code $PROJECT_DIR/$PROJECT_NAME"
        echo ""
        echo "To navigate to the project directory, run:"
        echo "  cd $PROJECT_DIR/$PROJECT_NAME"
        echo "Or execute this to navigate automatically:"
        echo "  eval \$(bash $0 --get-cd-command \"$PROJECT_NAME\" \"$PROJECT_DIR\")"
    elif [ -n "$DEPENDENCIES" ]; then
        # Prompt if only --dependencies is provided
        read -p "You are not in a Spring Boot project directory. Do you want to create a new project with these dependencies? (y/N) " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            read -p "Enter project name: " PROJECT_NAME
            if [ -z "$PROJECT_NAME" ]; then
                echo "Error: Project name is required"
                exit 1
            fi
            read -p "Enter package name (e.g., com.example.demo): " PACKAGE_NAME
            if [ -z "$PACKAGE_NAME" ]; then
                echo "Error: Package name is required"
                exit 1
            fi
            create_new_project "$PROJECT_NAME" "$PACKAGE_NAME" "$JAVA_VERSION" "$DEPENDENCIES" "$PROJECT_DIR" "$BUILD_TOOL"
            echo "New Spring Boot project '$PROJECT_NAME' created successfully."
            if [ "$OPEN_VSCODE" = true ]; then
                if command -v code &> /dev/null; then
                    cd "$PROJECT_DIR/$PROJECT_NAME" || exit
                    code .
                    echo "Opening project in VS Code..."
                else
                    echo "Warning: VS Code is not installed. Please open the project manually."
                fi
            fi
            if [ "$START_SERVER" = true ]; then
                cd "$PROJECT_DIR/$PROJECT_NAME" || exit
                echo "Starting development server using wrapper..."
                if [ "$BUILD_TOOL" = "maven" ]; then
                    ./mvnw spring-boot:run &
                else
                    ./gradlew bootRun &
                fi
                echo "Development server started. Access it at http://localhost:8080"
            fi
            # Post-setup instructions
            echo ""
            echo "Spring Boot project setup complete!"
            echo "Summary:"
            echo "  Project Name: $PROJECT_NAME"
            echo "  Package Name: $PACKAGE_NAME"
            echo "  Java Version: $JAVA_VERSION"
            echo "  Build Tool: $BUILD_TOOL"
            echo "  Dependencies: $DEPENDENCIES"
            echo "  Location: $PROJECT_DIR/$PROJECT_NAME"
            echo ""
            echo "Next steps:"
            echo "  Navigate to the project: cd $PROJECT_DIR/$PROJECT_NAME"
            echo "  Start the server (if not already running):"
            if [ "$BUILD_TOOL" = "maven" ]; then
                echo "    ./mvnw spring-boot:run"
            else
                echo "    ./gradlew bootRun"
            fi
            echo "  Build the project:"
            if [ "$BUILD_TOOL" = "maven" ]; then
                echo "    ./mvnw clean install"
            else
                echo "    ./gradlew build"
            fi
            echo "  Access the application: http://localhost:8080"
            echo ""
            echo "To open in VS Code:"
            echo "  code $PROJECT_DIR/$PROJECT_NAME"
            echo ""
            echo "To navigate to the project directory, run:"
            echo "  cd $PROJECT_DIR/$PROJECT_NAME"
            echo "Or execute this to navigate automatically:"
            echo "  eval \$(bash $0 --get-cd-command \"$PROJECT_NAME\" \"$PROJECT_DIR\")"
        else
            echo "Aborting. No project created or modified."
            exit 0
        fi
    else
        echo "Error: No action specified. Use --name and --package to create a new project, or --dependencies to add dependencies."
        show_help
    fi
fi

exit 0