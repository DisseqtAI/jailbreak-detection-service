#!/bin/bash

# Color codes for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print header
echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}  Jailbreak Detector Setup  ${NC}"
echo -e "${GREEN}=========================================${NC}\n"

# Define the full path to Python and pip in the virtual environment
PYTHON_PATH="$(pwd)/env/bin/python"
PIP_PATH="$(pwd)/env/bin/pip"

# Deactivate any existing virtual environment first
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo -e "${YELLOW}⚠️  Deactivating current virtual environment...${NC}"
    deactivate 2>/dev/null || true
fi

# Check if Python 3 is installed
echo -e "${YELLOW}⚠️  Checking Python installation...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed. Please install Python 3 and try again.${NC}"
    echo -e "   On macOS: brew install python3"
    exit 1
fi

python3_version=$(python3 --version | cut -d' ' -f2)
echo -e "${GREEN}✅ Using Python $python3_version${NC}"

# Make scripts executable
echo -e "${YELLOW}⚠️  Making scripts executable...${NC}"
chmod +x start_api.sh download_models.py
echo -e "${GREEN}✅ Scripts are now executable${NC}"

# Check if virtual environment exists, create if not
if [ ! -d "env" ]; then
    echo -e "${YELLOW}⚠️  Creating new Python virtual environment...${NC}"
    python3 -m venv env
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to create virtual environment.${NC}"
        echo -e "   Try installing venv package: pip3 install virtualenv${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Virtual environment created${NC}"
else
    echo -e "${GREEN}✅ Virtual environment already exists${NC}"
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

# Upgrade pip in the virtual environment
echo -e "${YELLOW}⚠️  Upgrading pip...${NC}"
"$PYTHON_PATH" -m pip install --upgrade pip
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to upgrade pip.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Pip upgraded${NC}"

# Install dependencies
echo -e "${YELLOW}⚠️  Installing required packages...${NC}"
"$PYTHON_PATH" -m pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to install required packages. Check requirements.txt and try again.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Required packages installed${NC}"

# Download models
echo -e "${YELLOW}⚠️  Downloading models...${NC}"
"$PYTHON_PATH" ./download_models.py
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to download models.${NC}"
    exit 1
fi

echo -e "\n${GREEN}✅ Setup completed successfully!${NC}"
echo -e "${BLUE}🚀 You can now run the API with: ./start_api.sh${NC}"
echo -e "${YELLOW}👉 Remember to activate the virtual environment with: source env/bin/activate${NC}\n" 