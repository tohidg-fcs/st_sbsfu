# STM32 SBSFU Build Fix Instructions for VS Code / Command Line

## Problem Summary

When building the SECoreBin project using makefiles from the command line (outside STM32CubeIDE), the build fails with undefined reference errors:

```
undefined reference to `SE_ReadKey_1'
undefined reference to `SE_ReadKey_1_Pub'
```

**Root Cause:** The makefile system doesn't include the dynamically-generated assembly file `se_key.s` which is created during the prebuild phase and contains these cryptographic key functions.

---

## Solution Overview

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

## Platform Compatibility

- ✅ macOS (Apple Silicon & Intel)
- ✅ Linux
- ✅ Windows (with appropriate bash shell)

**Tested on:**
- macOS with Apple Silicon
- arm-none-eabi-gcc toolchain
- GNU Make 3.81+

**Known Issues:**
- macOS: CRLF line endings in scripts (see macOS-Specific Issues section)
- macOS: Missing execute permissions on .sh files (see above)
- Windows: May require Git Bash or WSL for shell scripts
- Cross-platform: NumPy architecture mismatch with Python (affects prebuild.sh)

---

## Additional Resources

- Original project: ST SBSFU (Secure Boot and Secure Firmware Update)
- Build system: Eclipse CDT Managed Build
- Toolchain: GNU Tools for STM32
- Target MCU: STM32G071RB (NUCLEO board, Cortex-M0+, 128KB Flash)

### Documentation References

- [STM32CubeG0 Documentation](https://www.st.com/en/embedded-software/stm32cubeg0.html)
- [AN5056: Integration guide for SBSFU](https://www.st.com/resource/en/application_note/an5056-integration-guide-for-the-xc.pdf)
- [UM2262: Getting started with SBSFU](https://www.st.com/resource/en/user_manual/um2262-getting-started-with-the-xc.pdf)

---

*Document created: January 31, 2026*
*Last updated: January 31, 2026*
