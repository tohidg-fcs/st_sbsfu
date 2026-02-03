# SBSFU MCU Porting Cheat Sheet

Quick reference guide for porting STM32 Secure Boot and Secure Firmware Update (SBSFU) projects between different STM32 microcontroller families.

---

## 📋 Pre-Porting Checklist

### 1. Analyze Target MCU Specifications

| Parameter | Source MCU | Target MCU | Action Required |
|-----------|------------|------------|-----------------|
| **Flash Size** | Check datasheet | Check datasheet | Adjust memory layout if different |
| **RAM Size** | Check datasheet | Check datasheet | Update linker scripts |
| **Flash Sectors** | Count & sizes | Count & sizes | **CRITICAL:** Update sector definitions |
| **Core** | Cortex-M? | Cortex-M? | Usually compatible within family |
| **Max Frequency** | MHz | MHz | Adjust PLL if needed |
| **Package** | Pin count | Pin count | Verify GPIO availability |

### 2. Check Peripheral Availability

**Common differences between close families:**

| Peripheral | Check Method | Impact |
|------------|--------------|--------|
| **USART/UART count** | Reference Manual | Update COM port config |
| **GPIO ports** | Datasheet pinout | Verify PA/PB/PC/etc. exist |
| **PLL structure** | RCC chapter in RM | **CRITICAL:** Check PLLR/PLLI2S/PLLSAI |
| **FSMC/FMC** | Memory chapter | Remove if not present |
| **FMPI2C** | Peripheral list | F413-specific, not on F411 |
| **External interrupts** | NVIC chapter | Adjust vector table size |

**Quick Check Commands:**
```bash
# Compare Reference Manuals
diff <(grep "PLL" RM0383_STM32F411.pdf) <(grep "PLL" RM0430_STM32F413.pdf)

# Check HAL defines
grep -r "STM32F4.*xx" Drivers/CMSIS/Device/ST/STM32F4xx/Include/
```

---

## 🔧 Step-by-Step Porting Process

### STEP 1: Memory Layout (Linker Scripts)

**Files to modify:**
- `mapping_sbsfu.ld` - SBSFU and SE RAM regions
- `mapping_fwimg.ld` - Firmware slots (SWAP, Active, Download)

**Critical Rules:**

1. **Flash Sector Alignment (MANDATORY)**
   ```
   ✅ CORRECT: Slot starts at 0x08020000 (Sector 5 boundary)
   ❌ WRONG:   Slot starts at 0x08030000 (middle of sector)
   ```

2. **Slot Size Must Equal SWAP Size**
   ```
   If SWAP = 128 KB:
   - Active Slot = 128 KB
   - Download Slot = 128 KB
   ```

3. **Update RAM End Address**
   ```ld
   /* Example: 320 KB → 128 KB RAM */
   __ICFEDIT_SB_region_RAM_end__ = 0x2001FFEF;  /* Was: 0x2003FFEF */
   ```

**Get Sector Boundaries:**
```bash
# Check target MCU sector layout in datasheet "Flash module organization" table
# STM32F411: 4×16KB + 1×64KB + 3×128KB
# STM32F413: 4×16KB + 1×64KB + 7×128KB (more sectors)
```

**Validation:**
```c
// In sfu_low_level_flash_int.c
uint32_t FlashSectorsAddress[] = {
  0x08000000U,  // Sector 0
  0x08004000U,  // Sector 1
  0x08008000U,  // Sector 2
  0x0800C000U,  // Sector 3
  0x08010000U,  // Sector 4
  0x08020000U,  // Sector 5
  0x08040000U,  // Sector 6
  0x08060000U,  // Sector 7
  0x08080000U   // End marker
};
```

---

### STEP 2: Flash Sector Definitions

**File:** `Projects/.../2_Images_SBSFU/SBSFU/App/sfu_low_level_flash_int.c`

**Update sector count and addresses:**
```c
/* Old F413 (16 sectors) → New F411 (8 sectors) */
#define FLASH_SECTOR_TOTAL  8U  /* Was: 16U */

const uint32_t FlashSectorsAddress[FLASH_SECTOR_TOTAL + 1] = {
  /* Add all sector boundaries from datasheet */
};
```

