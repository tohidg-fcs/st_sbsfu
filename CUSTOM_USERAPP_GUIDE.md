# Creating Custom UserApp for SBSFU

Complete guide for developing your own application to run with STM32 Secure Boot and Secure Firmware Update (SBSFU).

---

## 📖 Table of Contents

1. [Understanding the Relationship](#understanding-the-relationship)
2. [Technical Requirements](#technical-requirements)
3. [Creating Your Custom Application](#creating-your-custom-application)
4. [Build Process](#build-process)
5. [Development Workflow](#development-workflow)
6. [Capabilities & Limitations](#capabilities--limitations)
7. [Examples](#examples)
8. [Troubleshooting](#troubleshooting)

---

## 🔗 Understanding the Relationship

### What is SBSFU (Bootloader)?

**SBSFU = Secure Boot + Secure Firmware Update**

Think of SBSFU as a security guard that:
- Verifies your application before running it
- Installs firmware updates safely
- Protects against unauthorized code
- Then **steps aside** and lets your app run

**SBSFU responsibilities:**
```
┌─────────────────────────────────────┐
│ 1. Boot sequence                    │
│    - Check RDP protection           │
│    - Verify MPU configuration       │
│    - Enable secure features         │
├─────────────────────────────────────┤
│ 2. Firmware verification            │
│    - Check signature (ECDSA)        │
│    - Decrypt if encrypted (AES)     │
│    - Validate integrity (SHA256)    │
├─────────────────────────────────────┤
│ 3. Firmware installation            │
│    - Copy Download → Active slot    │
│    - Erase old versions             │
│    - Rollback on failure            │
├─────────────────────────────────────┤
│ 4. Application launch                │
│    - Jump to verified UserApp       │
│    - Transfer control completely    │
└─────────────────────────────────────┘
```

**After jump:** SBSFU is dormant - your app runs independently!

### What is UserApp (Your Application)?

**UserApp = Your actual embedded application**

- IoT sensor node
- Motor controller
- Industrial gateway
- Smart home device
- Medical device controller
- **Any STM32 application you want!**

**UserApp responsibilities:**
```
┌─────────────────────────────────────┐
│ YOUR APPLICATION LOGIC              │
│ - Sensor reading                    │
│ - Motor control                     │
│ - Communication protocols           │
│ - User interface                    │
│ - Data processing                   │
│ - Whatever your product does!       │
└─────────────────────────────────────┘
```

### Boot Sequence Flow

```
Power On / Reset
    ↓
┌─────────────────────────────────────┐
│ SBSFU Execution                     │
│ (0x08000000 - 0x0801FFFF)          │
│                                     │
│ [SE] Crypto verification            │
│ [SBSFU] Security checks             │
│ [SBSFU] Firmware validation         │
└─────────────────────────────────────┘
    ↓ Jump to 0x08040200
┌─────────────────────────────────────┐
│ YOUR APPLICATION                    │
│ (0x08040000 - 0x0805FFFF)          │
│                                     │
│ [Your main()] → runs forever        │
│ [Your tasks] → execute               │
│ [Your peripherals] → controlled     │
└─────────────────────────────────────┘
    ↓ Request update (optional)
┌─────────────────────────────────────┐
│ Firmware Update Process              │
│                                     │
│ 1. Download new FW → Download Slot  │
│ 2. Reset device                     │
│ 3. SBSFU installs update            │
│ 4. Launch new version               │
└─────────────────────────────────────┘
```

**Key Insight:** SBSFU and UserApp are **separate programs** that run at different times!

---

## ✅ Technical Requirements

### 1. Memory Layout (MANDATORY)

Your application must respect the SBSFU memory map:

#### Flash Memory Map

```
┌────────────────────────────────────────────┐ 0x08000000
│ Secure Engine (SE)                          │ 32 KB
│ - Crypto library (isolated)                 │
├────────────────────────────────────────────┤ 0x08008000
│ SE Interface                                │ ~2 KB
├────────────────────────────────────────────┤ 0x08008900
│ SBSFU Code                                  │ ~94 KB
├────────────────────────────────────────────┤ 0x08020000
│ SWAP Area                                   │ 128 KB
│ - Temporary storage for updates            │
├────────────────────────────────────────────┤ 0x08040000
│ ╔════════════════════════════════════════╗ │
│ ║ ACTIVE SLOT #1 (YOUR APP LIVES HERE!) ║ │ 128 KB
│ ╟────────────────────────────────────────╢ │
│ ║ 0x200: Firmware Header                 ║ │ 512 bytes
│ ║   - Magic: "SFU1"                      ║ │
│ ║   - Version                            ║ │
│ ║   - Size                               ║ │
│ ║   - Signature (ECDSA)                  ║ │
│ ║   - Encryption info                    ║ │
│ ╟────────────────────────────────────────╢ │
│ ║ 0x08040200: YOUR CODE STARTS HERE     ║ │ ~127.5 KB
│ ║   - Vector table                       ║ │
│ ║   - .text (code)                       ║ │
│ ║   - .rodata (constants)                ║ │
│ ║   - .data init values                  ║ │
│ ╚════════════════════════════════════════╝ │
├────────────────────────────────────────────┤ 0x08060000
│ Download Slot #1                            │ 128 KB
│ - New firmware downloaded here             │
│ - SBSFU installs on next boot              │
└────────────────────────────────────────────┘ 0x08080000
```

#### RAM Memory Map

```
┌────────────────────────────────────────────┐ 0x20000000
│ SE Stack                                    │ 1 KB
├────────────────────────────────────────────┤ 0x20000400
│ SE RAM                                      │ 3 KB
├────────────────────────────────────────────┤ 0x20001000
│ ╔════════════════════════════════════════╗ │
│ ║ YOUR APPLICATION RAM                   ║ │ ~124 KB
│ ║ - .data (initialized variables)        ║ │
│ ║ - .bss (zero-initialized)              ║ │
│ ║ - Heap                                 ║ │
│ ║ - Stack                                ║ │
│ ╚════════════════════════════════════════╝ │
├────────────────────────────────────────────┤ 0x2001FFF0
│ FW State                                    │ 16 bytes
└────────────────────────────────────────────┘ 0x20020000
```

### 2. Linker Script Configuration

**Your application linker script must:**

```ld
/* Memory regions for STM32F411 with SBSFU */
MEMORY
{
  /* Your code starts AFTER 512-byte header */
  FLASH (rx)  : ORIGIN = 0x08040200, LENGTH = 130560  /* 128KB - 512B */
  
  /* Your RAM (SBSFU reserves first 4KB) */
  RAM (rwx)   : ORIGIN = 0x20001000, LENGTH = 124K
}

/* Define vector table location */
ENTRY(Reset_Handler)
__ICFEDIT_intvec_start__ = 0x08040200;

/* Use provided mapping for slot boundaries */
INCLUDE "mapping_fwimg.ld"  /* Defines SLOT addresses */
```

**Important addresses:**
- `SLOT_Active_1_start` = 0x08040000 (slot boundary)
- `INTVECT_START` = 0x08040200 (your code entry)
- Header space = 0x200 (512 bytes)

### 3. Vector Table Relocation

**File:** `Src/system_stm32f4xx.c`

```c
#include "stm32f4xx.h"

/* Defined in linker script */
extern uint32_t __ICFEDIT_intvec_start__;
#define INTVECT_START ((uint32_t)&__ICFEDIT_intvec_start__)

void SystemInit(void)
{
  /* Enable FPU if using floating point */
#if (__FPU_PRESENT == 1) && (__FPU_USED == 1)
  SCB->CPACR |= ((3UL << 10*2)|(3UL << 11*2));
#endif
  
  /* Reset RCC clock configuration to default */
  RCC->CR |= (uint32_t)0x00000001;
  RCC->CFGR = 0x00000000;
  RCC->CR &= (uint32_t)0xFEF6FFFF;
  RCC->PLLCFGR = 0x24003010;
  RCC->CR &= (uint32_t)0xFFFBFFFF;
  RCC->CIR = 0x00000000;
  
  /* ╔═══════════════════════════════════════════════════╗ */
  /* ║ CRITICAL: Relocate vector table to your app      ║ */
  /* ╚═══════════════════════════════════════════════════╝ */
  SCB->VTOR = INTVECT_START;  /* 0x08040200 */
  
  /* Configure external memory if needed (FSMC/FMC) */
#ifdef DATA_IN_ExtSRAM
  SystemInit_ExtMemCtl();
#endif
}
```

**Why this matters:**
- Default VTOR = 0x08000000 (SBSFU location)
- Your interrupts = 0x08040200 (UserApp location)
- **Without relocation:** ISRs call wrong addresses → HardFault!

### 4. Watchdog Handling

SBSFU may enable Independent Watchdog (IWDG):

```c
void main(void)
{
  HAL_Init();
  SystemClock_Config();
  
  /* ╔═══════════════════════════════════════════════════╗ */
  /* ║ IMPORTANT: Reload watchdog if SBSFU enabled it    ║ */
  /* ╚═══════════════════════════════════════════════════╝ */
  WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);
  
  /* Your initialization */
  MyApp_Init();
  
  /* Main loop */
  while (1) {
    MyApp_Run();
    
    /* Periodic watchdog reload - adjust timing to your needs */
    WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);
  }
}
```

**Without reload:** Device resets after ~2 seconds!

### 5. Size Constraints

**Maximum application size:**

```
For 128 KB Active Slot:
────────────────────────────────────────
Total slot size:        128 KB (131,072 bytes)
- Firmware header:      512 bytes
────────────────────────────────────────
Available for code:     130,560 bytes (~127.5 KB)
```

**Check your size:**
```bash
arm-none-eabi-size YourApp.elf
   text    data     bss     dec     hex filename
  24000     200    8000   32200    7dd8 YourApp.elf

# text + data must be < 130,560 bytes
# bss doesn't count (RAM only)
```

**If you exceed size:**
- Increase slot size in `mapping_fwimg.ld` (must maintain sector alignment!)
- Enable `-Os` optimization
- Remove unused libraries
- Use link-time optimization (LTO)

### 6. Firmware Header Format

**Generated automatically by postbuild script:**

```
Offset  Size  Field                 Description
──────────────────────────────────────────────────────────────────
0x000   4     Magic                 "SFU1" (0x53465531)
0x004   4     Image Length          Size of code + data
0x008   4     Partial Image Length  For chunked updates
0x00C   4     Version               Major.Minor.Patch
0x010   4     Date                  Build timestamp
0x014   64    Signature (ECDSA)     NIST P-256 signature
0x054   16    IV                    AES-CBC initialization vector
0x064   412   Reserved              Future use / padding
──────────────────────────────────────────────────────────────────
Total:  512 bytes (0x200)
```

**You don't create this manually** - postbuild.sh generates it!

---

## 🛠️ Creating Your Custom Application

### Method 1: Modify Existing UserApp (Recommended for Beginners)

**Advantages:**
- ✅ Linker script already configured
- ✅ Postbuild process set up
- ✅ VTOR relocation in place
- ✅ Known working configuration

**Steps:**

1. **Keep the project structure:**
   ```
   2_Images_UserApp/
   ├── Inc/
   │   ├── main.h              ← Your app header
   │   ├── stm32f4xx_hal_conf.h
   │   └── stm32f4xx_it.h      ← Your interrupt handlers
   ├── Src/
   │   ├── main.c              ← YOUR APPLICATION CODE
   │   ├── stm32f4xx_it.c      ← Your ISRs
   │   └── system_stm32f4xx.c  ← Keep VTOR setup!
   ├── STM32CubeIDE/
   │   ├── .cproject
   │   └── STM32F411RETx_FLASH.ld  ← Keep this!
   └── Binary/
       └── postbuild.sh        ← Keep this!
   ```

2. **Replace application code in `main.c`:**
   ```c
   int main(void)
   {
     /* Keep HAL init */
     HAL_Init();
     SystemClock_Config();
     
     /* Keep watchdog reload */
     WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);
     
     /* ═════════════════════════════════════════ */
     /* YOUR APPLICATION STARTS HERE              */
     /* ═════════════════════════════════════════ */
     
     MyApp_Init();
     
     while (1) {
       MyApp_ProcessSensors();
       MyApp_Communicate();
       MyApp_ControlActuators();
       
       WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);
     }
   }
   ```

3. **Remove unused files (optional):**
   - `fw_update_app.c` - YMODEM download menu (if you don't need it)
   - `test_protections.c` - Demo code
   - `se_user_code.c` - SE interface examples (if not using crypto)
   - `ymodem.c` - File transfer protocol
   
   **Keep:**
   - `common.c` - Utility functions
   - `flash_if.c` - Flash operations (if doing updates)
   - `sfu_app_new_image.c` - Update request interface

4. **Update `.cproject` if adding files:**
   - Right-click project → Refresh
   - New files auto-detected

5. **Build and test:**
   ```bash
   cd STM32CubeIDE/Debug
   make clean
   make -j8
   # Generates YourApp.sfb automatically
   ```

### Method 2: Fresh STM32CubeMX Project (Advanced)

**Advantages:**
- ✅ Start from scratch with your exact peripherals
- ✅ Clean project structure
- ✅ Full control over configuration

**Steps:**

**Step 1: Create CubeMX Project**

1. Open STM32CubeMX
2. Select MCU: **STM32F411RET6**
3. Configure peripherals for your application
4. Project Settings:
   - Toolchain: **STM32CubeIDE**
   - Project Name: **MyCustomApp**
5. Generate Code

**Step 2: Copy Critical Files from SBSFU UserApp**

```bash
# From your working SBSFU UserApp project
SBSFU_UserApp="path/to/2_Images_UserApp"
MyApp="path/to/MyCustomApp"

# Copy linker script
cp $SBSFU_UserApp/STM32CubeIDE/STM32F411RETx_FLASH.ld $MyApp/STM32CubeIDE/

# Copy mapping files
cp $SBSFU_UserApp/../Linker_Common/STM32CubeIDE/mapping_*.ld $MyApp/STM32CubeIDE/

# Copy postbuild script
cp $SBSFU_UserApp/Binary/postbuild.sh $MyApp/Binary/
chmod +x $MyApp/Binary/postbuild.sh
```

**Step 3: Modify Linker Script**

Edit `STM32CubeIDE/STM32F411RETx_FLASH.ld`:

```ld
/* Include SBSFU memory mapping */
INCLUDE "mapping_fwimg.ld"

/* Memory regions */
MEMORY
{
  /* Code starts at 0x08040200 (after header) */
  FLASH (rx) : ORIGIN = 0x08040200, LENGTH = 130560
  
  /* RAM starts after SBSFU reserved area */
  RAM (rwx)  : ORIGIN = 0x20001000, LENGTH = 124K
}

/* Entry point */
ENTRY(Reset_Handler)

/* Vector table location */
__ICFEDIT_intvec_start__ = 0x08040200;

/* Rest of linker script (sections, etc.) */
/* ... keep CubeMX generated content ... */
```

**Step 4: Update system_stm32f4xx.c**

Add to `Src/system_stm32f4xx.c`:

```c
/* After includes, add: */
extern uint32_t __ICFEDIT_intvec_start__;
#define INTVECT_START ((uint32_t)&__ICFEDIT_intvec_start__)

/* In SystemInit(), add after clock config: */
void SystemInit(void)
{
  /* ... existing clock/FPU config ... */
  
  /* Relocate vector table */
  SCB->VTOR = INTVECT_START;
}
```

**Step 5: Configure Postbuild**

In STM32CubeIDE:
1. Project Properties → C/C++ Build → Settings
2. Build Steps → Post-build steps
3. Command:
   ```bash
   arm-none-eabi-objcopy -O binary "${BuildArtifactFileBaseName}.elf" "../${BuildArtifactFileBaseName}.bin"
   arm-none-eabi-size "${BuildArtifactFileName}"
   "../Binary/postbuild.sh" "../" "${BuildArtifactFileName}" "../${BuildArtifactFileBaseName}.bin" "1" "1"
   ```

**Step 6: Test Build**

```bash
cd MyCustomApp/STM32CubeIDE/Debug
make
# Should generate:
# - MyCustomApp.elf
# - MyCustomApp.bin
# - ../Binary/MyCustomApp.sfb  ← This is what you flash!
```

---

## 🔨 Build Process

### Understanding the Build Chain

```
Your Source Code (.c, .h)
        ↓ [Compiler]
Object Files (.o)
        ↓ [Linker]
ELF File (.elf)
        ↓ [objcopy]
Binary File (.bin) - Raw code + data
        ↓ [postbuild.sh]
    ┌───────────────────────┐
    │ Python prepareimage.py│
    │ - Add 512B header     │
    │ - Sign with ECDSA     │
    │ - Encrypt with AES    │
    │ - Pad to slot size    │
    └───────────────────────┘
        ↓
Signed Firmware Bundle (.sfb)
        ↓ [YMODEM Transfer]
SBSFU Download Slot
        ↓ [Next Boot]
SBSFU Active Slot → Execution!
```

### Postbuild Script Breakdown

**File:** `Binary/postbuild.sh`

```bash
#!/bin/bash

# Parameters
PROJECT=$1        # "../"
EXECUTABLE=$2     # "MyApp.elf"
BINARY=$3         # "../MyApp.bin"
IMAGE_NUMBER=$4   # "1"
NB_IMAGES=$5      # "1"

# Find prepareimage.py from SECoreBin
SCRIPT=$(find ../../ -name "prepareimage.py" | head -1)
KEY_DIR=$(dirname $SCRIPT)

cd $(dirname $SCRIPT)

# Sign and encrypt the firmware
python3 prepareimage.py sign \
  -k "$KEY_DIR/ECCKEY$IMAGE_NUMBER.txt" \        # ECDSA private key
  --encrypt "$KEY_DIR/AES_CBC_KEY.bin" \         # AES encryption key
  --iv "$KEY_DIR/AES_CBC_IV.bin" \               # AES IV
  -i "$BINARY" \                                  # Input: raw binary
  -o "$BINARY.sfb" \                             # Output: signed bundle
  --header-size 0x200 \                          # 512 byte header
  --slot-size 0x20000 \                          # 128 KB slot
  --pad \                                        # Pad to slot size
  --version 1.0.1                                # Firmware version

# Copy to Binary folder
cp "$BINARY.sfb" "$PROJECT/Binary/$(basename ${BINARY%.bin}).sfb"

echo "✓ Generated: $(basename ${BINARY%.bin}).sfb"
```

### Manual Signing (Alternative)

If postbuild fails, sign manually:

```bash
cd Projects/.../2_Images_SECoreBin/Binary

python3 prepareimage.py sign \
  -k ECCKEY1.txt \
  --encrypt AES_CBC_KEY.bin \
  --iv AES_CBC_IV.bin \
  -i ../../2_Images_UserApp/Binary/MyApp.bin \
  -o ../../2_Images_UserApp/Binary/MyApp.sfb \
  --header-size 0x200 \
  --slot-size 0x20000 \
  --pad \
  --version 1.0.1

# Verify signature
hexdump -C ../../2_Images_UserApp/Binary/MyApp.sfb | head -3
# Should start with: 53 46 55 31 (magic "SFU1")
```

---

## 💻 Development Workflow

### Initial Setup (One Time)

```bash
# 1. Build and flash SBSFU
cd Projects/.../2_Images_SECoreBin/STM32CubeIDE
bash ./prebuild.sh .
# Build SECoreBin in IDE

cd ../../2_Images_SBSFU/STM32CubeIDE/Debug
make clean && make -j8

# Flash SBSFU
openocd -f board/st_nucleo_f4.cfg \
  -c "program SBSFU.elf verify reset exit"

# 2. SBSFU now running - shows prompt on UART
```

### Iterative Development

**Fast Development Cycle (bypass YMODEM):**

```bash
# 1. Modify your application code
vim MyApp/Src/main.c

# 2. Build
cd MyApp/STM32CubeIDE/Debug
make

# 3. Flash DIRECTLY to Active Slot (development only!)
openocd -f board/st_nucleo_f4.cfg \
  -c "program ../Binary/MyApp.sfb 0x08040000 verify" \
  -c "reset run" \
  -c "exit"

# 4. Test immediately - no YMODEM needed
# 5. Repeat steps 1-4 for rapid iteration
```

**Production-Like Testing (via YMODEM):**

```bash
# 1. Build your app
cd MyApp/STM32CubeIDE/Debug
make
# Generates MyApp.sfb

# 2. Connect to SBSFU UART (115200 baud)
screen /dev/tty.usbmodem* 115200

# 3. Trigger download in SBSFU menu
# Press '1' for "Download new firmware"

# 4. Send file via YMODEM
# Ctrl+A : (colon) then type:
exec !! sz --ymodem ../Binary/MyApp.sfb

# 5. SBSFU installs and boots new version
```

### Version Management

**Track firmware versions in header:**

```bash
# Edit version before release
vim MyApp/Binary/postbuild.sh

# Change --version parameter:
--version 1.2.3    # Major.Minor.Patch

# Build
make

# Version embedded in .sfb header
hexdump -C MyApp.sfb | grep -A1 "SFU1"
```

**Check running version:**

```c
/* In your app, read version from header */
typedef struct {
  uint32_t magic;
  uint32_t image_length;
  uint32_t partial_length;
  uint32_t version;  /* 0x01020300 = v1.2.3 */
  // ...
} FWImageHeader;

const FWImageHeader *header = (FWImageHeader*)0x08040000;
uint8_t major = (header->version >> 24) & 0xFF;
uint8_t minor = (header->version >> 16) & 0xFF;
uint8_t patch = (header->version >> 8) & 0xFF;

printf("Running firmware v%d.%d.%d\n", major, minor, patch);
```

---

## 🎯 Capabilities & Limitations

### ✅ What Your UserApp CAN Do

**Full STM32 Peripheral Access:**
- ✅ All GPIO ports
- ✅ Timers (PWM, input capture, etc.)
- ✅ UART/USART communication
- ✅ SPI, I2C, I3C
- ✅ ADC, DAC
- ✅ DMA
- ✅ USB (if available on MCU)
- ✅ Ethernet (if available)
- ✅ CAN/CAN-FD
- ✅ External interrupts
- ✅ RTC, watchdogs
- ✅ Low-power modes

**Software Capabilities:**
- ✅ FreeRTOS or other RTOS
- ✅ Networking stacks (LwIP, etc.)
- ✅ File systems (FatFS, LittleFS)
- ✅ Protocol implementations (Modbus, MQTT, etc.)
- ✅ AI/ML inference (TensorFlow Lite, etc.)
- ✅ DSP operations
- ✅ Bootloader interaction (firmware updates)
- ✅ Any standard C/C++ code

**Secure Engine Features (Optional):**
```c
#include "se_interface_application.h"

/* Cryptographic operations */
SE_StatusTypeDef status;

// SHA-256 hash
status = SE_SHA256_Init(&ctx);
SE_SHA256_Append(&ctx, data, len);
SE_SHA256_Finish(&ctx, hash);

// AES encryption
status = SE_Encrypt_AES_CBC(&ctx, plaintext, ciphertext, len);

// Signature verification
status = SE_VerifySignature(&signature, data, len);

// Secure key storage
uint8_t key[32];
SE_GetKey(SE_KEY_1, key);
```

### 🚫 What Your UserApp CANNOT Do

**Memory Restrictions:**
- ❌ Write to SBSFU memory (0x08000000-0x0801FFFF) - **MPU protected**
- ❌ Execute code from RAM (unless MPU reconfigured)
- ❌ Access SE directly (must use SE_Interface)
- ❌ Modify option bytes (RDP, WRP) - **Privileged only**

**Size Limitations:**
- ❌ Exceed Active Slot size (128 KB in this example)
- ❌ Use RAM reserved for SBSFU (first 4 KB)

**Security Constraints:**
- ❌ Run without valid signature (SBSFU won't boot it)
- ❌ Tamper with firmware header (breaks signature)
- ❌ Bypass RDP protection

**Practical Impacts:**

These restrictions actually **don't limit normal applications** much:
- You have 127 KB flash - plenty for most apps
- You have 124 KB RAM - sufficient for complex tasks
- SE interface provides all crypto you need
- SBSFU protection is transparent to your app

---

## 📚 Examples

### Example 1: Minimal Blinky

**Simplest possible SBSFU-compatible application:**

```c
/* main.c - Minimal application */
#include "stm32f4xx_hal.h"

extern uint32_t __ICFEDIT_intvec_start__;
#define INTVECT_START ((uint32_t)&__ICFEDIT_intvec_start__)

void SystemClock_Config(void);

int main(void)
{
  HAL_Init();
  SystemClock_Config();
  
  /* Reload watchdog */
  WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);
  
  /* Initialize LED */
  __HAL_RCC_GPIOA_CLK_ENABLE();
  GPIO_InitTypeDef gpio = {
    .Pin = GPIO_PIN_5,
    .Mode = GPIO_MODE_OUTPUT_PP,
    .Pull = GPIO_NOPULL,
    .Speed = GPIO_SPEED_FREQ_LOW
  };
  HAL_GPIO_Init(GPIOA, &gpio);
  
  /* Blink forever */
  while (1) {
    HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
    HAL_Delay(500);
    WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);
  }
}

void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_BYPASS;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 8;
  RCC_OscInitStruct.PLL.PLLN = 200;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 7;
  HAL_RCC_OscConfig(&RCC_OscInitStruct);

  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_SYSCLK|RCC_CLOCKTYPE_HCLK|
                                RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
  HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_3);
}

/* system_stm32f4xx.c */
void SystemInit(void)
{
  SCB->CPACR |= ((3UL << 10*2)|(3UL << 11*2));
  SCB->VTOR = INTVECT_START;  /* CRITICAL! */
}
```

**Build:** 2-3 KB flash, boots in 50ms

### Example 2: UART Echo with Firmware Update

```c
/* main.c - UART application with update capability */
#include "stm32f4xx_hal.h"
#include "sfu_app_new_image.h"

UART_HandleTypeDef huart2;

void SystemClock_Config(void);
void UART_Init(void);

int main(void)
{
  HAL_Init();
  SystemClock_Config();
  WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);
  
  UART_Init();
  
  printf("\r\n=== My UART Application v1.0 ===\r\n");
  printf("Press 'U' for firmware update\r\n");
  
  uint8_t rx_byte;
  
  while (1) {
    /* Echo received characters */
    if (HAL_UART_Receive(&huart2, &rx_byte, 1, 100) == HAL_OK) {
      HAL_UART_Transmit(&huart2, &rx_byte, 1, 100);
      
      /* Trigger firmware update */
      if (rx_byte == 'U' || rx_byte == 'u') {
        printf("\r\nChecking for new firmware...\r\n");
        
        /* Request SBSFU to install update on next boot */
        SFU_APP_InstallAtNextReset(FW_IMAGE_1);
        
        printf("Rebooting to apply update...\r\n");
        HAL_Delay(1000);
        HAL_NVIC_SystemReset();
      }
    }
    
    WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);
  }
}

void UART_Init(void)
{
  __HAL_RCC_USART2_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();
  
  GPIO_InitTypeDef gpio = {
    .Pin = GPIO_PIN_2 | GPIO_PIN_3,
    .Mode = GPIO_MODE_AF_PP,
    .Pull = GPIO_NOPULL,
    .Speed = GPIO_SPEED_FREQ_HIGH,
    .Alternate = GPIO_AF7_USART2
  };
  HAL_GPIO_Init(GPIOA, &gpio);
  
  huart2.Instance = USART2;
  huart2.Init.BaudRate = 115200;
  huart2.Init.WordLength = UART_WORDLENGTH_8B;
  huart2.Init.StopBits = UART_STOPBITS_1;
  huart2.Init.Parity = UART_PARITY_NONE;
  huart2.Init.Mode = UART_MODE_TX_RX;
  HAL_UART_Init(&huart2);
}

/* Retarget printf to UART */
int _write(int file, char *ptr, int len)
{
  HAL_UART_Transmit(&huart2, (uint8_t*)ptr, len, 1000);
  return len;
}
```

### Example 3: Sensor Application with Crypto

```c
/* main.c - Secure sensor data transmission */
#include "stm32f4xx_hal.h"
#include "se_interface_application.h"

ADC_HandleTypeDef hadc1;

void Sensor_Init(void);
uint16_t Sensor_Read(void);
void SendSecureData(uint8_t *data, uint16_t len);

int main(void)
{
  HAL_Init();
  SystemClock_Config();
  WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);
  
  Sensor_Init();
  
  while (1) {
    /* Read sensor every second */
    uint16_t sensor_value = Sensor_Read();
    
    /* Prepare data packet */
    uint8_t data[16];
    data[0] = 0x01;  /* Sensor ID */
    data[1] = (sensor_value >> 8) & 0xFF;
    data[2] = sensor_value & 0xFF;
    /* ... add timestamp, etc. ... */
    
    /* Sign data using Secure Engine */
    uint8_t signature[64];
    SE_StatusTypeDef status;
    status = SE_SignData(data, sizeof(data), signature);
    
    if (status == SE_SUCCESS) {
      /* Transmit signed data */
      SendSecureData(data, sizeof(data));
      // SendSignature(signature);
    }
    
    HAL_Delay(1000);
    WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);
  }
}
```

---

## 🐛 Troubleshooting

### Issue #1: Application Doesn't Boot

**Symptoms:**
```
= [SBOOT] STATE: EXECUTE USER FIRMWARE
= [SBOOT] System Security Check successfully passed. Starting...
[Nothing happens]
```

**Possible Causes:**

1. **Vector table not relocated**
   ```c
   /* Check in system_stm32f4xx.c */
   void SystemInit(void) {
     SCB->VTOR = INTVECT_START;  /* Must be 0x08040200 */
   }
   ```

2. **Wrong entry point address**
   ```bash
   # Verify in ELF file
   arm-none-eabi-readelf -h YourApp.elf | grep Entry
   # Should show: Entry point address: 0x80402xx
   ```

3. **Linker script wrong**
   ```ld
   /* Check FLASH origin */
   FLASH (rx) : ORIGIN = 0x08040200, LENGTH = 130560
   ```

### Issue #2: HardFault During Execution

**Debug steps:**

```bash
# 1. Build with debug symbols
make DEBUG=1

# 2. Check crash location
arm-none-eabi-gdb YourApp.elf
(gdb) target remote localhost:3333
(gdb) where
# Shows call stack at crash

# 3. Common causes:
# - Stack overflow (increase stack size in linker)
# - Uninitialized peripheral
# - Wrong interrupt handler
# - RAM overflow (bss too large)
```

**Check memory usage:**
```bash
arm-none-eabi-size YourApp.elf
   text    data     bss     dec     hex filename
  24000     200   50000   74200   121d8 YourApp.elf
                   ^^^^^
            If > 124KB → Overflow!
```

### Issue #3: CRITICAL FAILURE During Install

**SBSFU can't install firmware:**

```bash
# 1. Verify .sfb file structure
hexdump -C YourApp.sfb | head -5
# First 4 bytes MUST be: 53 46 55 31 (magic "SFU1")

# 2. Check signature
# Rebuild from scratch
cd SECoreBin/STM32CubeIDE
bash ./prebuild.sh .
# Build SECoreBin
cd ../../SBSFU/STM32CubeIDE/Debug
make clean && make
cd ../../UserApp/STM32CubeIDE/Debug
make clean && make

# 3. Verify .sfb size
ls -lh ../Binary/YourApp.sfb
# Should be exactly 128 KB (131,072 bytes) if padded
```

### Issue #4: Watchdog Reset Loop

**Device keeps resetting:**

```c
/* Add more frequent watchdog reloads */
void main(void) {
  HAL_Init();
  WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);  /* Right after init */
  
  SystemClock_Config();
  WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);  /* After slow operations */
  
  MyPeripheral_Init();
  WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);
  
  while (1) {
    MyTask();
    WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);  /* Every loop */
  }
}
```

### Issue #5: Size Exceeds Slot

**text + data > 130 KB:**

**Solutions:**

1. **Enable optimization:**
   ```bash
   # In makefile or .cproject
   CFLAGS += -Os  # Optimize for size
   ```

2. **Remove unused code:**
   ```bash
   # Link-time optimization
   CFLAGS += -flto
   LDFLAGS += -flto
   ```

3. **Check what's taking space:**
   ```bash
   arm-none-eabi-nm --size-sort -C -r YourApp.elf | head -20
   # Shows largest symbols
   ```

4. **Increase slot size (requires SBSFU rebuild):**
   ```ld
   /* In mapping_fwimg.ld - if flash available */
   /* Change 128KB slots to 256KB (requires sector 8 on larger F4) */
   ```

---

## 📖 Reference: SE Interface API

**Available cryptographic functions in your UserApp:**

```c
#include "se_interface_application.h"

/* SHA-256 Hashing */
SE_StatusTypeDef SE_SHA256_Init(SE_SHA256ctx_stt *ctx);
SE_StatusTypeDef SE_SHA256_Append(SE_SHA256ctx_stt *ctx, 
                                  const uint8_t *data, int32_t len);
SE_StatusTypeDef SE_SHA256_Finish(SE_SHA256ctx_stt *ctx, uint8_t *hash);

/* AES Encryption/Decryption */
SE_StatusTypeDef SE_Encrypt_AES_CBC(SE_AESCBCctx_stt *ctx,
                                    const uint8_t *plaintext,
                                    uint8_t *ciphertext, int32_t len);
SE_StatusTypeDef SE_Decrypt_AES_CBC(SE_AESCBCctx_stt *ctx,
                                    const uint8_t *ciphertext,
                                    uint8_t *plaintext, int32_t len);

/* ECDSA Signature */
SE_StatusTypeDef SE_SignData(const uint8_t *data, int32_t len,
                             uint8_t *signature);
SE_StatusTypeDef SE_VerifySignature(const uint8_t *signature,
                                    const uint8_t *data, int32_t len);

/* Random Number Generation */
SE_StatusTypeDef SE_GetRandomNumber(uint8_t *random, int32_t len);

/* Secure Key Access */
SE_StatusTypeDef SE_GetKey(SE_KeyIdx keyIdx, uint8_t *key);
```

**Example usage:**
```c
/* Hash some data */
SE_SHA256ctx_stt ctx;
uint8_t hash[32];

SE_SHA256_Init(&ctx);
SE_SHA256_Append(&ctx, mydata, sizeof(mydata));
SE_SHA256_Finish(&ctx, hash);

/* Now 'hash' contains SHA-256 of mydata */
```

---

## 🎓 Summary

**Key Points:**

1. **UserApp = Your Application**
   - Can be anything that fits memory constraints
   - Full peripheral access
   - Runs independently after SBSFU verifies it

2. **Critical Requirements:**
   - Linker script: FLASH origin = 0x08040200
   - System init: Set SCB->VTOR = 0x08040200
   - Watchdog: Reload IWDG periodically
   - Size: text + data < 130 KB
   - Signed: Build generates .sfb with valid header

3. **Development Flow:**
   - Flash SBSFU once
   - Iterate on UserApp
   - Transfer .sfb via YMODEM or direct flash
   - Test and debug

4. **You Have Full Control:**
   - Choose any application architecture
   - Use any peripherals
   - Implement any protocol
   - Optional: Use SE for crypto
   - Optional: Support OTA updates

**Remember:** SBSFU is just a secure launcher. Your application runs exactly like a normal STM32 program, just with a different start address!

---

**Document Version:** 1.0  
**Last Updated:** February 2026  
**For:** STM32F411RET6 SBSFU Port

