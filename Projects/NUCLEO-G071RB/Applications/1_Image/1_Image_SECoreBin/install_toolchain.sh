#!/bin/bash
# Installation script for ARM GCC toolchain and build dependencies

echo "=========================================="
echo "STM32 Build Environment Setup"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo "Please do not run this script as root"
   exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot detect OS"
    exit 1
fi

echo "Detected OS: $OS"
echo ""

# Install ARM GCC toolchain
echo "Installing ARM GCC toolchain..."
case $OS in
    ubuntu|debian)
        sudo apt-get update
        sudo apt-get install -y gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi
        ;;
    fedora|rhel|centos)
        sudo dnf install -y arm-none-eabi-gcc-cs arm-none-eabi-binutils-cs arm-none-eabi-newlib
        ;;
    arch|manjaro)
        sudo pacman -S --needed arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-newlib
        ;;
    *)
        echo "Unsupported OS. Please install arm-none-eabi-gcc manually."
        exit 1
        ;;
esac

# Install Python 3 (if not already installed)
echo ""
echo "Checking Python 3..."
if ! command -v python3 &> /dev/null; then
    echo "Installing Python 3..."
    case $OS in
        ubuntu|debian)
            sudo apt-get install -y python3
            ;;
        fedora|rhel|centos)
            sudo dnf install -y python3
            ;;
        arch|manjaro)
            sudo pacman -S --needed python
            ;;
    esac
else
    echo "Python 3 is already installed: $(python3 --version)"
fi

# Install Make (if not already installed)
echo ""
echo "Checking Make..."
if ! command -v make &> /dev/null; then
    echo "Installing Make..."
    case $OS in
        ubuntu|debian)
            sudo apt-get install -y make
            ;;
        fedora|rhel|centos)
            sudo dnf install -y make
            ;;
        arch|manjaro)
            sudo pacman -S --needed make
            ;;
    esac
else
    echo "Make is already installed: $(make --version | head -n1)"
fi

# Verify installations
echo ""
echo "=========================================="
echo "Verifying installations..."
echo "=========================================="

if command -v arm-none-eabi-gcc &> /dev/null; then
    echo "✓ ARM GCC: $(arm-none-eabi-gcc --version | head -n1)"
else
    echo "✗ ARM GCC: NOT FOUND"
fi

if command -v python3 &> /dev/null; then
    echo "✓ Python 3: $(python3 --version)"
else
    echo "✗ Python 3: NOT FOUND"
fi

if command -v make &> /dev/null; then
    echo "✓ Make: $(make --version | head -n1)"
else
    echo "✗ Make: NOT FOUND"
fi

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="
echo ""
echo "You can now build the project with:"
echo "  cd /workspaces/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin"
echo "  make"
