#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 --name <project-name> --app <app-name> [options]"
    echo ""
    echo "Arguments:"
    echo "  --name,-n <project-name>   Name of the project directory (mandatory)"
    echo "  --app,-a <app-name>        Name of the Django app (mandatory)"
    echo ""
    echo "Options:"
    echo "  --dir,-d <path>           Custom directory for project creation (default: current directory)"
    echo "  --python,-p <version>     Python version to use (e.g., python3.10, default: python3)"
    echo "  --start,-s                Automatically start the development server"
    echo "  --help,-h                 Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --name my-project --app myapp --start"
    echo "  $0 -n my-blog -a blog -p python3.11 -d ~/projects"
    echo "Note: If --name or --app is not provided, you will be prompted to enter them."
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
PYTHON_VERSION="python"
PROJECT_DIR="$(pwd)"
START_SERVER=false
PROJECT_NAME=""
APP_NAME=""

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
        --app|-a)
            if [ -z "$APP_NAME" ]; then
                APP_NAME="$2"
                shift 2
            else
                echo "Error: Multiple app names provided"
                show_help
            fi
            ;;
        --dir|-d)
            PROJECT_DIR="$2"
            shift 2
            ;;
        --python|-p)
            PYTHON_VERSION="$2"
            shift 2
            ;;
        --start|-s)
            START_SERVER=true
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

# Prompt for project name and app name if not provided
if [ -z "$PROJECT_NAME" ]; then
    read -p "Enter project name: " PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]; then
        echo "Error: Project name is required"
        exit 1
    fi
fi

if [ -z "$APP_NAME" ]; then
    read -p "Enter app name: " APP_NAME
    if [ -z "$APP_NAME" ]; then
        echo "Error: App name is required"
        exit 1
    fi
fi

# Validate Python version
check_command "$PYTHON_VERSION"

# Check if django-admin is installed, if not, offer to install Django
if ! command -v django-admin &> /dev/null; then
    read -p "django-admin is not found. Do you want to install Django? (y/N) " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        "$PYTHON_VERSION" -m pip install django || {
            echo "Error: Failed to install Django"
            exit 1
        }
    else
        echo "Django is required. Exiting."
        exit 1
    fi
fi

# Construct full project path
FULL_PROJECT_PATH="$PROJECT_DIR/$PROJECT_NAME"

# Check if project directory already exists
check_project_dir "$FULL_PROJECT_PATH"

# Create project directory and navigate to it
mkdir -p "$FULL_PROJECT_PATH"
cd "$FULL_PROJECT_PATH" || {
    echo "Error: Failed to navigate to project directory"
    exit 1
}

# Create Django project
echo "Creating Django project '$PROJECT_NAME' with app '$APP_NAME' using $PYTHON_VERSION..."
"$PYTHON_VERSION" -m django startproject "$PROJECT_NAME" . || {
    echo "Error: Failed to create Django project"
    exit 1
}

# Create app
"$PYTHON_VERSION" manage.py startapp "$APP_NAME" || {
    echo "Error: Failed to create Django app '$APP_NAME'"
    exit 1
}

# Create static and templates directories
mkdir -p static/css static/js static/images templates/"$APP_NAME"

# Create sample static files
touch static/css/style.css
touch static/js/script.js
# mkdir static/images/

# Create sample template files
cat > templates/base.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}My Django Project{% endblock %}</title>
    <link rel="stylesheet" href="{% static 'css/style.css' %}">
</head>
<body>
    {% block content %}
    {% endblock %}
    <script src="{% static 'js/script.js' %}"></script>
</body>
</html>
EOL


# Update settings.py to include app and configure static/templates

# Add app to INSTALLED_APPS
sed -i "/INSTALLED_APPS = \[/a \    '$APP_NAME.apps.${APP_NAME^}Config'," "$PROJECT_NAME/settings.py"

# Add STATICFILES_DIRS if not already present
if ! grep -q "STATICFILES_DIRS" "$PROJECT_NAME/settings.py"; then
    sed -i "/STATIC_URL =/a STATICFILES_DIRS = [BASE_DIR / \"static\"]" "$PROJECT_NAME/settings.py"
fi

# Update TEMPLATES[0]['DIRS'] to include templates directory
if ! grep -q "'DIRS': \[[^]]*\]" "$PROJECT_NAME/settings.py"; then
    sed -i "/'DIRS': \[/c\        'DIRS': [BASE_DIR / \"templates\"]," "$PROJECT_NAME/settings.py"
else
    sed -i "s/'DIRS': \[/&BASE_DIR \/ \"templates\", /" "$PROJECT_NAME/settings.py"
fi

# Create app-specific urls.py
cat > "$APP_NAME/urls.py" << 'EOL'
from django.urls import path

# URL patterns for the app
# from . import views
# urlpatterns = [
#     path('', views.<view-function-name>, name='<unique-identifier-for-url-pattern'),
#     path('post/<int:pk>/', views.<view-function-name>, name='<unique-identifier-for-url-pattern>'),
# ]
EOL


# Create requirements.txt
cat > requirements.txt << 'EOL'
django>=4.2
EOL

# Create .gitignore
cat > .gitignore << 'EOL'
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
*.sqlite3
EOL

# Run migrations
echo "Applying migrations..."
"$PYTHON_VERSION" manage.py makemigrations || {
    echo "Error: Failed to create migrations"
    exit 1
}
"$PYTHON_VERSION" manage.py migrate || {
    echo "Error: Failed to apply migrations"
    exit 1
}

# Display project structure
echo "Project created successfully at $FULL_PROJECT_PATH"
echo "Project structure:"
tree -L 3 || ls -lR

# Start development server if requested
if [ "$START_SERVER" = true ]; then
    echo "Starting development server..."
    "$PYTHON_VERSION" manage.py runserver &
    echo "Development server started. Access it at http://127.0.0.1:8000"
else
    echo "To start the development server, run:"
    echo "  cd $FULL_PROJECT_PATH"
    echo "  $PYTHON_VERSION manage.py runserver"
fi

# Post-setup instructions
echo ""
echo "Project setup complete!"
echo "Summary:"
echo "  Project Name: $PROJECT_NAME"
echo "  App Name: $APP_NAME"
echo "  Python Version: $PYTHON_VERSION"
echo "  Location: $FULL_PROJECT_PATH"
echo ""
echo "Next steps:"
echo "  Navigate to the project: cd $FULL_PROJECT_PATH"
echo "  Start the server (if not already running): $PYTHON_VERSION manage.py runserver"
echo "  Access the admin panel: http://127.0.0.1:8000/admin (after creating a superuser)"
echo "  Create a superuser: $PYTHON_VERSION manage.py createsuperuser"
echo ""
echo "To navigate to the project directory, run:"
echo "  cd $FULL_PROJECT_PATH"
echo "Or execute this to navigate automatically:"
echo "  eval \$(bash $0 --get-cd-command \"$PROJECT_NAME\" \"$PROJECT_DIR\")"

exit 0