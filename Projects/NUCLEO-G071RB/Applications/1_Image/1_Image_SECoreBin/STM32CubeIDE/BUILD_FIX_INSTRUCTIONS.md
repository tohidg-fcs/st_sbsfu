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

## Platform Compatibility

- ✅ macOS (Apple Silicon & Intel)
- ✅ Linux
- ✅ Windows (with appropriate bash shell)

**Tested on:**
- macOS with Apple Silicon
- arm-none-eabi-gcc toolchain
- GNU Make 3.81+

---

## Additional Resources

- Original project: ST SBSFU (Secure Boot and Secure Firmware Update)
- Build system: Eclipse CDT Managed Build
- Toolchain: GNU Tools for STM32

---

*Document created: January 31, 2026*
*Last updated: January 31, 2026*