**Test alignment macro:**
```bash
# Boot SBSFU and check UART output:
# ✅ Should NOT see: "SLOT_ACTIVE_1 is not properly aligned"
# ✅ Should see: "System Security Check successfully passed"
```

---

### STEP 3: MPU Configuration

**File:** `Projects/.../2_Images_SBSFU/SBSFU/App/sfu_low_level_security.h`

**Update memory protection regions:**

```c
/* Region 2 - Flash protection */
MPU_REGION_SIZE_512KB  /* Was: MPU_REGION_SIZE_1536KB */

/* Region 5 - SRAM protection */
MPU_REGION_SIZE_256KB          /* Base size */
SFU_PROTECT_MPU_SRAML_SIZE_SREG 0xE0  /* Disable subregions to get 128KB */
```

**Subregion calculation for RAM:**
- Each subregion = Base_Size / 8
- Example: 256KB / 8 = 32KB per subregion
- To get 128KB: Disable top 4 subregions = `0b11110000` = `0xE0`

---

### STEP 4: Preprocessor Defines ⚠️ **CRITICAL**

**Files to check:**
1. `.cproject` (STM32CubeIDE project settings)
2. Generated `subdir.mk` files in `Debug/` folder

**Rule:** MCU define MUST match target exactly

| ❌ WRONG | ✅ CORRECT |
|---------|-----------|
| `-DSTM32F413xx` | `-DSTM32F411xE` |
| `-DSTM32F7` | `-DSTM32F746xx` |
| `-DSTM32L4` | `-DSTM32L476xx` |

**How to fix:**

**Method 1: Update .cproject (Recommended)**
```xml
<!-- In .cproject file -->
<option ...>
  <listOptionValue value="STM32F411xE"/>  <!-- Was: STM32F413xx -->
</option>
```

**Method 2: Update makefiles directly**
```bash
cd Debug/
find . -name "*.mk" -exec sed -i 's/-DSTM32F413xx/-DSTM32F411xE/g' {} \;
```

**Verification:**
```bash
# Check compile command includes correct define
make -n | grep "DSTM32F4"
# Should see: -DSTM32F411xE
```

---

### STEP 5: Startup Files

**Add target MCU startup file to ALL projects:**
- SECoreBin
- SBSFU  
- UserApp

**Files needed:**
```
Application/Startup/startup_stm32f411xe.s
```

**Exclude old startup:**
```xml
<!-- In .cproject -->
<entry excluding="Application/Startup/startup_stm32f413xx.s" .../>
```

**Interrupt vector differences:**
```c
// STM32F413: 102 interrupts
// STM32F411: 86 interrupts
// Missing: CAN2, UART4/5, DFSDM, etc.
```

---

### STEP 6: Clock Configuration ⚠️ **MAJOR PITFALL**

**File:** `UserApp/Src/main.c` → `SystemClock_Config()`

**Check PLL structure differences in Reference Manual:**

| MCU Family | PLL Parameters | Notes |
|------------|----------------|-------|
| **STM32F411/F401** | M, N, P, Q | **NO PLLR** |
| **STM32F413/F446** | M, N, P, Q, **R** | PLLR for additional clocks |
| **STM32F7/H7** | Different structure | Separate PLLSAI, PLLI2S |

**Example Fix (F413 → F411):**
```c
/* REMOVE THIS LINE for F411: */
// RCC_OscInitStruct.PLL.PLLR = 2;  ← CAUSES HARDFAULT!

/* F411 PLL config: */
RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
RCC_OscInitStruct.PLL.PLLM = 8;
RCC_OscInitStruct.PLL.PLLN = 200;
RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
RCC_OscInitStruct.PLL.PLLQ = 7;
/* No PLLR on F411 */
```

**HSE Configuration:**
```c
/* NUCLEO boards use ST-Link MCO */
RCC_OscInitStruct.HSEState = RCC_HSE_BYPASS;  /* 8 MHz from ST-Link */

/* Discovery boards typically use crystal */
RCC_OscInitStruct.HSEState = RCC_HSE_ON;      /* 25 MHz crystal */
```

