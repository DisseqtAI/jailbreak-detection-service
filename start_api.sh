#!/bin/bash

# Color codes for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}   Starting Jailbreak Detector API Server  ${NC}"
echo -e "${GREEN}=========================================${NC}\n"

# Define the full path to Python in the virtual environment
PYTHON_PATH="$(pwd)/env/bin/python"
PIP_PATH="$(pwd)/env/bin/pip"

# Deactivate any existing virtual environment first
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo -e "${YELLOW}⚠️  Deactivating current virtual environment...${NC}"
    deactivate 2>/dev/null || true
fi

# Check if virtual environment exists, create if not
if [ ! -d "env" ]; then
    echo -e "${YELLOW}⚠️  Creating new Python virtual environment...${NC}"
    python3 -m venv env
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to create virtual environment. Please ensure python3-venv is installed.${NC}"
        exit 1
    fi
fi

# Activate the virtual environment using absolute path
ENV_ACTIVATE="$(pwd)/env/bin/activate"
echo -e "${YELLOW}⚠️  Activating Python virtual environment...${NC}"
if [ -f "$ENV_ACTIVATE" ]; then
    source "$ENV_ACTIVATE"
    
    # Verify Python exists in the virtual environment
    if [ ! -f "$PYTHON_PATH" ]; then
        echo -e "${RED}❌ Python executable not found at $PYTHON_PATH${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Virtual environment activated${NC}"
else
    echo -e "${RED}❌ Virtual environment activation script not found at $ENV_ACTIVATE${NC}"
    exit 1
fi

# Check if packages are installed
echo -e "${YELLOW}⚠️  Checking for required packages...${NC}"
if ! "$PYTHON_PATH" -c "import uvicorn" &> /dev/null; then
    echo -e "${YELLOW}⚠️  Installing required packages...${NC}"
    
    # Ensure pip is up to date in the virtual environment
    "$PYTHON_PATH" -m pip install --upgrade pip
    
    # Install packages
    "$PYTHON_PATH" -m pip install -r requirements.txt
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to install required packages. Check requirements.txt and try again.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Required packages installed${NC}"
fi

# Set environment variables
export LOG_LEVEL="info"
export MAX_WORKERS=2  # Using 2 workers for balance

echo -e "${BLUE}🔧 Configuration:${NC}"
echo -e "  - Host: 0.0.0.0"
echo -e "  - Port: 8000"
echo -e "  - Log level: $LOG_LEVEL"
echo -e "  - Workers: $MAX_WORKERS\n"

# Start the API server
echo -e "${GREEN}🚀 Starting FastAPI server at http://localhost:8000${NC}"
echo -e "${YELLOW}👉 Use Ctrl+C to stop the server${NC}\n"

# Run the server with uvicorn using the virtual environment's Python
"$PYTHON_PATH" -m uvicorn api:app --host 0.0.0.0 --port 8000 --workers $MAX_WORKERS 