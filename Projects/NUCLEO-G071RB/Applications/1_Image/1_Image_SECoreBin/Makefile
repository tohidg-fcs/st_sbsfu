######################################
# Target
######################################
TARGET = SECoreBin

######################################
# Building variables
######################################
# Debug build?
DEBUG = 1
# Optimization
OPT = -Os

#######################################
# Paths
#######################################
# Build path
BUILD_DIR = build

# Project root (relative to this Makefile)
PROJECT_ROOT = ../../../../../

# Drivers path
DRIVERS_PATH = $(PROJECT_ROOT)/Drivers

# Middleware path
MIDDLEWARE_PATH = $(PROJECT_ROOT)/Middlewares

######################################
# Source files
######################################
# C sources
C_SOURCES = \
Src/se_crypto_bootloader.c \
Src/se_low_level.c \
STM32CubeIDE/Application/User/data_init.c \
STM32CubeIDE/Application/User/syscalls.c \
$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Src/stm32g0xx_hal.c \
$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Src/stm32g0xx_hal_cortex.c \
$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Src/stm32g0xx_hal_crc.c \
$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Src/stm32g0xx_hal_crc_ex.c \
$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Src/stm32g0xx_hal_flash.c \
$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Src/stm32g0xx_hal_flash_ex.c \
$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Src/stm32g0xx_hal_gpio.c \
$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Src/stm32g0xx_hal_rcc.c \
$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Src/stm32g0xx_hal_rcc_ex.c \
$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Src/stm32g0xx_hal_pwr.c \
$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Src/stm32g0xx_hal_pwr_ex.c \
$(MIDDLEWARE_PATH)/ST/STM32_Secure_Engine/Core/se_callgate.c \
$(MIDDLEWARE_PATH)/ST/STM32_Secure_Engine/Core/se_startup.c \
$(MIDDLEWARE_PATH)/ST/STM32_Secure_Engine/Core/se_fwimg.c \
$(MIDDLEWARE_PATH)/ST/STM32_Secure_Engine/Core/se_crypto_common.c \
$(MIDDLEWARE_PATH)/ST/STM32_Secure_Engine/Core/se_exception.c \
$(MIDDLEWARE_PATH)/ST/STM32_Secure_Engine/Core/se_user_application.c \
$(MIDDLEWARE_PATH)/ST/STM32_Secure_Engine/Core/se_utils.c

# ASM sources
ASM_SOURCES = \
STM32CubeIDE/Application/Startup/se_key.s

#######################################
# Binaries
#######################################
PREFIX = arm-none-eabi-
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)gcc
AS = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
NM = $(GCC_PATH)/$(PREFIX)nm
else
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
NM = $(PREFIX)nm
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
 
#######################################
# CFLAGS
#######################################
# CPU
CPU = -mcpu=cortex-m0plus

# FPU
FPU =

# Float-ABI
FLOAT-ABI = -mfloat-abi=soft

# MCU
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# Macros for GCC based compilers
AS_DEFS =

# C defines
C_DEFS = \
-DSTM32G071xx \
-DUSE_HAL_DRIVER \
-D_STDINT

# AS includes
AS_INCLUDES =

# C includes
C_INCLUDES = \
-IInc \
-I$(MIDDLEWARE_PATH)/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Inc \
-I$(DRIVERS_PATH)/CMSIS/Device/ST/STM32G0xx/Include \
-I$(DRIVERS_PATH)/STM32G0xx_HAL_Driver/Inc \
-I$(DRIVERS_PATH)/BSP/STM32G0xx_Nucleo \
-I$(DRIVERS_PATH)/BSP/Components/Common \
-I$(MIDDLEWARE_PATH)/ST/STM32_Secure_Engine/Core \
-I$(MIDDLEWARE_PATH)/ST/STM32_Secure_Engine/Key \
-I../1_Image_SBSFU/SBSFU/App \
-I../1_Image_SBSFU/SBSFU/Target \
-I../Linker_Common/STM32CubeIDE \
-I$(DRIVERS_PATH)/CMSIS/Include

# Compile GCC flags
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g3 -gdwarf-2
endif

# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

#######################################
# LDFLAGS
#######################################
# Link script
LDSCRIPT = STM32CubeIDE/STM32G071RBTx.ld

# Libraries
LIBS = -l:STM32CryptographicV3.1.5_CM0PLUS_GCC.a -lc -lm -lnosys
LIBDIR = \
-L$(MIDDLEWARE_PATH)/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Lib \
-L../Linker_Common/STM32CubeIDE

LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# Default action: build all
all: prebuild $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin postbuild

#######################################
# Pre-build step
#######################################
.PHONY: prebuild
prebuild:
	@echo "Running pre-build script..."
	@bash STM32CubeIDE/prebuild.sh STM32CubeIDE

#######################################
# Build the application
#######################################
# List of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))

# List of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	@echo "Compiling: $<"
	@$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	@echo "Assembling: $<"
	@$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	@echo "Linking: $@"
	@$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	@$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo "Creating HEX: $@"
	@$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo "Creating BIN: $@"
	@$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir $@

#######################################
# Post-build step
#######################################
.PHONY: postbuild
postbuild: $(BUILD_DIR)/$(TARGET).elf
	@echo "Running post-build script..."
	@if [ -f STM32CubeIDE/postbuild.sh ]; then \
		dos2unix STM32CubeIDE/postbuild.sh 2>/dev/null || sed -i 's/\r$$//' STM32CubeIDE/postbuild.sh; \
		bash STM32CubeIDE/postbuild.sh $(BUILD_DIR)/$(TARGET).elf || echo "Post-build script had warnings (non-critical)"; \
	else \
		echo "Post-build script not found (will be generated during pre-build)"; \
	fi

#######################################
# Clean up
#######################################
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -fR $(BUILD_DIR)
	@rm -f STM32CubeIDE/Application/Startup/se_key.s
	@rm -f STM32CubeIDE/postbuild.sh
	@rm -f STM32CubeIDE/crypto.txt
	@rm -f STM32CubeIDE/output.txt
	@echo "Clean complete"

#######################################
# Show info
#######################################
.PHONY: info
info:
	@echo "Target: $(TARGET)"
	@echo "MCU: STM32G071RBTx"
	@echo "Build directory: $(BUILD_DIR)"
	@echo "Optimization: $(OPT)"
	@echo "Debug: $(DEBUG)"
	@echo ""
	@echo "C Sources:"
	@for src in $(C_SOURCES); do echo "  $$src"; done
	@echo ""
	@echo "ASM Sources:"
	@for src in $(ASM_SOURCES); do echo "  $$src"; done

#######################################
# Dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)

# *** EOF ***
