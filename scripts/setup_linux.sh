#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Version
VERSION="1.0.0"

# Source conda utilities
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$SCRIPT_DIR/conda_utils.sh"

# Total number of stages
TOTAL_STAGES=6
CURRENT_STAGE=0
STAGE_NAME=""

# Trap ctrl-c and call cleanup
trap cleanup INT

# Cleanup function to restore terminal settings
cleanup() {
    echo -e "\n${YELLOW}Setup interrupted.${NC}"
    exit 1
}

# Log a message to the console
log() {
    local message="$1"
    local level="${2:-INFO}"
    local color="${NC}"
    
    case $level in
        INFO) color="${BLUE}" ;; 
        SUCCESS) color="${GREEN}" ;; 
        WARNING) color="${YELLOW}" ;; 
        ERROR) color="${RED}" ;; 
        DEBUG) color="${GRAY}" ;; 
    esac
    
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] ${message}${NC}"
}

# Get current timestamp
get_timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# Print formatted log messages
log_info() {
    log "$1" "INFO"
}

log_success() {
    log "$1" "SUCCESS"
}

log_warning() {
    log "$1" "WARNING"
}

log_error() {
    log "$1" "ERROR"
}

log_step() {
    echo -e "\n${GRAY}[$(get_timestamp)]${NC} ${BLUE}[STEP]${NC}    ${BOLD}$1${NC}"
}

log_debug() {
    if [[ "${DEBUG}" == "true" ]]; then
        log "$1" "DEBUG"
    fi
}

log_section() {
    echo -e "\n${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════════════${NC}\n"
}

# Display title and logo
display_header() {
    local title="$1"
    
    echo ""
    echo -e "${CYAN}"
    echo ' ███████╗███████╗ ██████╗ ██████╗ ███╗   ██╗██████╗       ███╗   ███╗███████╗'
    echo ' ██╔════╝██╔════╝██╔════╝██╔═══██╗████╗  ██║██╔══██╗      ████╗ ████║██╔════╝'
    echo ' ███████╗█████╗  ██║     ██║   ██║██╔██╗ ██║██║  ██║█████╗██╔████╔██║█████╗  '
    echo ' ╚════██║██╔══╝  ██║     ██║   ██║██║╚██╗██║██║  ██║╚════╝██║╚██╔╝██║██╔══╝  '
    echo ' ███████║███████╗╚██████╗╚██████╔╝██║ ╚████║██████╔╝      ██║ ╚═╝ ██║███████╗'
    echo ' ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝       ╚═╝     ╚═╝╚══════╝'
    echo -e "${NC}"
    echo -e "${BOLD}Second-Me Setup Script v${VERSION} (Linux Edition)${NC}"
    echo -e "${GRAY}$(date)${NC}\n"
    
    if [ -n "$title" ]; then
        echo -e "${CYAN}====== $title ======${NC}"
        echo ""
    fi
}

# Display stage start
display_stage() {
    local stage_num=$1
    local stage_name=$2
    CURRENT_STAGE=$stage_num
    STAGE_NAME=$stage_name
    
    echo ""
    echo -e "${CYAN}====== Stage $stage_num/$TOTAL_STAGES: $stage_name ======${NC}"
    echo ""
}

# Get conda environment name from .env file
get_conda_env_name() {
    if [[ -f ".env" ]]; then
        local env_name=$(grep '^CONDA_DEFAULT_ENV=' .env | cut -d '=' -f2)
        if [[ -n "$env_name" ]]; then
            echo "$env_name"
            return 0
        fi
    fi
    echo "second-me"  
    return 0
}

# Check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        return 1
    fi
    return 0
}

# Install packages using apt-get
install_apt_packages() {
    log_step "Checking and installing required packages with apt-get"
    
    sudo apt-get update
    
    local required_packages=(
        "sqlite3"
        "make"
        "cmake"
        "nodejs"
        "npm"
    )
    
    for package in "${required_packages[@]}"; do
        if ! dpkg -l | grep -q " $package "; then
            log_warning "Installing $package..."
            if ! sudo apt-get install -y $package; then
                log_error "Failed to install $package"
                return 1
            fi
        fi
    done
    
    log_success "All required packages are installed"
    return 0
}

# Install conda
install_conda() {
    log_info "Installing Miniconda..."
    
    MINICONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
    wget "https://repo.anaconda.com/miniconda/${MINICONDA_INSTALLER}" -O "${MINICONDA_INSTALLER}"
    bash "${MINICONDA_INSTALLER}" -b -p "$HOME/miniconda"
    rm "${MINICONDA_INSTALLER}"
    
    eval "$($HOME/miniconda/bin/conda shell.bash hook)"
    conda init
    
    log_success "Conda installed and initialized successfully"
    return 0
}