---

### STEP 7: Peripheral Pin Mapping

**Update for target board hardware**

**Files to modify:**
1. `UserApp/Inc/main.h` - LED, Button definitions
2. `UserApp/Inc/com.h` - UART configuration
3. `SBSFU/App/sfu_low_level.c` - Status LED, security button

**Example: NUCLEO-F411RE**

```c
/* LED Configuration */
#define LED_PIN           GPIO_PIN_5   /* PA5 - Green LED */
#define LED_GPIO_PORT     GPIOA

/* Button Configuration */
#define BUTTON_PIN        GPIO_PIN_13  /* PC13 - Blue user button */
#define BUTTON_GPIO_PORT  GPIOC

/* UART (for YMODEM and console) */
#define COM_UART                  USART2      /* ST-Link Virtual COM */
#define COM_UART_TX_PIN           GPIO_PIN_2  /* PA2 */
#define COM_UART_RX_PIN           GPIO_PIN_3  /* PA3 */
#define COM_UART_TX_AF            GPIO_AF7_USART2
#define COM_UART_RX_AF            GPIO_AF7_USART2
```

**Get pin mapping from:**
- Board User Manual (UM)
- Schematic (if available)
- Pinout on st.com

---

### STEP 8: Remove Incompatible BSP

**Problem:** Discovery board BSP uses peripherals not on smaller MCUs

**Solution:** Exclude BSP compilation

```bash
# In UserApp/Debug/
rm -rf Drivers/BSP
sed -i '/BSP/d' sources.mk
sed -i '/BSP/d' objects.list
```

**Implement hardware abstraction in main.h:**
```c
/* Instead of BSP_LED_Init() */
#define BSP_LED_Init(led) do { \
  __HAL_RCC_GPIOA_CLK_ENABLE(); \
  GPIO_InitTypeDef GPIO_InitStruct = {0}; \
  GPIO_InitStruct.Pin = LED_PIN; \
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP; \
  GPIO_InitStruct.Pull = GPIO_NOPULL; \
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW; \
  HAL_GPIO_Init(LED_GPIO_PORT, &GPIO_InitStruct); \
} while(0)
```

---

## 🧪 Build & Validation

### Build Order (CRITICAL)

Always rebuild in this exact order:

```bash
1. SECoreBin   → Generates crypto keys
2. SBSFU       → Links SECoreBin, must rebuild if SECoreBin changed
3. UserApp     → Signs firmware with SECoreBin keys
```

**Verification:**
```bash
# Check timestamps are synchronized
ls -lh SECoreBin.elf SBSFU.elf UserApp.elf UserApp.sfb
# All should be within same minute
```

### Address Consistency Check

**Before flashing, verify:**

```bash
# 1. Check SBSFU compiled addresses
arm-none-eabi-nm SBSFU.elf | grep SLOT_Active_1_start
# Output: 08040000 A __ICFEDIT_SLOT_Active_1_start__

# 2. Check UserApp linked address  
arm-none-eabi-readelf -S UserApp.elf | grep .text
# Output: .text ... 08040000 ...

# 3. Check signed firmware header
hexdump -C UserApp.sfb | head -3
# Should show: 53 46 55 31 (magic "SFU1")

# 4. Verify size fits in slot
arm-none-eabi-size UserApp.elf
# text + data must be < SLOT_SIZE (e.g., 128 KB)
```

---

## 🐛 Common Issues & Solutions

### Issue #1: SLOT_ACTIVE_1 Not Properly Aligned

**Symptom:**
```
SLOT_ACTIVE_1 (8030000) is not properly aligned
```

**Root Cause:** Slot address not at flash sector boundary

**Solution:**
1. Check sector map in datasheet
2. Update `mapping_fwimg.ld` to use sector boundaries
3. Ensure all slots (SWAP, Active, Download) start at sector boundaries

---

### Issue #2: UserApp HardFault After SBSFU Launch

