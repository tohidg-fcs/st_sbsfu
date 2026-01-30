# Build Instructions for NUCLEO-G071RB SECoreBin

This document explains how to build the SECoreBin project using the command line without STM32CubeIDE.

## Prerequisites

### Required Tools

1. **ARM GCC Toolchain**
   ```bash
   # On Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install gcc-arm-none-eabi binutils-arm-none-eabi
   
   # Verify installation
   arm-none-eabi-gcc --version
   ```

2. **Python 3**
   ```bash
   # Usually pre-installed on Linux
   python3 --version
   
   # If not installed:
   sudo apt-get install python3
   ```

3. **Make**
   ```bash
   # Usually pre-installed on Linux
   make --version
   
   # If not installed:
   sudo apt-get install make
   ```

## Building the Project

### Quick Start

From the project directory (`1_Image_SECoreBin`), run:

```bash
make
```

This will:
1. Run the pre-build script to generate cryptographic keys
2. Compile all source files
3. Link the application
4. Generate `.elf`, `.hex`, and `.bin` files
5. Run post-build processing

### Build Output

The build artifacts will be in the `build/` directory:
- `build/SECoreBin.elf` - ELF executable with debug symbols
- `build/SECoreBin.hex` - Intel HEX format for programming
- `build/SECoreBin.bin` - Raw binary file
- `build/SECoreBin.map` - Memory map file

### Makefile Targets

- `make all` or `make` - Build everything (default)
- `make clean` - Remove all build artifacts
- `make info` - Display build configuration information
- `make prebuild` - Run only the pre-build script
- `make postbuild` - Run only the post-build script

### Build Options

**Debug Build (default):**
```bash
make DEBUG=1
```

**Release Build:**
```bash
make DEBUG=0
```

**Custom Optimization:**
```bash
make OPT=-O2
```

**Custom GCC Path:**
```bash
make GCC_PATH=/path/to/arm-toolchain/bin
```

## Build Process Details

### Pre-Build Step

The pre-build script (`STM32CubeIDE/prebuild.sh`) performs:
1. Reads cryptographic configuration from `Inc/se_crypto_config.h`
2. Processes cryptographic keys from `Binary/` directory
3. Generates `se_key.s` assembly file with embedded keys
4. Creates appropriate post-build script based on crypto scheme

### Compilation

Compiles the following components:
- **Application sources** (`Src/`)
  - `se_crypto_bootloader.c`
  - `se_low_level.c`
  
- **HAL Driver sources** (from `Drivers/STM32G0xx_HAL_Driver/`)
  - Core HAL functions
  - CRC, Flash, GPIO, RCC, PWR peripherals
  
- **Secure Engine** (from `Middlewares/ST/STM32_Secure_Engine/`)
  - `se_callgate.c`
  - `se_startup.c`

- **Assembly sources**
  - `se_key.s` (generated during pre-build)

### Linking

Links against:
- **STM32 Cryptographic Library**: `STM32CryptographicV3.1.5_CM0PLUS_GCC.a`
- **Linker Script**: `STM32G071RBTx.ld`
- Additional common linker files from `Linker_Common/STM32CubeIDE/`

### Post-Build Step

Extracts Secure Engine interface symbols for use by other components in the SBSFU system.

## Compiler Flags Used

### C Compiler Flags
- `-mcpu=cortex-m0plus` - Target Cortex-M0+ CPU
- `-mthumb` - Use Thumb instruction set
- `-mfloat-abi=soft` - Software floating point
- `-Os` - Optimize for size
- `-g3` - Maximum debug information (debug build)
- `-fdata-sections -ffunction-sections` - Enable dead code elimination
- `-Wall` - Enable all warnings
- `-DSTM32G071xx -DUSE_HAL_DRIVER` - MCU and HAL defines

### Linker Flags
- `-specs=nano.specs` - Use newlib-nano (smaller C library)
- `-Wl,--gc-sections` - Remove unused sections
- `-Wl,-Map=build/SECoreBin.map` - Generate map file

## Troubleshooting

### "Python installation missing"
Ensure Python 3 is installed and in your PATH:
```bash
which python3
python3 --version
```

### "arm-none-eabi-gcc: command not found"
Install the ARM GCC toolchain or specify the path:
```bash
make GCC_PATH=/usr/bin
```

### Missing cryptographic keys
Ensure the `Binary/` directory contains the required key files:
- `OEM_KEY_COMPANY*.bin` files for AES schemes
- `ECCKEY*.txt` files for ECC schemes

### Build fails with linker errors
Check that all library paths are correct:
- `Middlewares/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Lib/`
- `Linker_Common/STM32CubeIDE/`

## Integration with Full SBSFU System

This SECoreBin project is part of the larger SBSFU (Secure Boot and Secure Firmware Update) system. After building:

1. Build the SBSFU bootloader (`../1_Image_SBSFU/`)
2. Build the user application (`../1_Image_UserApp/`)
3. Use the appropriate scripts to combine and flash all components

## Additional Notes

- The Makefile uses relative paths, so it must be run from the `1_Image_SECoreBin/` directory
- The pre-build script determines the crypto scheme automatically from `se_crypto_config.h`
- Different crypto schemes may require different key files in the `Binary/` directory
- Generated files (`se_key.s`, `postbuild.sh`) are cleaned with `make clean`

## Reference

For more information about the SBSFU system and security configuration, refer to:
- `readme.txt` in this directory
- ST documentation for the STM32 Secure Boot and Secure Firmware Update solution
- [STM32CubeG0 firmware package documentation](https://www.st.com/en/embedded-software/stm32cubeg0.html)
