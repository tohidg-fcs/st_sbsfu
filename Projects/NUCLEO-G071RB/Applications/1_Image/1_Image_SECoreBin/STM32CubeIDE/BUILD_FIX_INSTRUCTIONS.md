# STM32 SBSFU Complete Guide for VS Code / Command Line Development

**Complete guide for building, flashing, and debugging STM32 SBSFU projects without STM32CubeIDE**

## Table of Contents

1. [Prerequisites & Toolchain Setup](#prerequisites--toolchain-setup)
2. [Initial Project Setup](#initial-project-setup)
3. [VS Code Configuration](#vs-code-configuration)
4. [Cryptographic Keys Setup](#cryptographic-keys-and-security-setup)
5. [Build Fix Instructions](#build-fix-instructions)
6. [Complete Build Workflow](#complete-build-workflow)
7. [Flashing & Debugging](#flashing--debugging)
8. [Verification & Testing](#verification--testing)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites & Toolchain Setup

### Required Tools

**1. ARM GCC Toolchain**

macOS installation:
```bash
# Option A: Using Homebrew
brew install --cask gcc-arm-embedded

# Option B: Manual installation
# Download from: https://developer.arm.com/downloads/-/gnu-rm
# Version tested: GNU Tools for STM32 (13.3.rel1)

# Verify installation
arm-none-eabi-gcc --version
# Should show: arm-none-eabi-gcc (GNU Tools for STM32 13.3.rel1) ...
```

**2. Build Tools**

```bash
# Make (should already be installed on macOS)
make --version  # Should be 3.81 or higher

# Python 3 for build scripts
python3 --version  # Should be 3.8 or higher

# Install Python dependencies
cd Middlewares/ST/STM32_Secure_Engine/Utilities/KeysAndImages
pip3 install -r requirements.txt
```

**3. Flashing/Debugging Tools**

```bash
# Option A: ST-Link tools
brew install stlink

# Option B: OpenOCD
brew install openocd

# Verify installation
st-info --version
openocd --version
```

**4. VS Code Extensions**

Install these extensions in VS Code:
- **C/C++** (ms-vscode.cpptools) - IntelliSense and debugging
- **Cortex-Debug** (marus25.cortex-debug) - ARM debugging
- **Makefile Tools** (ms-vscode.makefile-tools) - Makefile support
- **Hex Editor** (ms-vscode.hexeditor) - Binary inspection

### Environment Setup

Add to `~/.zshrc` or `~/.bash_profile`:

```bash
# ARM GCC Toolchain
export PATH="/Applications/ARM/bin:$PATH"

# ST-Link tools
export PATH="/usr/local/bin:$PATH"

# Verify after restart
which arm-none-eabi-gcc
which st-flash
```

---

## Initial Project Setup

### Understanding the Makefile Structure

STM32CubeIDE uses **Eclipse CDT Managed Build** which auto-generates makefiles from `.cproject` XML files.

**Project Structure:**
```
Projects/NUCLEO-G071RB/Applications/1_Image/
├── 1_Image_SECoreBin/
│   ├── STM32CubeIDE/
│   │   ├── .cproject           ← Eclipse project config
│   │   ├── .project            ← Eclipse metadata
│   │   ├── prebuild.sh         ← Generates se_key.s
│   │   ├── Debug/              ← Auto-generated makefiles
│   │   │   ├── makefile        ← Main makefile
│   │   │   ├── sources.mk      ← Source directories
│   │   │   ├── objects.mk      ← Object files list
│   │   │   └── Application/    ← Per-directory rules
│   └── Binary/                 ← Cryptographic keys
├── 1_Image_SBSFU/
│   └── STM32CubeIDE/Debug/     ← SBSFU makefiles
└── 1_Image_UserApp/
    └── STM32CubeIDE/Debug/     ← UserApp makefiles
```

**Key Points:**
- ✅ Makefiles are **already generated** in this project
- ✅ They work from command line without modification (mostly)
- ⚠️ If you modify .cproject in IDE, makefiles regenerate (lose manual fixes)
- ⚠️ Some dynamic files (like se_key.s) need manual makefile fixes

### Makefile Generation (If Starting Fresh)

If you need to regenerate makefiles or start a new project:

```bash
# Option 1: Use STM32CubeIDE once to generate initial makefiles
# 1. Open project in STM32CubeIDE
# 2. Right-click project → Build Configurations → Set Active → Debug
# 3. Project → Build Project (Ctrl+B)
# 4. Makefiles are now in STM32CubeIDE/Debug/
# 5. Copy modified makefiles (from this guide) if needed

# Option 2: Use existing makefiles from this project as template
# They're already configured and tested for command-line builds
```

---

## VS Code Configuration

### Workspace Structure

Open the SBSFU project root in VS Code:

```bash
cd /Users/tohid/stm32Projects/sbsfu/st_sbsfu
code .
```

### Configure Tasks (Build, Clean, Flash)

Create `.vscode/tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build SECoreBin",
            "type": "shell",
            "command": "cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE && bash ./prebuild.sh . && cd Debug && make all -j4",
            "group": "build",
            "problemMatcher": ["$gcc"],
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            }
        },
        {
            "label": "Build SBSFU",
            "type": "shell",
            "command": "cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/Debug && make all -j4",
            "group": "build",
            "dependsOn": ["Build SECoreBin"],
            "problemMatcher": ["$gcc"]
        },
        {
            "label": "Build UserApp",
            "type": "shell",
            "command": "cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_UserApp/STM32CubeIDE/Debug && make all -j4",
            "group": "build",
            "problemMatcher": ["$gcc"]
        },
        {
            "label": "Build All (SECoreBin → SBSFU → UserApp)",
            "dependsOrder": "sequence",
            "dependsOn": [
                "Build SECoreBin",
                "Build SBSFU",
                "Build UserApp"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
        {
            "label": "Clean SECoreBin",
            "type": "shell",
            "command": "cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE/Debug && make clean",
            "group": "build"
        },
        {
            "label": "Clean SBSFU",
            "type": "shell",
            "command": "cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/Debug && make clean",
            "group": "build"
        },
        {
            "label": "Clean All",
            "dependsOn": ["Clean SECoreBin", "Clean SBSFU"],
            "group": "build"
        },
        {
            "label": "Flash SBSFU",
            "type": "shell",
            "command": "st-flash write Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/Debug/SBSFU.bin 0x08000000",
            "dependsOn": ["Build SBSFU"],
            "problemMatcher": []
        }
    ]
}
```

**Usage:**
- `Cmd+Shift+B` → Shows build tasks menu
- Select "Build All" for complete build
- Use terminal: `Tasks: Run Task` → Select task

### Configure IntelliSense

Create `.vscode/c_cpp_properties.json`:

```json
{
    "configurations": [
        {
            "name": "Mac",
            "includePath": [
                "${workspaceFolder}/**",
                "${workspaceFolder}/Drivers/CMSIS/Include",
                "${workspaceFolder}/Drivers/CMSIS/Device/ST/STM32G0xx/Include",
                "${workspaceFolder}/Drivers/STM32G0xx_HAL_Driver/Inc",
                "${workspaceFolder}/Middlewares/ST/STM32_Secure_Engine/Core",
                "${workspaceFolder}/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/Inc"
            ],
            "defines": [
                "STM32G071xx",
                "USE_HAL_DRIVER"
            ],
            "compilerPath": "/Applications/ARM/bin/arm-none-eabi-gcc",
            "cStandard": "c11",
            "cppStandard": "c++17",
            "intelliSenseMode": "gcc-arm"
        }
    ],
    "version": 4
}
```

### Configure Debugging

Create `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug SBSFU (OpenOCD)",
            "type": "cortex-debug",
            "request": "launch",
            "servertype": "openocd",
            "cwd": "${workspaceFolder}",
            "executable": "${workspaceFolder}/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/Debug/SBSFU.elf",
            "device": "STM32G071RB",
            "configFiles": [
                "interface/stlink.cfg",
                "target/stm32g0x.cfg"
            ],
            "preLaunchTask": "Build SBSFU",
            "runToEntryPoint": "main",
            "showDevDebugOutput": "raw"
        },
        {
            "name": "Debug SBSFU (ST-Link GDB)",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/Debug/SBSFU.elf",
            "args": [],
            "stopAtEntry": true,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "miDebuggerPath": "arm-none-eabi-gdb",
            "miDebuggerServerAddress": "localhost:4242",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            "preLaunchTask": "Build SBSFU"
        }
    ]
}
```

---

## Build Fix Instructions

### Problem Summary

When building the SECoreBin project using makefiles from the command line (outside STM32CubeIDE), the build fails with undefined reference errors:

```
undefined reference to `SE_ReadKey_1'
undefined reference to `SE_ReadKey_1_Pub'
```

**Root Cause:** The makefile system doesn't include the dynamically-generated assembly file `se_key.s` which is created during the prebuild phase and contains these cryptographic key functions.

### Solution Overview

The build system needs to be updated to:
1. Recognize the `Application/Startup/` subdirectory
2. Include rules to compile `se_key.s` into `se_key.o`
3. Add `se_key.o` to the linker object list

---

## Step-by-Step Fix Instructions

### Step 1: Update `sources.mk`

**File:** `Debug/sources.mk`

**Change:** Add `Application/Startup \` to the SUBDIRS list

**Before:**
```makefile
# Every subdirectory with source files must be described here
SUBDIRS := \
Application/User \
Drivers/STM32G0xx_HAL_Driver \
Middlewares/STM32_Secure_Engine \
```

**After:**
```makefile
# Every subdirectory with source files must be described here
SUBDIRS := \
Application/Startup \
Application/User \
Drivers/STM32G0xx_HAL_Driver \
Middlewares/STM32_Secure_Engine \
```

---

### Step 2: Create `Application/Startup/subdir.mk`

**File:** `Debug/Application/Startup/subdir.mk` (NEW FILE)

**Content:**
```makefile
################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Application/Startup/se_key.s 

OBJS += \
./Application/Startup/se_key.o 

S_DEPS += \
./Application/Startup/se_key.d 


# Each subdirectory must supply rules for building sources it contributes
Application/Startup/%.o: ../Application/Startup/%.s Application/Startup/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m0plus -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -x assembler-with-cpp --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@" "$<"

Application/Startup/%.o: ../Application/Startup/%.S Application/Startup/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m0plus -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -x assembler-with-cpp --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@" "$<"

clean: clean-Application-2f-Startup

clean-Application-2f-Startup:
	-$(RM) ./Application/Startup/se_key.d ./Application/Startup/se_key.o

.PHONY: clean-Application-2f-Startup
```

---

### Step 3: Update Main `makefile`

**File:** `Debug/makefile`

**Change:** Include the new `Application/Startup/subdir.mk`

**Before:**
```makefile
# All of the sources participating in the build are defined here
-include sources.mk
-include Middlewares/STM32_Secure_Engine/subdir.mk
-include Drivers/STM32G0xx_HAL_Driver/subdir.mk
-include Application/User/subdir.mk
-include objects.mk
```

**After:**
```makefile
# All of the sources participating in the build are defined here
-include sources.mk
-include Middlewares/STM32_Secure_Engine/subdir.mk
-include Drivers/STM32G0xx_HAL_Driver/subdir.mk
-include Application/Startup/subdir.mk
-include Application/User/subdir.mk
-include objects.mk
```

---

### Step 4: Update `objects.list`

**File:** `Debug/objects.list`

**Change:** Add `se_key.o` to the object files list

**Before:**
```makefile
"./Application/User/data_init.o"
"./Application/User/se_crypto_bootloader.o"
"./Application/User/se_low_level.o"
"./Application/User/syscalls.o"
"./Drivers/STM32G0xx_HAL_Driver/stm32g0xx_hal_crc.o"
"./Drivers/STM32G0xx_HAL_Driver/stm32g0xx_hal_crc_ex.o"
"./Drivers/STM32G0xx_HAL_Driver/stm32g0xx_hal_flash.o"
"./Drivers/STM32G0xx_HAL_Driver/stm32g0xx_hal_flash_ex.o"
"./Middlewares/STM32_Secure_Engine/se_callgate.o"
"./Middlewares/STM32_Secure_Engine/se_crypto_common.o"
"./Middlewares/STM32_Secure_Engine/se_exception.o"
"./Middlewares/STM32_Secure_Engine/se_fwimg.o"
"./Middlewares/STM32_Secure_Engine/se_startup.o"
"./Middlewares/STM32_Secure_Engine/se_user_application.o"
"./Middlewares/STM32_Secure_Engine/se_utils.o"
```

**After:**
```makefile
"./Application/User/data_init.o"
"./Application/User/se_crypto_bootloader.o"
"./Application/User/se_low_level.o"
"./Application/User/syscalls.o"
"./Drivers/STM32G0xx_HAL_Driver/stm32g0xx_hal_crc.o"
"./Drivers/STM32G0xx_HAL_Driver/stm32g0xx_hal_crc_ex.o"
"./Drivers/STM32G0xx_HAL_Driver/stm32g0xx_hal_flash.o"
"./Drivers/STM32G0xx_HAL_Driver/stm32g0xx_hal_flash_ex.o"
"./Middlewares/STM32_Secure_Engine/se_callgate.o"
"./Middlewares/STM32_Secure_Engine/se_crypto_common.o"
"./Middlewares/STM32_Secure_Engine/se_exception.o"
"./Middlewares/STM32_Secure_Engine/se_fwimg.o"
"./Middlewares/STM32_Secure_Engine/se_startup.o"
"./Middlewares/STM32_Secure_Engine/se_user_application.o"
"./Middlewares/STM32_Secure_Engine/se_utils.o"
"./Application/Startup/se_key.o"
```

---

## Build Commands

After applying the fixes, build using:

```bash
cd STM32CubeIDE/Debug

# Clean previous build
make clean

# Build the project
make all -j4
```

**Expected Output:**
```
Finished building target: SECoreBin.elf
   text    data     bss     dec     hex filename
  18014       8    2636   20658    50b2 SECoreBin.elf
Finished building: SECoreBin.bin
```

---

## Quick Apply Script

You can use this script to apply all changes automatically:

```bash
#!/bin/bash
cd STM32CubeIDE/Debug

# 1. Update sources.mk
sed -i.bak '/^SUBDIRS := \\/a\
Application/Startup \\
' sources.mk

# 2. Create Application/Startup directory
mkdir -p Application/Startup

# 3. Create subdir.mk
cat > Application/Startup/subdir.mk << 'EOF'
################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Application/Startup/se_key.s 

OBJS += \
./Application/Startup/se_key.o 

S_DEPS += \
./Application/Startup/se_key.d 


# Each subdirectory must supply rules for building sources it contributes
Application/Startup/%.o: ../Application/Startup/%.s Application/Startup/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m0plus -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -x assembler-with-cpp --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@" "$<"

Application/Startup/%.o: ../Application/Startup/%.S Application/Startup/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m0plus -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -x assembler-with-cpp --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@" "$<"

clean: clean-Application-2f-Startup

clean-Application-2f-Startup:
	-$(RM) ./Application/Startup/se_key.d ./Application/Startup/se_key.o

.PHONY: clean-Application-2f-Startup
EOF

# 4. Update main makefile
sed -i.bak '/^-include Application\/User\/subdir.mk$/i\
-include Application/Startup/subdir.mk
' makefile

# 5. Add to objects.list
echo '"./Application/Startup/se_key.o"' >> objects.list

echo "Build fix applied successfully!"
```

---

## Technical Details

### Why This Fix Is Needed

**Chicken-and-Egg Problem:**
1. `se_key.s` is generated by `prebuild.sh` during the build
2. STM32CubeIDE's makefile generator runs BEFORE prebuild
3. The generator doesn't see `se_key.s` (it doesn't exist yet)
4. So it's not included in the auto-generated makefiles

**STM32CubeIDE vs Command Line:**
- **STM32CubeIDE**: Handles this internally, regenerating build configuration after prebuild
- **Command Line / VS Code**: Uses static makefiles that don't automatically update

### Files Modified Summary

| File | Change Type | Purpose |
|------|-------------|---------|
| `sources.mk` | Modified | Tells make to look in Application/Startup/ |
| `Application/Startup/subdir.mk` | Created | Provides rules to compile se_key.s |
| `makefile` | Modified | Includes the new subdir.mk |
| `objects.list` | Modified | Adds se_key.o to linker inputs |

---

## Important Notes

⚠️ **Warning:** These are "auto-generated" files. If you regenerate the project in STM32CubeIDE, you may need to reapply these changes.

✅ **Permanent Solution:** Add `se_key.s` to the `.cproject` file so STM32CubeIDE includes it during makefile generation.

💡 **Best Practice:** Keep a copy of these modified files or this instruction document for reference.

---

## Troubleshooting

### Issue: "No such file or directory: se_key.s"
**Solution:** Run prebuild script first:
```bash
cd STM32CubeIDE
bash ./prebuild.sh .
```

### Issue: Still getting undefined reference errors
**Solution:** Verify `se_key.o` is in objects.list and was compiled:
```bash
ls -la Debug/Application/Startup/se_key.o
grep se_key.o Debug/objects.list
```

### Issue: Python/NumPy architecture mismatch
**Solution:** Fix Python environment (see original build error). This was the initial problem before the makefile issues.

---

## macOS-Specific Issues and Fixes

When building on macOS, you may encounter additional platform-specific issues:

### Issue 1: CRLF Line Ending Errors

**Symptom:**
```bash
/bin/bash: -: invalid option
```

**Root Cause:** Shell scripts (*.sh) have DOS/Windows CRLF (`\r\n`) line endings instead of Unix LF (`\n`)

**Solution:**

**Option A - Using sed:**
```bash
sed -i '' 's/\r$//' prebuild.sh
sed -i '' 's/\r$//' postbuild.sh
```

**Option B - Using dos2unix (if installed):**
```bash
dos2unix prebuild.sh postbuild.sh
```

**Option C - Fix all .sh files in project:**
```bash
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec sed -i '' 's/\r$//' {} \;
```

### Issue 2: Script Permission Errors

**Symptom:**
```bash
bash: ./prebuild.sh: Permission denied
```

**Root Cause:** Shell scripts lack execute permissions

**Solution:**

**Fix single script:**
```bash
chmod +x prebuild.sh
chmod +x postbuild.sh
```

**Fix all .sh files in project:**
```bash
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec chmod +x {} \;
```

### Combined macOS Setup

Run this comprehensive setup for macOS:

```bash
#!/bin/bash
# Navigate to project root
cd /Users/tohid/stm32Projects/sbsfu/st_sbsfu

# Fix line endings for all shell scripts
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec sed -i '' 's/\r$//' {} \;

# Add execute permissions
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec chmod +x {} \;

echo "macOS platform fixes applied!"
```

---

## Cryptographic Keys and Security Setup

### STEP 0: Generate Keys (ONE TIME ONLY - BEFORE FIRST BUILD)

**⚠️ CRITICAL: Keys must be generated ONCE before building any projects!**

This project uses **SECBOOT_ECCDSA_WITH_AES128_CBC_SHA256** crypto scheme:
- **ECDSA P-256**: Asymmetric signature/authentication (private key signs, public key verifies)
- **AES-128-CBC**: Symmetric encryption (16-byte key)
- **SHA256**: Firmware integrity hashing

### Current Keys in This Project

**Location:** `Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/Binary/`

| File | Type | Size | Purpose | Security |
|------|------|------|---------|----------|
| `ECCKEY1.txt` | ECC P-256 Private Key | 227 bytes | Signs UserApp firmware | **🔒 KEEP SECRET** |
| `OEM_KEY_COMPANY1_key_AES_CBC.bin` | AES-128 Key | 16 bytes | Encrypts UserApp firmware | **🔒 KEEP SECRET** |
| `OEM_KEY_COMPANY1_key_AES_GCM.bin` | AES-128 Key | 16 bytes | (Alternative - not used) | **🔒 KEEP SECRET** |
| `nonce.bin` | Initialization Vector | 12 bytes | CBC encryption nonce | Can be public |

**Key Details:**
```bash
# View ECC key (PEM format):
$ head -n 5 Binary/ECCKEY1.txt
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIIEobnAEKh92mvSE+X70hQMvFb8LOg+TGB9Dqu4dyvO8oAoGCCqGSM49
AwEHoUQDQgAEuvKX+D7jB9wWw3F4HfGwPvCVsERUEoFI+yxmuVQ9pUroJgR2tzeL
PEbY/WpjYXxGw33pRkQxbtfhbbpw7US6Ag==
-----END EC PRIVATE KEY-----

# AES key is 16 bytes (128 bits):
$ hexdump -C Binary/OEM_KEY_COMPANY1_key_AES_CBC.bin
00000000  4f 45 4d 5f 4b 45 59 5f  43 4f 4d 50 41 4e 59 31  |OEM_KEY_COMPANY1|
```

### Key Generation Commands (For Reference)

**⚠️ THESE KEYS ARE ALREADY GENERATED - DO NOT RUN UNLESS YOU WANT NEW KEYS!**

If you need to generate fresh keys for production:

```bash
cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin
cd ../../../../../../Middlewares/ST/STM32_Secure_Engine/Utilities/KeysAndImages

# Generate ECC P-256 keypair (for signing/authentication)
python3 prepareimage.py keygen -k ECCKEY1.txt -t ecdsa-p256

# Generate AES-128 key (for CBC encryption)
python3 prepareimage.py keygen -k OEM_KEY_COMPANY1_key_AES_CBC.bin -t aes-cbc

# Generate AES-128 key (for GCM - optional)
python3 prepareimage.py keygen -k OEM_KEY_COMPANY1_key_AES_GCM.bin -t aes-gcm

# Move keys to Binary folder
mv ECCKEY1.txt ../../../Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/Binary/
mv OEM_KEY_COMPANY1_key_AES_CBC.bin ../../../Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/Binary/
```

### How Keys Flow Through the Build System

```
┌─────────────────────────────────────────────────────────────┐
│ Step 0: Generate Keys (ONE TIME ONLY)                        │
│                                                              │
│  python3 prepareimage.py keygen -k ECCKEY1.txt -t ecdsa-p256│
│  → Creates: ECCKEY1.txt (private + public key pair)         │
│  → Creates: OEM_KEY_COMPANY1_key_AES_CBC.bin (AES key)      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ Step 1: SECoreBin Build                                      │
│                                                              │
│  prebuild.sh:                                                │
│    - READS existing ECCKEY1.txt (does NOT regenerate)       │
│    - Extracts PUBLIC KEY from ECCKEY1.txt                    │
│    - Generates se_key.s assembly file containing:           │
│      * SE_ReadKey_1() → Returns PRIVATE KEY (for decryption)│
│      * SE_ReadKey_1_Pub() → Returns PUBLIC KEY (for verify) │
│      * AES keys embedded as data                            │
│    - Compiles se_key.s into se_key.o                        │
│                                                              │
│  Result: SECoreBin.bin (contains all keys embedded)          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ Step 2: SBSFU Build                                          │
│                                                              │
│  postbuild.sh (from SECoreBin):                              │
│    - Converts SECoreBin.bin → SE_CORE_Bin.c                 │
│    - Embeds as: const uint8_t SE_CORE_Bin[] = {...}        │
│                                                              │
│  SBSFU compilation:                                          │
│    - Includes SE_CORE_Bin.c as source file                  │
│    - Links Secure Engine into SBSFU.elf                     │
│                                                              │
│  Result: SBSFU.bin (bootloader with PUBLIC KEY embedded)     │
│  📍 PUBLIC KEY is now in flash memory for verification       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ Step 3: UserApp Build & Signing                              │
│                                                              │
│  UserApp compilation: (regular C code, no special crypto)    │
│    - Compiles application sources                           │
│    - Generates UserApp.bin (unsigned, unencrypted)          │
│                                                              │
│  UserApp Makefile post-build:                                │
│    - Converts UserApp.elf → UserApp.bin                     │
│    - Calls: "../../../1_Image_SECoreBin/STM32CubeIDE/      │
│              postbuild.sh" "../" "UserApp.elf"              │
│              "../UserApp.bin" "1" "1"                        │
│                                                              │
│  postbuild.sh (SYMLINK → SECBOOT_ECCDSA_WITH_AES128_CBC_    │
│              SHA256.sh):                                     │
│    ┌─────────────────────────────────────────────────┐     │
│    │ Step 1: Encrypt UserApp.bin                     │     │
│    │   python prepareimage.py enc \                  │     │
│    │     -k OEM_KEY_COMPANY1_key_AES_CBC.bin \       │     │
│    │     -i iv.bin \                                  │     │
│    │     UserApp.bin UserApp.sfu                     │     │
│    │   → Creates encrypted firmware (AES-128-CBC)    │     │
│    ├─────────────────────────────────────────────────┤     │
│    │ Step 2: Generate SHA256 hash                    │     │
│    │   python prepareimage.py sha256 \               │     │
│    │     UserApp.bin UserApp.sign                    │     │
│    │   → Hash of ORIGINAL (unencrypted) binary       │     │
│    ├─────────────────────────────────────────────────┤     │
│    │ Step 3: Sign hash + pack firmware               │     │
│    │   python prepareimage.py pack \                 │     │
│    │     -m "SFU1" \          # Magic (slot 1)       │     │
│    │     -k ECCKEY1.txt \     # PRIVATE KEY          │     │
│    │     -r 28 \              # Rollback counter     │     │
│    │     -v 1 \               # Version              │     │
│    │     -i iv.bin \          # Init vector          │     │
│    │     -f UserApp.sfu \     # Encrypted FW         │     │
│    │     -t UserApp.sign \    # SHA256 hash          │     │
│    │     UserApp.sfb \        # OUTPUT FILE          │     │
│    │     -o 2048              # Offset               │     │
│    │   → Signs hash with ECDSA P-256 private key     │     │
│    │   → Packages: header + encrypted FW + signature │     │
│    ├─────────────────────────────────────────────────┤     │
│    │ Step 4: Generate firmware header                │     │
│    │   python prepareimage.py header \               │     │
│    │     -m "SFU1" -k ECCKEY1.txt ... \              │     │
│    │     UserAppsfuh.bin                             │     │
│    │   → Metadata for SBSFU verification             │     │
│    ├─────────────────────────────────────────────────┤     │
│    │ Step 5: Merge SBSFU + UserApp (optional)        │     │
│    │   python prepareimage.py merge \                │     │
│    │     -i UserAppsfuh.bin \                         │     │
│    │     -s SBSFU.elf \                               │     │
│    │     -u UserApp.elf \                             │     │
│    │     SBSFU_UserApp.bin                            │     │
│    │   → Combined binary for testing                 │     │
│    ├─────────────────────────────────────────────────┤     │
│    │ Step 6: Cleanup temp files                      │     │
│    │   rm UserApp.sign UserApp.sfu UserAppsfuh.bin   │     │
│    └─────────────────────────────────────────────────┘     │
│                                                              │
│  Final Output: UserApp.sfb                                   │
│    ┌───────────────────────────────────────────┐           │
│    │ Firmware Header (metadata)                │           │
│    │  - Magic: "SFU1"                          │           │
│    │  - Version: 1                             │           │
│    │  - Firmware size                          │           │
│    │  - SHA256 hash (32 bytes)                 │           │
│    │  - ECDSA signature (64 bytes)             │           │
│    │  - Rollback counter: 28                   │           │
│    │  - IV (12 bytes)                          │           │
│    ├───────────────────────────────────────────┤           │
│    │ Encrypted Firmware (AES-128-CBC)          │           │
│    │  - UserApp.bin encrypted                  │           │
│    └───────────────────────────────────────────┘           │
│                                                              │
│  📍 PRIVATE KEY never leaves development machine             │
│  📍 postbuild.sh is auto-created symlink based on crypto    │
│     scheme in se_crypto_config.h                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ Runtime: Firmware Verification (on MCU)                      │
│                                                              │
│  When UserApp.sfb is uploaded to device:                     │
│    1. SBSFU parses firmware header from UserApp.sfb         │
│    2. Extracts encrypted firmware + signature               │
│    3. Calls SE_Verify(firmware, signature)                  │
│    4. SE uses PUBLIC KEY (from se_key.o) to verify ECDSA    │
│    5. SE decrypts firmware with AES key (from se_key.o)     │
│    6. SE computes SHA256 of decrypted firmware              │
│    7. Compares computed hash with signed hash               │
│    8. If signature valid ✓ AND hash matches ✓:             │
│       - SBSFU installs firmware to active slot              │
│       - Boots UserApp                                        │
│    9. If signature invalid ✗ OR hash mismatch ✗:           │
│       - Firmware rejected (prevents malicious code)         │
│       - SBSFU refuses to install                            │
└─────────────────────────────────────────────────────────────┘
```

### Key Security Best Practices

**🔒 CRITICAL - Keep Private Keys Secret:**
1. **Backup**: Store keys in secure, encrypted backup location
2. **Version Control**: Add to `.gitignore`, never commit to public repos
3. **Access Control**: Limit access to authorized developers only
4. **Production**: Generate NEW keys for production (don't use ST's examples)
5. **Key Rotation**: Regenerating keys requires rebuilding ALL three projects

**⚠️ WARNING: Key Dependency Chain**
```
If ECCKEY1.txt is lost or regenerated:
  → Must rebuild SECoreBin (new public key embedded)
  → Must rebuild SBSFU (new SE_CORE_Bin.c)
  → Must reflash device with new SBSFU.bin
  → Old UserApp.sfb files become INVALID (different signature)
```

**Disaster Recovery:**
```bash
# If you lose keys and device is already flashed:
1. Connect debugger and fully erase flash
2. Generate new keys with prepareimage.py keygen
3. Rebuild SECoreBin, SBSFU, UserApp in order
4. Flash new SBSFU.bin to device
```

---

## UserApp Firmware Signing Process (Detailed)

### Overview

The UserApp project uses an **automated signing and encryption pipeline** that runs during the makefile post-build step. No manual intervention required!

### Postbuild.sh Symlink Mechanism

**Dynamic Script Selection:**
```bash
# During SECoreBin prebuild, postbuild.sh is created as a symlink
# based on the crypto scheme in se_crypto_config.h

$ ls -la 1_Image_SECoreBin/STM32CubeIDE/postbuild.sh
lrwxr-xr-x postbuild.sh -> ./SECBOOT_ECCDSA_WITH_AES128_CBC_SHA256.sh

# Available crypto-specific scripts:
# - SECBOOT_ECCDSA_WITHOUT_ENCRYPT_SHA256.sh      (ECDSA only, no encryption)
# - SECBOOT_ECCDSA_WITH_AES128_CBC_SHA256.sh      (ECDSA + AES-CBC - USED HERE)
# - SECBOOT_AES128_GCM_AES128_GCM_AES128_GCM.sh  (AES-GCM for all operations)
```

**This ensures:**
- ✅ Correct signing script automatically selected
- ✅ Crypto scheme consistency between SECoreBin and UserApp
- ✅ No manual script selection needed

### UserApp Makefile Post-Build

**From UserApp/STM32CubeIDE/Debug/makefile:**
```makefile
post-build:
	arm-none-eabi-objcopy -O binary "UserApp.elf" "../UserApp.bin"
	arm-none-eabi-size "UserApp.elf"
	"../../../1_Image_SECoreBin/STM32CubeIDE/postbuild.sh" \
	    "../" \                    # arg1: Build directory
	    "UserApp.elf" \            # arg2: ELF file path
	    "../UserApp.bin" \         # arg3: Binary file path
	    "1" \                      # arg4: Firmware ID (slot 1)
	    "1"                        # arg5: Firmware version
```

### Signing Script Workflow

**Script:** `SECBOOT_ECCDSA_WITH_AES128_CBC_SHA256.sh`

**Input Files:**
```
UserApp.bin                                  ← Unencrypted, unsigned firmware
../Binary/ECCKEY1.txt                        ← ECC P-256 private key
../Binary/OEM_KEY_COMPANY1_key_AES_CBC.bin   ← AES-128 encryption key
../Binary/iv.bin                             ← Initialization vector
```

**Process (5 Steps):**

```bash
# ================================================================
# STEP 1: Encrypt Firmware with AES-128-CBC
# ================================================================
python prepareimage.py enc \
  -k OEM_KEY_COMPANY1_key_AES_CBC.bin \
  -i iv.bin \
  UserApp.bin \
  UserApp.sfu

# Output: UserApp.sfu (encrypted firmware)
# - AES-128-CBC mode (Cipher Block Chaining)
# - 16-byte key
# - 12-byte IV
# - Padding to 16-byte blocks

# ================================================================
# STEP 2: Generate SHA256 Hash
# ================================================================
python prepareimage.py sha256 \
  UserApp.bin \
  UserApp.sign

# Output: UserApp.sign (32-byte SHA256 hash)
# - Hash of ORIGINAL (unencrypted) firmware
# - Used for integrity verification
# - Will be signed in next step

# ================================================================
# STEP 3: Sign Hash + Pack Firmware
# ================================================================
python prepareimage.py pack \
  -m "SFU1" \              # Magic number (firmware slot identifier)
  -k ECCKEY1.txt \         # ECC P-256 PRIVATE KEY (signs the hash)
  -r 28 \                  # Rollback counter (anti-rollback protection)
  -v 1 \                   # Firmware version
  -i iv.bin \              # Initialization vector
  -f UserApp.sfu \         # Encrypted firmware (from step 1)
  -t UserApp.sign \        # SHA256 hash (from step 2)
  UserApp.sfb \            # OUTPUT: Secure Firmware Binary
  -o 2048                  # Header offset (2KB)

# Output: UserApp.sfb (complete package)
# Contains:
#   - Firmware header (metadata + signature)
#   - Encrypted firmware
#   - ECDSA signature (64 bytes: R=32, S=32)

# ================================================================
# STEP 4: Generate Firmware Header (Metadata Only)
# ================================================================
python prepareimage.py header \
  -m "SFU1" \
  -k ECCKEY1.txt \
  -r 28 \
  -v 1 \
  -i iv.bin \
  -f UserApp.sfu \
  -t UserApp.sign \
  -o 2048 \
  UserAppsfuh.bin

# Output: UserAppsfuh.bin (header only)
# Used for merged binary generation

# ================================================================
# STEP 5: Merge SBSFU + UserApp (Optional)
# ================================================================
python prepareimage.py merge \
  -v 0 \                   # Verbose level
  -e 1 \                   # Enable encryption flag
  -i UserAppsfuh.bin \     # Firmware header
  -s SBSFU.elf \           # SBSFU bootloader ELF
  -u UserApp.elf \         # UserApp ELF
  SBSFU_UserApp.bin        # Combined binary for testing

# Output: SBSFU_UserApp.bin
# Complete flash image: SBSFU + Header + UserApp
# Can be flashed directly to 0x08000000 for quick testing

# ================================================================
# STEP 6: Cleanup Temporary Files
# ================================================================
rm UserApp.sign          # SHA256 hash (no longer needed)
rm UserApp.sfu           # Encrypted firmware (already in .sfb)
rm UserAppsfuh.bin       # Header-only file (already in .sfb)
```

### Output Files Structure

**UserApp.sfb (Secure Firmware Binary) - MAIN OUTPUT:**

```
Offset    Size      Description
═══════════════════════════════════════════════════════════
0x0000    4 bytes   Magic: "SFU1" (0x53465531)
0x0004    4 bytes   Header size
0x0008    4 bytes   Firmware version (1)
0x000C    4 bytes   Firmware size (bytes)
0x0010    32 bytes  SHA256 hash of clear firmware
0x0030    64 bytes  ECDSA signature (R=32 bytes, S=32 bytes)
0x0070    4 bytes   Partial firmware offset
0x0074    4 bytes   Partial firmware size
0x0078    12 bytes  IV (initialization vector)
0x0084    28 bytes  Rollback counter
0x00A0    ...       Reserved/padding
─────────────────────────────────────────────────────────
0x0800    ...       Encrypted firmware (AES-128-CBC)
          (size)    UserApp.bin encrypted
═══════════════════════════════════════════════════════════
```

**SBSFU_UserApp.bin (Combined Binary) - OPTIONAL:**

```
Flash Address    Content
═══════════════════════════════════════════════════
0x08000000       SBSFU bootloader + Secure Engine
                 (from SBSFU.elf, ~62KB)
─────────────────────────────────────────────────
0x08003000       UserApp firmware header
                 (metadata + signature, ~2KB)
─────────────────────────────────────────────────
0x08003800       Encrypted UserApp firmware
                 (from UserApp.bin, variable size)
═══════════════════════════════════════════════════
```

### Verification on Device

**When SBSFU receives UserApp.sfb:**

```c
// Pseudo-code of SBSFU verification process

1. Parse firmware header from UserApp.sfb
   - Extract magic "SFU1"
   - Extract version, size, IV
   - Extract SHA256 hash (32 bytes)
   - Extract ECDSA signature (64 bytes)

2. Verify firmware slot (magic == "SFU1")

3. Check version (version >= current_version)
   - Prevents rollback attacks

4. Decrypt encrypted firmware
   SE_Decrypt(UserApp.sfu, OEM_KEY_AES_CBC, IV)
   → decrypted_firmware[]

5. Compute SHA256 of decrypted firmware
   SHA256(decrypted_firmware)
   → computed_hash[32]

6. Verify ECDSA signature
   SE_ReadKey_1_Pub()                    // Get public key
   → public_key
   
   ECDSA_Verify(
       public_key,
       computed_hash,                     // Hash we just computed
       signature_from_header              // Signature from UserApp.sfb
   )
   → VALID or INVALID

7. Decision:
   if (signature == VALID && computed_hash == header_hash)
   {
       // Install firmware to active slot
       Flash_Write(ACTIVE_SLOT_ADDRESS, decrypted_firmware);
       
       // Mark as valid
       FW_Status = FW_VALID;
       
       // Boot UserApp
       Jump_To_Application();
   }
   else
   {
       // Reject firmware
       FW_Status = FW_INVALID;
       
       // Stay in SBSFU or boot existing valid firmware
   }
```

### Security Features

**Confidentiality (Encryption):**
- ✅ AES-128-CBC encrypts firmware
- ✅ Attacker cannot extract code even with firmware file
- ✅ Decryption key stored in Secure Engine (MPU protected)

**Integrity (Hashing):**
- ✅ SHA256 ensures firmware not tampered
- ✅ Any byte change invalidates hash
- ✅ Hash computed on clear firmware before encryption

**Authenticity (Signing):**
- ✅ ECDSA signature proves firmware from trusted source
- ✅ Only holder of private key can create valid signature
- ✅ Public key verification in Secure Engine

**Anti-Rollback:**
- ✅ Version counter prevents downgrade attacks
- ✅ Rollback counter stored in header
- ✅ SBSFU rejects older versions

### Key Files Reference

**Keys Used by Signing Script:**

| File | Type | Size | Purpose | Security Level |
|------|------|------|---------|----------------|
| `ECCKEY1.txt` | ECC P-256 Private Key | 227 bytes | Signs firmware hash | 🔒 TOP SECRET |
| `OEM_KEY_COMPANY1_key_AES_CBC.bin` | AES-128 Key | 16 bytes | Encrypts firmware | 🔒 TOP SECRET |
| `iv.bin` | Initialization Vector | 12 bytes | CBC mode nonce | 🔓 Can be public |

**Generated Output Files:**

| File | Description | Usage |
|------|-------------|-------|
| `UserApp.bin` | Unsigned, unencrypted binary | Intermediate (deleted) |
| `UserApp.sfu` | Encrypted firmware only | Intermediate (cleaned up) |
| `UserApp.sign` | SHA256 hash | Intermediate (cleaned up) |
| `UserAppsfuh.bin` | Header with metadata | Intermediate (cleaned up) |
| **`UserApp.sfb`** | **Signed, encrypted, complete** | **FLASH THIS!** |
| `SBSFU_UserApp.bin` | Combined bootloader + app | Testing only |

### Troubleshooting Signing Process

**Problem: "Python module not found"**
```bash
# Install dependencies
cd Middlewares/ST/STM32_Secure_Engine/Utilities/KeysAndImages
pip3 install -r requirements.txt
```

**Problem: "ECCKEY1.txt not found"**
```bash
# Keys must exist before building UserApp
ls -lh Projects/.../1_Image_SECoreBin/Binary/ECCKEY1.txt

# If missing, generate keys (see "Cryptographic Keys Setup" section)
```

**Problem: "Signature verification failed on device"**
```bash
# Ensure same keys used for SECoreBin and UserApp
# Rebuild all three projects in order:
# 1. SECoreBin (embeds public key)
# 2. SBSFU (includes SE with public key)
# 3. UserApp (signs with matching private key)
```

**Problem: "postbuild.sh: command not found"**
```bash
# Fix permissions and CRLF issues (macOS)
chmod +x Projects/.../1_Image_SECoreBin/STM32CubeIDE/postbuild.sh
sed -i '' 's/\r$//' Projects/.../1_Image_SECoreBin/STM32CubeIDE/postbuild.sh
```

---

## Build Dependency Chain

The SBSFU system consists of three interdependent projects that must be built in order:

### 1. SECoreBin Project (Secure Engine Core)

**Location:** `Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/`

**Purpose:**
- Isolated secure execution environment
- Cryptographic operations (AES, SHA256, RSA/ECC)
- Secure key storage and management
- Implements SE_ReadKey_1 and SE_ReadKey_1_Pub functions

**Build Output:**
- `SECoreBin.bin` (18,014 bytes code + 2,636 bytes BSS = 20,658 bytes total)
- `SE_CORE_Bin.c` - Generated C file embedding SECoreBin.bin as byte array

**Key Files Generated:**
- `Application/Startup/se_key.s` (222 lines) - Dynamically generated by prebuild.sh
- `SE_CORE_Bin.c` - Used by SBSFU project

**Build Command:**
```bash
cd STM32CubeIDE
bash ./prebuild.sh .
cd Debug
make clean && make all -j4
```

### 2. SBSFU Project (Secure Boot Secure Firmware Update)

**Location:** `Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/`

**Purpose:**
- Main bootloader
- Firmware verification (signature and integrity checks)
- Firmware decryption
- Secure firmware installation
- Launches user application

**Dependencies:**
- Requires `SE_CORE_Bin.c` from SECoreBin project
- Links Secure Engine as embedded binary

**Build Output:**
- `SBSFU.elf` (46,900 bytes code + 128 bytes data + 15,744 bytes BSS = 62,772 bytes total)
- `SBSFU.bin` - Ready to flash to MCU

**Key Files Compiled:**
```
Application/Core/SE_CORE_Bin.c      ← From SECoreBin
Application/Core/sfu_boot.c
Application/Core/sfu_loader.c
Application/Core/sfu_new_image.c
Application/Core/sfu_fwimg_common.c
Application/Core/sfu_low_level_security.c
Application/Core/sfu_mpu_isolation.c
Application/Core/sfu_low_level_flash*.c
Application/Core/sfu_com_*.c
```

**Build Command:**
```bash
cd STM32CubeIDE/Debug
make clean && make all -j4
```

### 3. UserApp Project (User Application)

**Location:** `Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_UserApp/`

**Purpose:**
- Your actual application firmware
- Gets signed and optionally encrypted
- Installed and verified by SBSFU bootloader

**Dependencies:**
- Requires SECoreBin cryptographic keys for signing
- Post-build script signs firmware image

**Build Output:**
- `UserApp.bin` - Signed/encrypted user application
- `UserApp.sfb` - Secure firmware binary for SBSFU

### Build Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ 1. SECoreBin Project                                         │
│    ├─ prebuild.sh generates se_key.s                        │
│    ├─ Compile secure engine core                            │
│    ├─ Generate SECoreBin.bin                                │
│    └─ postbuild.sh creates SE_CORE_Bin.c                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼ (SE_CORE_Bin.c)
┌─────────────────────────────────────────────────────────────┐
│ 2. SBSFU Project                                             │
│    ├─ Include SE_CORE_Bin.c as source                       │
│    ├─ Compile SBSFU bootloader                              │
│    ├─ Link with embedded Secure Engine                      │
│    └─ Generate SBSFU.bin                                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼ (SBSFU installed on MCU)
┌─────────────────────────────────────────────────────────────┐
│ 3. UserApp Project                                           │
│    ├─ Compile user application                              │
│    ├─ postbuild.sh signs with SE keys                       │
│    └─ Generate UserApp.sfb (secure firmware binary)         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼ (Flash via SBSFU)
┌─────────────────────────────────────────────────────────────┐
│ MCU Flash Memory Layout                                      │
│    ├─ 0x08000000: SBSFU bootloader (with embedded SE)       │
│    ├─ 0x0800xxxx: Active Firmware Slot                      │
│    └─ 0x080xxxxx: Download Firmware Slot                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Complete Build Workflow

### End-to-End Build Process (Command Line)

**Complete workflow from fresh checkout to flashed device:**

```bash
# ============================================================
# STEP 0: One-Time Setup (after git clone)
# ============================================================

# 0.1 Navigate to project root
cd /Users/tohid/stm32Projects/sbsfu/st_sbsfu

# 0.2 Fix macOS-specific issues (CRLF + permissions)
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec sed -i '' 's/\r$//' {} \;
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec chmod +x {} \;

# 0.3 Install Python dependencies
cd Middlewares/ST/STM32_Secure_Engine/Utilities/KeysAndImages
pip3 install -r requirements.txt
cd -

# 0.4 Verify keys exist (should already be in repo)
ls -lh Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/Binary/
# Should see: ECCKEY1.txt, OEM_KEY_COMPANY1_key_AES_CBC.bin, etc.

# ============================================================
# STEP 1: Build SECoreBin (Secure Engine Core)
# ============================================================

cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE

# 1.1 Run prebuild script (generates se_key.s from keys)
bash ./prebuild.sh .
# Output: Application/Startup/se_key.s created (222 lines)

# 1.2 Apply makefile fixes (if not already applied)
cd Debug
# Follow "Build Fix Instructions" section to add se_key.s to build

# 1.3 Build
make clean
make all -j4

# Expected output:
#   text    data     bss     dec     hex filename
#  18014       8    2636   20658    50b2 SECoreBin.elf
# Finished building: SECoreBin.bin

# 1.4 Generate SE_CORE_Bin.c (postbuild)
cd ..
bash ./postbuild.sh .

# Verify output
ls -lh ../../1_Image_SBSFU/Application/Core/SE_CORE_Bin.c
# Should exist and be ~75KB

# ============================================================
# STEP 2: Build SBSFU (Secure Boot Secure Firmware Update)
# ============================================================

cd ../../1_Image_SBSFU/STM32CubeIDE/Debug

# 2.1 Clean build
make clean

# 2.2 Build SBSFU (includes SE_CORE_Bin.c)
make all -j4

# Expected output:
#   text    data     bss     dec     hex filename
#  46900     128   15744   62772    f534 SBSFU.elf
# Finished building: SBSFU.bin

# Verify binary size
ls -lh ../SBSFU.bin
# Should be ~62KB

# ============================================================
# STEP 3: Build UserApp (User Application)
# ============================================================

cd ../../1_Image_UserApp/STM32CubeIDE/Debug

# 3.1 Clean build
make clean

# 3.2 Build UserApp (compiles + signs + encrypts automatically)
make all -j4

# What happens during build:
# 1. Compiles all C sources → UserApp.elf
# 2. Converts to binary → UserApp.bin
# 3. Post-build runs automatically:
#    - Calls ../../../1_Image_SECoreBin/STM32CubeIDE/postbuild.sh
#    - postbuild.sh is a SYMLINK to SECBOOT_ECCDSA_WITH_AES128_CBC_SHA256.sh
#    - Python script prepareimage.py:
#      a) Encrypts UserApp.bin with AES-128-CBC → UserApp.sfu
#      b) Computes SHA256 hash → UserApp.sign
#      c) Signs hash with ECCKEY1.txt (ECDSA P-256)
#      d) Packages header + encrypted FW + signature → UserApp.sfb
#      e) Generates combined binary SBSFU_UserApp.bin (optional)
#      f) Cleans up temporary files (UserApp.sfu, UserApp.sign)

# Expected output:
#    text    data     bss     dec     hex filename
#   xxxxx     xxx    xxxx   xxxxx    xxxx UserApp.elf
# Finished building: UserApp.bin
# Finished building: UserApp.sfb
# ✓ Firmware encrypted with AES-128-CBC
# ✓ Firmware signed with ECDSA P-256
# ✓ Secure firmware binary ready: UserApp.sfb

# 3.3 Verify signed firmware exists
ls -lh ../UserApp.sfb
# Should exist with .sfb extension

# 3.4 Verify output files
ls -lh ../Binary/
# Should contain:
#   UserApp.sfb         → Signed + encrypted + header (ready to flash!)
#   SBSFU_UserApp.bin   → Combined SBSFU + UserApp (for testing)

# 3.5 Check what's inside UserApp.sfb
file ../UserApp.sfb
hexdump -C ../UserApp.sfb | head -n 20
# First bytes should show:
#   - Magic number "SFU1"
#   - Version info
#   - Followed by encrypted firmware data

# ============================================================
# STEP 4: Flash to Device
# ============================================================

cd /Users/tohid/stm32Projects/sbsfu/st_sbsfu

# 4.1 Connect NUCLEO board via USB

# 4.2 Flash SBSFU bootloader
st-flash write Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/SBSFU.bin 0x08000000

# Expected output:
# st-flash 1.7.0
# 2026-01-31T10:00:00 INFO common.c: Loading device parameters....
# 2026-01-31T10:00:00 INFO common.c: Device connected is: G0x1 device, id 0x10006460
# 2026-01-31T10:00:00 INFO common.c: Flash size: 131072 bytes
# 2026-01-31T10:00:01 INFO common.c: Flash written: 62772 bytes

# 4.3 Reset device
# Press black RESET button on NUCLEO board

# 4.4 Verify SBSFU is running
# Connect serial console (115200 baud)
# Should see SBSFU boot messages

# ============================================================
# STEP 5: Upload UserApp (via SBSFU)
# ============================================================

# Option A: Using UART/Ymodem (from SBSFU menu)
# 1. Connect to serial console (115200 baud)
# 2. Press '1' or '2' for download menu
# 3. Send UserApp.sfb via Ymodem protocol

# Option B: Flash directly (for testing)
st-flash write Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_UserApp/STM32CubeIDE/UserApp.bin 0x08003000
# (Check linker script for correct address)
```

### Quick Build Commands

**Build everything from project root:**

```bash
#!/bin/bash
# Quick build script - save as build_all.sh

set -e  # Exit on error

PROJECT_ROOT="/Users/tohid/stm32Projects/sbsfu/st_sbsfu"
NUCLEO_PATH="Projects/NUCLEO-G071RB/Applications/1_Image"

cd "$PROJECT_ROOT"

echo "=========================================="
echo "Building SECoreBin..."
echo "=========================================="
cd "$NUCLEO_PATH/1_Image_SECoreBin/STM32CubeIDE"
bash ./prebuild.sh .
cd Debug
make clean && make all -j4
cd ..
bash ./postbuild.sh .

echo "=========================================="
echo "Building SBSFU..."
echo "=========================================="
cd "$PROJECT_ROOT/$NUCLEO_PATH/1_Image_SBSFU/STM32CubeIDE/Debug"
make clean && make all -j4

echo "=========================================="
echo "Building UserApp..."
echo "=========================================="
cd "$PROJECT_ROOT/$NUCLEO_PATH/1_Image_UserApp/STM32CubeIDE/Debug"
make clean && make all -j4

echo "=========================================="
echo "Build complete!"
echo "=========================================="
echo "SBSFU: $PROJECT_ROOT/$NUCLEO_PATH/1_Image_SBSFU/STM32CubeIDE/SBSFU.bin"
echo "UserApp: $PROJECT_ROOT/$NUCLEO_PATH/1_Image_UserApp/STM32CubeIDE/UserApp.sfb"
```

### Individual Project Commands

**SECoreBin only:**
```bash
cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE
bash ./prebuild.sh . && cd Debug && make clean && make all -j4 && cd .. && bash ./postbuild.sh .
```

**SBSFU only:**
```bash
cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/Debug
make clean && make all -j4
```

**UserApp only:**
```bash
cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_UserApp/STM32CubeIDE/Debug
make clean && make all -j4
```

---

## Flashing & Debugging

### Flashing with ST-Link Tools

**Install ST-Link:**
```bash
brew install stlink
st-info --version
```

**Flash SBSFU bootloader:**
```bash
# Full chip erase (recommended for first flash)
st-flash erase

# Flash SBSFU.bin to flash start
st-flash write Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/SBSFU.bin 0x08000000

# Verify flash
st-flash read flash_dump.bin 0x08000000 0x20000
hexdump -C flash_dump.bin | head -n 10
```

**Flash UserApp (direct - bypass SBSFU):**
```bash
# Check linker script for UserApp start address
# Typically 0x08003000 or similar

st-flash write Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_UserApp/STM32CubeIDE/UserApp.bin 0x08003000
```

### Flashing with OpenOCD

**Install OpenOCD:**
```bash
brew install openocd
openocd --version
```

**Flash using OpenOCD:**
```bash
# Start OpenOCD server
openocd -f interface/stlink.cfg -f target/stm32g0x.cfg

# In another terminal, connect with telnet
telnet localhost 4444

# OpenOCD commands:
> reset halt
> flash write_image erase Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/SBSFU.bin 0x08000000
> verify_image Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/SBSFU.bin 0x08000000
> reset run
> exit
```

**OpenOCD script (flash_sbsfu.cfg):**
```tcl
# Save as flash_sbsfu.cfg
source [find interface/stlink.cfg]
source [find target/stm32g0x.cfg]

init
reset halt
flash write_image erase Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/SBSFU.bin 0x08000000
verify_image Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/SBSFU.bin 0x08000000
reset run
shutdown
```

**Usage:**
```bash
openocd -f flash_sbsfu.cfg
```

### Debugging with GDB

**Start GDB server (choose one):**

```bash
# Option A: OpenOCD
openocd -f interface/stlink.cfg -f target/stm32g0x.cfg

# Option B: ST-Link GDB server
st-util -p 4242
```

**Connect GDB client:**
```bash
arm-none-eabi-gdb Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/Debug/SBSFU.elf

# In GDB:
(gdb) target extended-remote localhost:4242
(gdb) load
(gdb) monitor reset halt
(gdb) break main
(gdb) continue
(gdb) info registers
(gdb) backtrace
```

### VS Code Debugging

**Prerequisites:**
- Cortex-Debug extension installed
- `.vscode/launch.json` configured (see VS Code Configuration section)

**Usage:**
1. Open VS Code
2. Press `F5` or Run → Start Debugging
3. Select "Debug SBSFU (OpenOCD)" configuration
4. Debugger launches, stops at main()
5. Use debug controls: Continue (F5), Step Over (F10), Step Into (F11)

**Debug Console Commands:**
```
-exec monitor reset halt
-exec monitor flash write_image erase path/to/firmware.bin 0x08000000
-exec info registers
```

### Serial Console (UART Debug Output)

**Connect serial console to view SBSFU messages:**

```bash
# Find device
ls /dev/tty.usbmodem*

# Connect with screen
screen /dev/tty.usbmodem14203 115200

# Or use minicom
minicom -D /dev/tty.usbmodem14203 -b 115200

# Exit screen: Ctrl+A, then K
```

**Expected SBSFU boot output:**
```
===================================================================
=              (C) COPYRIGHT 2017 STMicroelectronics             =
=                                                                 =
=              Secure Boot and Secure Firmware Update             =
===================================================================

INFO: System Security Check successfully passed. Starting...
INFO: Consecutive Boot on error counter = 0
INFO: New Fw to install: Fw header @: 0800a000
INFO: Slot 0 @: 08003000 / Slot 1 @: 0800a000
INFO: Fw State: 00000000
INFO: No valid firmware detected...
```

---

## Verification & Testing

### Build Verification

**Check build outputs exist:**
```bash
# SECoreBin outputs
ls -lh Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE/Debug/SECoreBin.elf
ls -lh Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE/SECoreBin.bin
ls -lh Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/Application/Core/SE_CORE_Bin.c

# SBSFU outputs
ls -lh Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/Debug/SBSFU.elf
ls -lh Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/SBSFU.bin

# UserApp outputs
ls -lh Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_UserApp/STM32CubeIDE/Debug/UserApp.elf
ls -lh Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_UserApp/STM32CubeIDE/UserApp.bin
ls -lh Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_UserApp/STM32CubeIDE/UserApp.sfb
```

**Verify memory sizes:**
```bash
# SECoreBin should be ~20KB
arm-none-eabi-size Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE/Debug/SECoreBin.elf
#    text    data     bss     dec     hex filename
#   18014       8    2636   20658    50b2 SECoreBin.elf

# SBSFU should be ~62KB
arm-none-eabi-size Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/Debug/SBSFU.elf
#    text    data     bss     dec     hex filename
#   46900     128   15744   62772    f534 SBSFU.elf
```

**Inspect binary contents:**
```bash
# View ELF sections
arm-none-eabi-objdump -h Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/Debug/SBSFU.elf

# View symbol table
arm-none-eabi-nm -C Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/Debug/SBSFU.elf | grep SE_ReadKey

# Hexdump first 256 bytes
hexdump -C Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/SBSFU.bin | head -n 16

# Check for stack pointer and reset vector (Cortex-M)
hexdump -C Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/STM32CubeIDE/SBSFU.bin | head -n 2
# 00000000  00 80 00 20 xx xx xx 08  ....
#            ^^^^^^^^^  ^^^^^^^^^
#            Stack      Reset Vector
#            Pointer    (entry point)
```

### Runtime Verification

**After flashing SBSFU:**

1. **Check serial output:**
   - Connect at 115200 baud
   - Should see SBSFU boot messages
   - Should NOT see crash/fault messages

2. **Check LED indicators:**
   - LED should blink in pattern (check project code)
   - Solid LED may indicate boot loop

3. **Try firmware update:**
   - Press USER button to enter SBSFU menu
   - Select "Download new firmware"
   - Send UserApp.sfb via Ymodem

4. **Verify signature:**
   - SBSFU should verify UserApp signature
   - Should see "Signature verification: OK"
   - Firmware installs and boots

### Test Checklist

- [ ] All three projects build without errors
- [ ] SECoreBin.bin is ~18KB-20KB
- [ ] SBSFU.bin is ~46KB-63KB  
- [ ] SE_CORE_Bin.c contains embedded binary
- [ ] UserApp.sfb is generated with signature
- [ ] SBSFU boots and shows menu on serial
- [ ] Signature verification works
- [ ] UserApp installs and runs
- [ ] LED blinks correctly
- [ ] No hardfaults or crashes

---

## Troubleshooting

### Build Errors

**Problem: `arm-none-eabi-gcc: command not found`**

```bash
# Check if toolchain is installed
which arm-none-eabi-gcc

# If not found, install:
brew install --cask gcc-arm-embedded

# Or add to PATH
export PATH="/Applications/ARM/bin:$PATH"
```

**Problem: `undefined reference to SE_ReadKey_1`**

```bash
# Cause: se_key.s not compiled/linked
# Solution: Follow "Build Fix Instructions" section

# Quick check:
ls -lh Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE/Application/Startup/se_key.s
ls -lh Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE/Debug/Application/Startup/se_key.o

# If se_key.s doesn't exist:
cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE
bash ./prebuild.sh .
```

**Problem: `Python module not found (numpy, cryptodome, etc.)`**

```bash
# Install Python dependencies
cd Middlewares/ST/STM32_Secure_Engine/Utilities/KeysAndImages
pip3 install -r requirements.txt

# If NumPy architecture error (Apple Silicon):
pip3 uninstall numpy
pip3 install numpy --no-binary numpy
```

**Problem: `make: *** No rule to make target`**

```bash
# Clean and rebuild
cd STM32CubeIDE/Debug
make clean
rm -rf *.o *.d Application/ Drivers/ Middlewares/
make all -j4

# If still failing, regenerate makefiles from STM32CubeIDE
```

**Problem: `region 'FLASH' overflowed`**

```bash
# Firmware too large for flash memory
# Check linker script memory regions
cat STM32CubeIDE/*.ld | grep "MEMORY" -A 10

# Reduce code size:
# - Disable debug symbols in release build
# - Enable optimization (-Os)
# - Remove unused code
```

### Flashing Errors

**Problem: `st-flash: error while loading shared libraries`**

```bash
# Reinstall st-link
brew reinstall stlink

# Or install from source
git clone https://github.com/stlink-org/stlink
cd stlink
make clean
make
sudo make install
```

**Problem: `Error: ST-Link: device not found`**

```bash
# Check USB connection
system_profiler SPUSBDataType | grep -A 10 "STM"

# Check permissions (Linux)
sudo usermod -a -G dialout $USER

# Reset ST-Link
# Unplug and replug USB cable

# Update ST-Link firmware (Windows STM32CubeIDE)
```

**Problem: `Flash write failed at address 0x08000000`**

```bash
# Flash may be read-protected
# Full chip erase:
st-flash erase

# Or use OpenOCD:
openocd -f interface/stlink.cfg -f target/stm32g0x.cfg -c "init; reset halt; stm32g0x mass_erase 0; exit"
```

### Runtime Errors

**Problem: SBSFU doesn't boot (LED off, no serial output)**

```bash
# Check flashing was successful
st-flash read flash_verify.bin 0x08000000 0x20000
hexdump -C flash_verify.bin | head -n 10

# Check reset vector
# First 8 bytes should be: SP (0x20xxxxxx) and PC (0x08xxxxxx)

# Verify power supply (3.3V on NUCLEO)
# Check SWD connection
```

**Problem: SBSFU boots but rejects UserApp**

```bash
# Check signature mismatch
# Ensure UserApp was signed with same ECCKEY1.txt

# Check serial output for error:
# "Signature verification: FAILED"

# Rebuild all projects with same keys:
cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE
bash ./prebuild.sh .  # Uses existing keys
# Then rebuild SBSFU and UserApp
```

**Problem: Hardfault or crash during boot**

```bash
# Connect debugger and check fault registers
arm-none-eabi-gdb Projects/.../SBSFU/STM32CubeIDE/Debug/SBSFU.elf
(gdb) target extended-remote localhost:4242
(gdb) monitor reset halt
(gdb) continue
# Wait for fault
(gdb) backtrace
(gdb) info registers

# Common causes:
# - Stack overflow (check linker script stack size)
# - Unaligned memory access
# - Invalid function pointer
# - MPU configuration error
```

### macOS Specific Issues

**Issue: "No such file or directory: se_key.s"**
**Solution:** Run prebuild script first:
```bash
cd STM32CubeIDE
bash ./prebuild.sh .
```

**Issue: Still getting undefined reference errors**
**Solution:** Verify `se_key.o` is in objects.list and was compiled:
```bash
ls -la Debug/Application/Startup/se_key.o
grep se_key.o Debug/objects.list
```

**Issue: Python/NumPy architecture mismatch**
**Solution:** Fix Python environment (see original build error). This was the initial problem before the makefile issues.

**Issue: CRLF Line Ending Errors**

**Symptom:**
```bash
/bin/bash: -: invalid option
```

**Root Cause:** Shell scripts (*.sh) have DOS/Windows CRLF (`\r\n`) line endings instead of Unix LF (`\n`)

**Solution:**

**Option A - Using sed:**
```bash
sed -i '' 's/\r$//' prebuild.sh
sed -i '' 's/\r$//' postbuild.sh
```

**Option B - Using dos2unix (if installed):**
```bash
dos2unix prebuild.sh postbuild.sh
```

**Option C - Fix all .sh files in project:**
```bash
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec sed -i '' 's/\r$//' {} \;
```

**Issue: Script Permission Errors**

**Symptom:**
```bash
bash: ./prebuild.sh: Permission denied
```

**Root Cause:** Shell scripts lack execute permissions

**Solution:**

**Fix single script:**
```bash
chmod +x prebuild.sh
chmod +x postbuild.sh
```

**Fix all .sh files in project:**
```bash
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec chmod +x {} \;
```

**Combined macOS Setup**

Run this comprehensive setup for macOS:

```bash
#!/bin/bash
# Navigate to project root
cd /Users/tohid/stm32Projects/sbsfu/st_sbsfu

# Fix line endings for all shell scripts
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec sed -i '' 's/\r$//' {} \;

# Add execute permissions
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec chmod +x {} \;

echo "macOS platform fixes applied!"
```

### Clean Rebuild Procedure

**When in doubt, clean everything:**

```bash
#!/bin/bash
# Complete clean rebuild script

PROJECT_ROOT="/Users/tohid/stm32Projects/sbsfu/st_sbsfu"
cd "$PROJECT_ROOT"

echo "Cleaning all build artifacts..."

# Clean SECoreBin
cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE/Debug
make clean
rm -rf Application/ Drivers/ Middlewares/ *.o *.d *.elf *.bin *.map

# Clean SBSFU
cd ../../1_Image_SBSFU/STM32CubeIDE/Debug
make clean
rm -rf Application/ Drivers/ Middlewares/ *.o *.d *.elf *.bin *.map

# Clean UserApp
cd ../../1_Image_UserApp/STM32CubeIDE/Debug
make clean
rm -rf Application/ Drivers/ Middlewares/ *.o *.d *.elf *.bin *.map

# Remove generated files
cd "$PROJECT_ROOT"
rm -f Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE/Application/Startup/se_key.s
rm -f Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/Application/Core/SE_CORE_Bin.c

echo "Clean complete. Now rebuild from scratch."

# Rebuild all
bash Projects/NUCLEO-G071RB/Applications/1_Image/build_all.sh
```

---

## Platform Compatibility

- ✅ **macOS** (Apple Silicon & Intel) - Fully tested
- ✅ **Linux** - Compatible with minor adjustments
- ✅ **Windows** - Requires Git Bash or WSL

**Tested Configuration:**
- **OS**: macOS 14+ (Apple Silicon)
- **Toolchain**: GNU Tools for STM32 (13.3.rel1)
- **Make**: GNU Make 3.81+
- **Python**: Python 3.8+ with NumPy, PyCryptodome, ecdsa
- **Flash Tool**: ST-Link v1.7.0+ or OpenOCD
- **Target**: STM32G071RB (NUCLEO board, Cortex-M0+, 128KB Flash)

**Known Platform Issues:**

| Platform | Issue | Solution |
|----------|-------|----------|
| macOS | CRLF line endings in .sh files | `sed -i '' 's/\r$//' *.sh` |
| macOS | Missing execute permissions | `chmod +x *.sh` |
| macOS (Apple Silicon) | NumPy architecture mismatch | Reinstall: `pip3 install numpy --no-binary numpy` |
| Windows | Bash scripts won't run | Use Git Bash or WSL |
| Linux | ST-Link permissions | `sudo usermod -a -G dialout $USER` |
| All | Make version <3.81 | Upgrade GNU Make |

---

## Quick Reference Card

### Essential Commands

```bash
# One-time setup
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec sed -i '' 's/\r$//' {} \;
find Projects/NUCLEO-G071RB/Applications/1_Image -name "*.sh" -exec chmod +x {} \;
pip3 install -r Middlewares/ST/STM32_Secure_Engine/Utilities/KeysAndImages/requirements.txt

# Build SECoreBin
cd Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/STM32CubeIDE
bash ./prebuild.sh . && cd Debug && make clean && make all -j4 && cd .. && bash ./postbuild.sh .

# Build SBSFU
cd ../1_Image_SBSFU/STM32CubeIDE/Debug
make clean && make all -j4

# Build UserApp
cd ../../1_Image_UserApp/STM32CubeIDE/Debug
make clean && make all -j4

# Flash
st-flash write ../1_Image_SBSFU/STM32CubeIDE/SBSFU.bin 0x08000000

# Debug
st-util -p 4242
arm-none-eabi-gdb ../1_Image_SBSFU/STM32CubeIDE/Debug/SBSFU.elf
```

### File Locations

```
SECoreBin.elf     → Projects/.../1_Image_SECoreBin/STM32CubeIDE/Debug/
SECoreBin.bin     → Projects/.../1_Image_SECoreBin/STM32CubeIDE/
SE_CORE_Bin.c     → Projects/.../1_Image_SBSFU/Application/Core/
SBSFU.elf         → Projects/.../1_Image_SBSFU/STM32CubeIDE/Debug/
SBSFU.bin         → Projects/.../1_Image_SBSFU/STM32CubeIDE/
UserApp.elf       → Projects/.../1_Image_UserApp/STM32CubeIDE/Debug/
UserApp.sfb       → Projects/.../1_Image_UserApp/STM32CubeIDE/
Crypto Keys       → Projects/.../1_Image_SECoreBin/Binary/
```

### Memory Map (STM32G071RB)

```
0x08000000 - 0x08002FFF: SBSFU Bootloader + SE Core (~12 KB)
0x08003000 - 0x0800xxxx: Active Firmware Slot (UserApp)
0x0800xxxx - 0x0801FFFF: Download Firmware Slot
0x20000000 - 0x20008FFF: RAM (36 KB)
```

### VS Code Shortcuts

```
Cmd+Shift+B       → Build tasks menu
F5                → Start debugging
Shift+F5          → Stop debugging
F9                → Toggle breakpoint
F10               → Step over
F11               → Step into
Cmd+Shift+P       → Command palette
```

---

## Summary: Complete VS Code Independence Checklist

**✅ You can now work 100% without STM32CubeIDE by following these steps:**

### Initial Setup (Once)
- [x] Install ARM GCC toolchain
- [x] Install ST-Link or OpenOCD  
- [x] Install Python dependencies
- [x] Fix CRLF line endings (macOS)
- [x] Add execute permissions (macOS)
- [x] Configure VS Code tasks, launch, and IntelliSense
- [x] Verify keys exist in Binary/ folder

### Daily Development Workflow
- [x] Build from command line: `make clean && make all -j4`
- [x] Or use VS Code tasks: `Cmd+Shift+B`
- [x] Flash with `st-flash` or OpenOCD
- [x] Debug with VS Code (F5) or GDB
- [x] Monitor with serial console (115200 baud)
- [x] Apply makefile fixes if se_key.s missing

### Key Files to Understand
- [x] `.cproject` - Eclipse project config (generates makefiles)
- [x] `makefile` - Main build orchestration
- [x] `sources.mk` - Source directory list
- [x] `objects.list` - Linker object files
- [x] `prebuild.sh` - Generates se_key.s from keys
- [x] `postbuild.sh` - Signs firmware, creates .sfb

### What You DON'T Need
- ❌ STM32CubeIDE for building
- ❌ STM32CubeIDE for flashing
- ❌ STM32CubeIDE for debugging
- ❌ Eclipse workspace or project files
- ❌ Windows-only tools

### What You MIGHT Still Need IDE For
- ⚠️ Initial .ioc → code generation (STM32CubeMX standalone works)
- ⚠️ Makefile regeneration (after .cproject changes)
- ⚠️ Complex debugging scenarios (though VS Code + GDB is powerful)

**This document provides EVERYTHING you need to develop STM32 SBSFU projects entirely in VS Code with command-line tools!**

---

## Additional Resources

### Official Documentation
- [STM32CubeG0 Documentation](https://www.st.com/en/embedded-software/stm32cubeg0.html)
- [AN5056: Integration guide for SBSFU](https://www.st.com/resource/en/application_note/an5056-integration-guide-for-the-xc.pdf)
- [UM2262: Getting started with SBSFU](https://www.st.com/resource/en/user_manual/um2262-getting-started-with-the-xc.pdf)
- [UM2237: STM32CubeProgrammer](https://www.st.com/resource/en/user_manual/um2237-stm32cubeprogrammer-software-description-stmicroelectronics.pdf)

### Community Resources
- [ST Community Forums](https://community.st.com/)
- [ARM GCC Toolchain](https://developer.arm.com/downloads/-/gnu-rm)
- [OpenOCD Documentation](https://openocd.org/doc/html/index.html)
- [Cortex-Debug VS Code Extension](https://github.com/Marus/cortex-debug)

### Useful Tools
- **STM32CubeProgrammer** - GUI flash tool (alternative to st-flash)
- **STM32CubeMX** - Standalone code generator (.ioc → code)
- **J-Link** - Alternative debugger (better than ST-Link)
- **PuTTY/minicom** - Serial terminal alternatives

---

**Document Information:**
- **Created**: January 31, 2026
- **Last Updated**: January 31, 2026
- **Version**: 2.0 - Complete VS Code Guide
- **Author**: GitHub Copilot with user collaboration
- **Target**: STM32G071RB NUCLEO, 1-Image SBSFU configuration
- **Tested**: macOS Apple Silicon, GNU Tools for STM32 v13.3.rel1

---

**End of Document**