# Activate Python environment
activate_python_env() {
    log_section "PYTHON ENVIRONMENT ACTIVATION"
    
    # 1. Check conda installation
    log_step "Checking conda installation"
    if ! command -v conda &> /dev/null; then
        log_info "Conda not found, installing..."
        if ! install_conda; then
            log_error "Failed to install Conda."
            return 1
        fi
    fi
    
    # 2. Get environment name
    local env_name
    if ! env_name=$(get_conda_env_name); then
        log_error "Could not get conda environment name"
        return 1
    fi
    
    # 3. Activate environment
    log_step "Activating conda environment: $env_name"
    
    if conda env list | grep -q "^${env_name} "; then
        log_info "Environment exists, updating dependencies..."
        if ! conda env update -f environment.yml -n "$env_name"; then
            log_error "Failed to update conda environment"
            return 1
        fi
    else
        log_info "Creating new environment... $env_name"
        if ! conda env create -f environment.yml -n "$env_name"; then
            log_error "Failed to create conda environment $env_name"
            return 1
        fi
    fi
    
    eval "$(conda shell.bash hook)"
    conda activate "$env_name"
    
    log_success "Successfully activated conda environment: $env_name"
    
    # 4. Install Python packages using Poetry
    log_step "Installing Python packages using Poetry"
    
    if [ ! -f "pyproject.toml" ]; then
        log_error "Missing pyproject.toml file"
        return 1
    fi
    
    log_info "Updating Poetry lockfile..."
    if ! poetry lock --no-cache; then
        log_error "Failed to update Poetry lockfile"
        return 1
    fi
    
    log_info "Using Poetry to install dependencies..."
    if ! poetry install --no-root --no-interaction; then
        log_error "Failed to install dependencies using Poetry"
        return 1
    fi
    
    log_info "Verifying key packages..."
    local required_packages=("flask" "chromadb" "langchain")
    for pkg in "${required_packages[@]}"; do
        if ! python -c "import $pkg" 2>/dev/null; then
            log_error "Package '$pkg' is not installed correctly"
            return 1
        else
            log_info "Package '$pkg' is installed correctly"
        fi
    done

    log_step "Checking graphrag version"
    GRAPHRAG_VERSION=$(pip show graphrag 2>/dev/null | grep "Version:" | cut -d " " -f2)
    GRAPHRAG_TARGET="1.2.1.dev27"
    GRAPHRAG_LOCAL_PATH="dependencies/graphrag-${GRAPHRAG_TARGET}.tar.gz"
    
    if [ "$GRAPHRAG_VERSION" != "$GRAPHRAG_TARGET" ]; then
        log_info "Installing correct version of graphrag..."
        if [ -f "$GRAPHRAG_LOCAL_PATH" ]; then
            log_info "Installing graphrag from local file..."
            if ! pip install --force-reinstall "$GRAPHRAG_LOCAL_PATH"; then
                log_error "Failed to install graphrag from local file"
                return 1
            fi
        else
            log_error "Local graphrag package not found at: $GRAPHRAG_LOCAL_PATH"
            return 1
        fi
        log_success "Graphrag installed successfully"
    else
        log_success "Graphrag version is correct, skipping installation"
    fi
    
    log_success "Python environment setup completed"
    return 0
}

# Build llama.cpp
build_llama() {
    log_section "BUILDING LLAMA.CPP"
    
    LLAMA_LOCAL_ZIP="dependencies/llama.cpp.zip"
    
    if [ ! -d "llama.cpp" ]; then
        log_info "Setting up llama.cpp..."
        
        if [ -f "$LLAMA_LOCAL_ZIP" ]; then
            log_info "Using local llama.cpp archive..."
            if ! unzip -q "$LLAMA_LOCAL_ZIP"; then
                log_error "Failed to extract local llama.cpp archive"
                return 1
            fi
        else
            log_error "Local llama.cpp archive not found at: $LLAMA_LOCAL_ZIP"
            return 1
        fi
    else
        log_info "Found existing llama.cpp directory"
    fi
    
    if [ -f "llama.cpp/build/bin/llama-server" ]; then
        log_info "Found existing llama-server build, skipping compilation"
        return 0
    fi
    
    cd llama.cpp
    
    if [ -d "build" ]; then
        log_info "Cleaning previous build..."
        rm -rf build
    fi
    
    log_info "Creating build directory..."
    mkdir -p build && cd build
    
    log_info "Configuring CMake..."
    if ! cmake ..; then
        log_error "CMake configuration failed"
        cd ../..
        return 1
    fi
    
    log_info "Building project..."
    if ! cmake --build . --config Release; then
        log_error "Build failed"
        cd ../..
        return 1
    fi
    
    if [ ! -f "bin/llama-server" ]; then
        log_error "Build failed: llama-server executable not found"
        cd ../..
        return 1
    fi
    
    log_success "Found llama-server at: bin/llama-server"
    cd ../..
    log_section "LLAMA.CPP BUILD COMPLETE"
}

# Set up frontend environment
build_frontend() {
    log_section "SETTING UP FRONTEND"
    
    FRONTEND_DIR="lpm_frontend"
    
    cd "$FRONTEND_DIR" || {
        log_error "Failed to enter frontend directory: $FRONTEND_DIR"
        return 1
    }
    
    if [ -d "node_modules" ]; then
        log_info "Found existing node_modules, skipping installation."
    else
        log_info "Installing dependencies..."
        if ! npm install; then
            log_error "Failed to install frontend dependencies"
            cd ..
            return 1
        fi
    fi
    
    log_success "Frontend dependencies installed successfully"
    cd ..
    log_section "FRONTEND SETUP COMPLETE"
}

# Main function
main() {
    display_header "Second-Me Complete Installation (Linux)"
    
    log_section "Running pre-installation checks"
    if ! install_apt_packages; then
        log_error "Dependency installation failed"
        exit 1
    fi
    
    log_section "Starting installation"
    
    if ! activate_python_env; then
        exit 1
    fi
    
    if ! build_llama; then
        exit 1
    fi
    
    if ! build_frontend; then
        exit 1
    fi

    log_success "Installation complete!"
    return 0
}

# Start execution
main "$@"