**Symptoms:**
```
= [SBOOT] STATE: EXECUTE USER FIRMWARE
= [SBOOT] System Security Check successfully passed. Starting...
[No output, stuck in infinite loop]
```

**Common Causes:**

1. **Wrong MCU define** → Using F413xx HAL on F411 hardware
   - Fix: Change `-DSTM32F413xx` to `-DSTM32F411xE`

2. **PLLR configuration** → F411 doesn't have PLLR register
   - Fix: Remove `RCC_OscInitStruct.PLL.PLLR = 2;`

3. **VTOR not set** → Vector table offset wrong
   - Check: `system_stm32f4xx.c` should set `SCB->VTOR = INTVECT_START;`

---

### Issue #3: CRITICAL FAILURE During FW Installation

**Symptom:**
```
New Fw to be installed from slot SLOT_DWL_1
INSTALL NEW USER FIRMWARE
HANDLE CRITICAL FAILURE
```

**Causes:**
1. **Build order issue** → SBSFU linked with old SECoreBin
   - Fix: Rebuild SECoreBin → SBSFU → UserApp

2. **Wrong file transferred** → Sent `.bin` instead of `.sfb`
   - Fix: Transfer `UserApp.sfb`, not `UserApp.bin`

3. **Address mismatch** → UserApp signed for different address than SBSFU expects
   - Fix: Verify address consistency (see validation above)

---

### Issue #4: Compile Errors - Peripheral Not Found

**Symptoms:**
```c
error: 'GPIOG' undeclared
error: 'USART6' undeclared
error: 'FSMC_xxx' undeclared
```

**Root Cause:** Using peripherals that don't exist on target MCU

**Solution:**
1. Check peripheral availability in datasheet
2. Update pin mappings to available ports (e.g., GPIOG → GPIOA)
3. Change to available UART (e.g., USART6 → USART2)
4. Remove FSMC/FMC code if not present

---

### Issue #5: Wrong Timestamp After Rebuild

**Symptom:** Build succeeds but same old firmware behavior

**Cause:** Makefile dependencies cached

**Solution:**
```bash
make clean
rm -rf Debug/*
make -j8
```

---

## 📝 Post-Porting Checklist

- [ ] All three projects compile without errors
- [ ] Build timestamps synchronized (within same minute)
- [ ] Address consistency verified (SBSFU, UserApp, .sfb all match)
- [ ] Firmware size < slot size
- [ ] SBSFU boots and shows security check passed
- [ ] UART console working at correct baud rate
- [ ] UserApp transfers via YMODEM successfully  
- [ ] UserApp installs without "CRITICAL FAILURE"
- [ ] UserApp executes and prints banner
- [ ] LED blinks on correct pin
- [ ] Button press detected
- [ ] Firmware update functionality works

---

## 🔍 Reference: Quick MCU Family Comparison

### STM32F4 Series Common Variants

| MCU | Flash | RAM | Sectors | PLLR | FSMC | FMPI2C | Notes |
|-----|-------|-----|---------|------|------|--------|-------|
| **F401** | 512KB | 96KB | 8 | ❌ | ❌ | ❌ | Entry level |
| **F411** | 512KB | 128KB | 8 | ❌ | ❌ | ❌ | NUCLEO common |
| **F413** | 1.5MB | 320KB | 16 | ✅ | ✅ | ✅ | Discovery |
| **F446** | 512KB | 128KB | 8 | ✅ | ❌ | ✅ | Extended |
| **F429** | 2MB | 256KB | 24 | ❌ | ✅ | ❌ | LCD-TFT |

### Key Differences to Check

| Feature | Where to Check | Impact if Missing |
|---------|----------------|-------------------|
| **PLLR** | RCC registers | **HardFault** if configured |
| **FSMC** | Memory controller | Compile error in BSP |
| **FMPI2C** | I2C peripherals | Compile error if used |
| **GPIOG/H/I** | GPIO chapters | Pin mapping must change |
| **USART4-8** | USART chapters | COM port config must change |
| **Flash sectors** | Flash organization | **Boot failure** if misaligned |

