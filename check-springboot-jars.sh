#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --dir,-d <path>        Directory containing the Spring Boot project (default: current directory)"
    echo "  --help,-h              Display this help message"
    echo ""
    echo "Examples:"
    echo "  Check JARs in current directory: $0"
    echo "  Check JARs in specific directory: $0 --dir /path/to/project"
    echo "  Show help: $0 --help"
    exit 1
}

# Function to validate command existence
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is not installed. Please install it and try again."
        exit 1
    fi
}

# Function to check if the directory is a Spring Boot project
is_spring_boot_project() {
    local dir="$1"
    if [ -f "$dir/pom.xml" ]; then
        return 0
    else
        return 1
    fi
}

# Function to get the local Maven repository path
get_maven_local_repo() {
    local home_dir="$HOME"
    local maven_repo="$home_dir/.m2/repository"
    if [ ! -d "$maven_repo" ]; then
        echo "Warning: Local Maven repository not found at $maven_repo. Checking target directory only."
        echo ""
    else
        echo "$maven_repo"
    fi
}

# Function to check for missing JAR files
check_missing_jars() {
    local pom_file="$1"
    local project_dir="$2"
    local maven_repo="$3"
    local missing_jars=()

    # Parse dependencies from pom.xml using xmlstarlet
    local deps
    deps=$(xmlstarlet sel -N x="http://maven.apache.org/POM/4.0.0" -t -m "//x:dependency" \
        -v "concat(x:groupId,'|',x:artifactId,'|',x:version)" -n "$pom_file" 2>/dev/null)

    if [ -z "$deps" ]; then
        echo "No dependencies found in pom.xml."
        return
    fi

    while IFS='|' read -r group_id artifact_id version; do
        if [ -z "$group_id" ] || [ -z "$artifact_id" ] || [ -z "$version" ]; then
            echo "Skipping incomplete dependency: groupId=$group_id, artifactId=$artifact_id, version=$version"
            continue
        fi

        # Construct JAR file path in local Maven repository
        local group_path
        group_path=$(echo "$group_id" | tr '.' '/')
        local jar_path="$maven_repo/$group_path/$artifact_id/$version/$artifact_id-$version.jar"

        # Check if JAR exists in Maven repository
        if [ -n "$maven_repo" ] && [ -f "$jar_path" ]; then
            continue
        fi

        # Check if JAR exists in target directory
        local target_jar="$project_dir/target/$artifact_id-$version.jar"
        if [ -f "$target_jar" ]; then
            continue
        fi

        # JAR is missing
        missing_jars+=("$group_id:$artifact_id:$version")
    done <<< "$deps"

    # Output results
    if [ ${#missing_jars[@]} -eq 0 ]; then
        echo "All JAR files for dependencies in pom.xml are present."
    else
        echo "Missing JAR files for the following dependencies:"
        for jar in "${missing_jars[@]}"; do
            echo "  - $jar"
        done
        echo ""
        read -p "Do you want to install missing JARs using Maven wrapper? (y/N) " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            if [ -f "$project_dir/mvnw" ]; then
                echo "Running Maven wrapper to install dependencies..."
                cd "$project_dir" || { echo "Error: Failed to navigate to project directory"; exit 1; }
                ./mvnw clean install || { echo "Error: Maven install failed"; exit 1; }
                echo "Dependencies installed successfully."
            else
                echo "Error: Maven wrapper (mvnw) not found in $project_dir."
                echo "Alternatively, you can regenerate the project with these dependencies at https://start.spring.io."
                echo "Select the same project settings and include the following dependencies:"
                for jar in "${missing_jars[@]}"; do
                    echo "  - $(echo "$jar" | cut -d':' -f2)"
                done
                exit 1
            fi
        else
            echo "Alternatively, you can regenerate the project with these dependencies at https://start.spring.io."
            echo "Select the same project settings and include the following dependencies:"
            for jar in "${missing_jars[@]}"; do
                echo "  - $(echo "$jar" | cut -d':' -f2)"
            done
            echo "Aborting. No dependencies installed."
            exit 0
        fi
    fi
}

# Default values
PROJECT_DIR="$(pwd)"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dir|-d)
            PROJECT_DIR="$2"
            shift 2
            ;;
        --help|-h)
            show_help
            ;;
        -*)
            echo "Error: Unknown option $1"
            show_help
            ;;
    esac
done

# Check for required commands
check_command java
check_command xmlstarlet

# Validate project directory
if ! is_spring_boot_project "$PROJECT_DIR"; then
    echo "Error: No pom.xml found in $PROJECT_DIR. This is not a Spring Boot project directory."
    exit 1
fi

# Get Maven local repository path
MAVEN_REPO=$(get_maven_local_repo)

# Check for missing JARs
check_missing_jars "$PROJECT_DIR/pom.xml" "$PROJECT_DIR" "$MAVEN_REPO"

exit 0