---

## 🛠️ Automation Scripts

### Quick Port Script Template

```bash
#!/bin/bash
# Port SBSFU to new MCU

OLD_MCU="STM32F413xx"
NEW_MCU="STM32F411xE"
PROJECT_PATH="Projects/STM32F413H-Discovery/Applications/2_Images"

echo "Porting $OLD_MCU → $NEW_MCU"

# 1. Update preprocessor defines
find "$PROJECT_PATH" -name "*.mk" -exec sed -i "s/$OLD_MCU/$NEW_MCU/g" {} \;

# 2. Update .cproject files
find "$PROJECT_PATH" -name ".cproject" -exec sed -i "s/$OLD_MCU/$NEW_MCU/g" {} \;

# 3. Clean all builds
find "$PROJECT_PATH" -name "Debug" -type d -exec make -C {} clean \;

echo "Manual steps required:"
echo "1. Update mapping_fwimg.ld for flash sectors"
echo "2. Update sfu_low_level_flash_int.c sector array"
echo "3. Update MPU configuration in sfu_low_level_security.h"
echo "4. Update peripheral pins in main.h and com.h"
echo "5. Remove PLLR from SystemClock_Config()"
echo "6. Rebuild: SECoreBin → SBSFU → UserApp"
```

---

## 📚 Essential Documents

**For each MCU, download and compare:**

1. **Datasheet (DS)** - Flash/RAM size, package, pinout
2. **Reference Manual (RM)** - Peripheral registers, memory map
3. **Programming Manual (PM)** - Cortex-M core specifics
4. **Board User Manual (UM)** - Pin connections, schematics

**Key sections to check:**
- Flash memory organization (sector layout)
- RCC registers (PLL configuration)
- GPIO port availability
- Peripheral list and differences

---

## 💡 Pro Tips

1. **Always build in order:** SECoreBin → SBSFU → UserApp
2. **Check timestamps:** All builds should be within same minute
3. **Use clean builds:** When in doubt, `make clean` everything
4. **Test incrementally:** Flash SBSFU first, verify boot before UserApp
5. **Document changes:** Keep notes on what you changed and why
6. **Backup working configs:** Before major changes, commit to git
7. **Use diff tools:** Compare working vs new MCU reference manuals
8. **Watch UART output:** Most issues show up in boot messages
9. **Don't guess addresses:** Calculate from datasheet sector layout
10. **Verify with tools:** Use `nm`, `readelf`, `hexdump` to validate

---

## 🎯 Quick Reference: File Modification Matrix

| File | What to Change | Why |
|------|----------------|-----|
| `mapping_sbsfu.ld` | RAM end addresses | Adjust for target RAM size |
| `mapping_fwimg.ld` | Slot addresses | **Flash sector alignment** |
| `sfu_low_level_flash_int.c` | Sector array | Match target sector count |
| `sfu_low_level_security.h` | MPU regions | Flash/RAM sizes |
| `.cproject` | MCU define | **Critical: HAL compatibility** |
| `Debug/*.mk` | Preprocessor defines | If .cproject doesn't regenerate |
| `main.c` | SystemClock_Config | **Remove unsupported PLL params** |
| `main.h` | LED/Button pins | Board-specific hardware |
| `com.h` | UART/GPIO pins | Board-specific hardware |
| `startup_*.s` | Add new, exclude old | Target MCU vector table |

---

## 📞 When Stuck

1. **Check UART output** - Most informative for boot issues
2. **Verify addresses** - Use nm/readelf/hexdump trinity
3. **Compare datasheets** - Side-by-side peripheral availability
4. **Check HAL version** - Ensure HAL supports target MCU
5. **Look at ST examples** - Similar MCU projects for reference
6. **Use debugger** - Step through to find HardFault location
7. **Read error messages carefully** - They're usually accurate
8. **Don't skip validation** - Address consistency check saves hours

---

**Document Version:** 1.0  
**Last Updated:** February 2026  
**Based on:** STM32F413ZHT → STM32F411RET6 porting experience

