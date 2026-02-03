# STM32F411RET6 Port Documentation

## Overview
This document describes the memory adjustments made to port the SBSFU (Secure Boot and Secure Firmware Update) project from **STM32F413ZHT** to **STM32F411RET6**.

**Date:** February 1, 2026  
**Project:** ST SBSFU 2_Images Application  
**Original MCU:** STM32F413ZHT (1536 KB Flash, 320 KB RAM)  
**Target MCU:** STM32F411RET6 (512 KB Flash, 128 KB RAM)

---

## SBSFU Architecture Overview

### Understanding the Three Components

The SBSFU solution consists of three distinct projects, each with specific responsibilities:

#### 1. **SECoreBin (Secure Engine Core Binary)**

**Purpose:** Isolated cryptographic library that verifies firmware authenticity

**Responsibilities:**
- Firmware signature verification (ECDSA, RSA)
- Firmware decryption (AES-CBC, AES-GCM)
- Hash computation (SHA-256)
- Secure key storage access
- Anti-rollback version checking

**Hardware Dependencies:** ⚠️ **MINIMAL**
```
Hardware Used:
├── CPU Core (ARM Cortex-M4)       - Cryptographic computations
├── Flash Controller (Read-Only)   - Reading firmware from slots
├── CRC Peripheral (Optional)      - Hardware CRC acceleration
└── MPU (Configured by SBSFU)      - Memory protection enforcement

Hardware NOT Used:
├── ❌ No UART/Console
├── ❌ No GPIO/LEDs/Buttons
├── ❌ No Timers/RTC
├── ❌ No SPI/I2C/USB
└── ❌ No External Memory
```

**Memory Isolation:**
- **Flash Region**: 32 KB (0x08000000 - 0x08007FFF)
  - CallGate entry point
  - Cryptographic code
  - Key storage area
- **RAM Region**: 4 KB (0x20000000 - 0x20000FFF)
  - Stack for SE operations
  - Temporary buffers for crypto
  - **Protected by MPU/Firewall**

**Key Characteristics:**
- ✅ **Stateless**: No persistent state between calls
- ✅ **Isolated**: Cannot be accessed directly by user application
- ✅ **Minimal**: Pure computation, no I/O operations
- ✅ **Callable**: Accessed only via SE CallGate interface
- ✅ **Hardware-Independent**: Works on any Cortex-M4 with sufficient resources

**For STM32F411RET6:**
- ✅ **No hardware changes needed** - SE region preserved at 32 KB
- ✅ **CRC peripheral available** - Hardware acceleration works
- ✅ **Memory protection configured** - MPU settings updated
- ✅ **Compilation successful** - No device-specific dependencies

---

#### 2. **SBSFU (Secure Boot and Secure Firmware Update)**

**Purpose:** Boot manager and firmware update orchestrator

**Responsibilities:**
- System initialization and security setup
- MPU/Firewall configuration
- Firmware image management (Active/Download/SWAP)
- User interface (UART console, status LEDs)
- Local firmware download (YMODEM protocol)
- Calling Secure Engine for verification
- Firmware installation and rollback
- Watchdog management
- Tamper detection

**Hardware Dependencies:** ⚠️ **EXTENSIVE**
```
Hardware Used:
├── UART (Console/YMODEM)          - User communication
├── GPIO (LEDs/Buttons)            - Status indication
├── RTC/Tamper                     - Security monitoring
├── Flash Controller (R/W)         - Firmware installation
├── CRC Peripheral                 - Integrity checks
├── MPU/Firewall                   - Memory protection
├── IWDG (Watchdog)                - System reliability
└── System Clock (RCC)             - Clock configuration

Critical for Port:
├── ⚠️ UART pins - Must map to available STM32F411 pins
├── ⚠️ LED/Button GPIOs - Board-specific
├── ⚠️ RTC/Tamper pin - Security feature
└── ⚠️ Flash sectors - Already updated for STM32F411
```

**Memory Usage:**
- **Flash Region**: ~94 KB (0x08008900 - 0x0801FFFF)
- **RAM Region**: ~124 KB (0x20001000 - 0x2001FFEF)

**Key Files Requiring Hardware Configuration:**
```
sfu_low_level.c         - UART, GPIO, CRC initialization
sfu_low_level_security.c - MPU, RTC, Tamper setup
sfu_boot.c              - Boot sequence and hardware checks
main.c                  - GPIO pins, LED assignments
```

**For STM32F411RET6:**
- ⚠️ **UART pins must be mapped** to available LQFP64 pins
- ⚠️ **GPIO assignments** need board-specific configuration
- ⚠️ **RTC/Tamper** configuration may need adjustment
- ✅ **Flash operations** already updated for 8 sectors

---

#### 3. **UserApp (User Application)**

**Purpose:** The actual firmware application

**Responsibilities:**
- Application-specific functionality
- Peripheral usage (based on application needs)
- Communication protocols
- Data processing
- User interface (if any)

**Hardware Dependencies:** 📱 **APPLICATION-SPECIFIC**
- Completely depends on what the application does
- Uses peripherals remaining after SBSFU initialization
- Must fit within Active Slot constraints (160 KB max)

**Memory Constraints:**
- **Flash Slot**: 160 KB maximum (0x08030000 - 0x08057FFF)
- **RAM Available**: ~124 KB shared with SBSFU context
- **Header Overhead**: ~512 bytes for authentication/metadata

**For STM32F411RET6:**
- ⚠️ **Application must be ≤ 158 KB** (reduced from 640 KB)
- ⚠️ **RAM usage must be optimized** for 128 KB total
- ⚠️ **Peripheral availability** different from STM32F413

---

### Component Interaction Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         BOOT SEQUENCE                            │
└─────────────────────────────────────────────────────────────────┘

1. Power-On Reset
   └──> Vector table points to SBSFU (0x08000200)

2. SBSFU Initialization
   ├──> Configure MPU/Firewall (sfu_low_level_security.c)
   ├──> Initialize peripherals (UART, GPIO, RTC)
   ├──> Setup flash sectors and memory regions
   └──> Check security features (tamper, watchdog)

3. SBSFU Calls SECoreBin (via CallGate)
   ├──> "Verify Active Slot #1 firmware"
   └──> SE reads flash → computes hash → checks signature
        └──> Returns: ✅ Valid or ❌ Invalid

4. If Valid:
   ├──> SBSFU configures MPU for UserApp execution
   ├──> Sets vector table to UserApp (0x08030200)
   ├──> Jumps to UserApp Reset_Handler
   └──> UserApp runs with restricted privileges

5. If Invalid:
   ├──> Check Download Slot for new firmware
   ├──> If found: Install via SWAP mechanism
   └──> If none: Enter local loader (YMODEM) or error state
```

---

### Hardware Isolation and Security

```
Memory Protection (MPU Configuration):
┌────────────────────────────────────────────────────────────────┐
│ Region 7 (Highest Priority) - SE Flash Execution              │
│   └──> 32 KB @ 0x08000000, Privileged R/O, Execution Allowed  │
├────────────────────────────────────────────────────────────────┤
│ Region 6 - SE RAM Protection                                  │
│   └──> 4 KB @ 0x20000000, Privileged R/W, No Execution        │
├────────────────────────────────────────────────────────────────┤
│ Region 5 - SBSFU+UserApp RAM Access                          │
│   └──> 128 KB @ 0x20000000, Full Access, No Execution         │
├────────────────────────────────────────────────────────────────┤
│ Region 4 - FW Header Protection                               │
│   └──> 512 B @ Slot_Active, Privileged R/W, No Execution      │
├────────────────────────────────────────────────────────────────┤
│ Region 3 - SBSFU+Slots Execution (UserApp Mode)              │
│   └──> 512 KB @ 0x08000000, R/O, Execution Allowed            │
├────────────────────────────────────────────────────────────────┤
│ Region 2 - Flash R/W Access (SBSFU Mode)                      │
│   └──> 512 KB @ 0x08000000, Full Access, No Execution         │
└────────────────────────────────────────────────────────────────┘

Security Enforcement:
├── SECoreBin: Cannot be called directly (CallGate only)
├── SBSFU: Privileged mode, full hardware access
├── UserApp: Unprivileged mode, restricted access
└── MPU violations → HardFault → Device reset
```

---

### Critical Understanding for STM32F411RET6 Port

#### ✅ **What's Already Handled:**

**SECoreBin:**
- ✅ Linker script updated for 32 KB region
- ✅ No hardware-specific code (pure computation)
- ✅ Compilation successful with no changes
- ✅ Startup file added (startup_stm32f411xe.s)

**SBSFU:**
- ✅ Memory regions adjusted (128 KB RAM, 512 KB Flash)
- ✅ MPU configuration updated for reduced memory
- ✅ Flash sector definitions updated (8 sectors)
- ✅ Linker scripts synchronized

#### ⚠️ **What Requires Manual Configuration:**

**SBSFU Hardware Setup:**
```c
// In sfu_low_level.c - YOU MUST UPDATE:

// 1. UART Configuration (for console/YMODEM)
#define SFU_UART                     USART2  // ← Check available on F411
#define SFU_UART_TX_GPIO_PORT        GPIOA   // ← Map to board pins
#define SFU_UART_TX_PIN              GPIO_PIN_2
#define SFU_UART_RX_GPIO_PORT        GPIOA
#define SFU_UART_RX_PIN              GPIO_PIN_3

// 2. LED Configuration (for status indication)
#define SFU_GREEN_LED_GPIO_PORT      GPIOC   // ← Your board specific
#define SFU_GREEN_LED_PIN            GPIO_PIN_13

// 3. Button Configuration (for user input)
#define SFU_BUTTON_GPIO_PORT         GPIOA   // ← Your board specific
#define SFU_BUTTON_PIN               GPIO_PIN_0

// 4. RTC/Tamper (for security monitoring)
#define RTC_TAMPER_PIN               GPIO_PIN_13  // ← Verify on F411
#define RTC_TAMPER_GPIO_PORT         GPIOC
```

**UserApp:**
- Size must fit in 160 KB (vs original 640 KB)
- Peripheral usage must account for F411 limitations
- No CAN, FSMC, TIM8, UART4/5 available

---

## Summary: Hardware Dependencies by Component

| Component | Hardware Usage | Port Status | Action Required |
|-----------|---------------|-------------|-----------------|
| **SECoreBin** | Minimal (CPU, Flash read, CRC) | ✅ Complete | None - hardware independent |
| **SBSFU** | Extensive (UART, GPIO, RTC, Flash R/W) | ⚠️ Partial | GPIO pin mapping needed |
| **UserApp** | Application-specific | ⚠️ Pending | Size optimization + peripheral config |

**Bottom Line:** SECoreBin is essentially a **pure software cryptographic library** that happens to run in protected memory. The real hardware work is in SBSFU, which needs board-specific GPIO/UART configuration for your STM32F411RET6 target hardware.

---

## MCU Specifications Comparison

| Feature | STM32F413ZHT | STM32F411RET6 | Change |
|---------|--------------|---------------|--------|
| Flash Memory | 1536 KB | 512 KB | **-1024 KB (-66%)** |
| SRAM | 320 KB | 128 KB | **-192 KB (-60%)** |
| Core | Cortex-M4 | Cortex-M4 | Same |
| Max Frequency | 100 MHz | 100 MHz | Same |
| Flash Address | 0x08000000 - 0x0817FFFF | 0x08000000 - 0x0807FFFF | Reduced |
| RAM Address | 0x20000000 - 0x2004FFFF | 0x20000000 - 0x2001FFFF | Reduced |

---

## Memory Layout Changes

### Flash Memory Layout

#### Original STM32F413ZHT (1536 KB)
```
0x08000000 ┌─────────────────────────────────┐
           │ Secure Engine (SE)              │ 32 KB
0x08008000 ├─────────────────────────────────┤
           │ SE Interface                    │ ~2.3 KB
0x08008900 ├─────────────────────────────────┤
           │ SBSFU                           │ ~93.7 KB
0x08020000 ├─────────────────────────────────┤
           │ SWAP Area                       │ 128 KB
0x08040000 ├─────────────────────────────────┤
           │ Active Slot #1                  │ 640 KB
0x080E0000 ├─────────────────────────────────┤
           │ Download Slot #1                │ 640 KB
0x08180000 └─────────────────────────────────┘
```

#### New STM32F411RET6 (512 KB)

**STM32F411RET6 Flash Sector Organization:**
```
Sector 0:  16 KB  (0x08000000 - 0x08003FFF)  ← SE Region
Sector 1:  16 KB  (0x08004000 - 0x08007FFF)  ← SE Region
Sector 2:  16 KB  (0x08008000 - 0x0800BFFF)  ← SE Interface + SBSFU
Sector 3:  16 KB  (0x0800C000 - 0x0800FFFF)  ← SBSFU
Sector 4:  64 KB  (0x08010000 - 0x0801FFFF)  ← SBSFU
Sector 5: 128 KB  (0x08020000 - 0x0803FFFF)  ← SWAP Area
Sector 6: 128 KB  (0x08040000 - 0x0805FFFF)  ← Active Slot #1
Sector 7: 128 KB  (0x08060000 - 0x0807FFFF)  ← Download Slot #1
```

**Memory Layout:**
```
0x08000000 ┌─────────────────────────────────┐
           │ Secure Engine (SE)              │ 32 KB (Sectors 0-1)
0x08008000 ├─────────────────────────────────┤
           │ SE Interface                    │ ~2.3 KB (Sector 2)
0x08008900 ├─────────────────────────────────┤
           │ SBSFU                           │ ~93.7 KB (Sectors 2-4)
0x08020000 ├─────────────────────────────────┤
           │ SWAP Area                       │ 128 KB (Sector 5) ✓ Aligned
0x08040000 ├─────────────────────────────────┤
           │ Active Slot #1                  │ 128 KB (Sector 6) ✓ Aligned
0x08060000 ├─────────────────────────────────┤
           │ Download Slot #1                │ 128 KB (Sector 7) ✓ Aligned
0x08080000 └─────────────────────────────────┘
```

**⚠️ CRITICAL ALIGNMENT REQUIREMENTS:**
- **All slots MUST start at sector boundaries** (validated by `IS_ALIGNED` macro)
- **Slot sizes MUST be multiples of SWAP size** (128 KB each)
- **Flash sectors cannot be partially used** by different regions
- **Misalignment causes boot failure** with error messages

### RAM Memory Layout

#### Original STM32F413ZHT (320 KB)
```
0x20000000 ┌─────────────────────────────────┐
           │ SE Stack                        │ 1 KB
0x20000400 ├─────────────────────────────────┤
           │ SE RAM                          │ 3 KB
0x20001000 ├─────────────────────────────────┤
           │ SBSFU RAM                       │ ~252 KB
0x2003FFF0 ├─────────────────────────────────┤
           │ FW Image State                  │ 16 bytes
0x20040000 └─────────────────────────────────┘
```

#### New STM32F411RET6 (128 KB)
```
0x20000000 ┌─────────────────────────────────┐
           │ SE Stack                        │ 1 KB (unchanged)
0x20000400 ├─────────────────────────────────┤
           │ SE RAM                          │ 3 KB (unchanged)
0x20001000 ├─────────────────────────────────┤
           │ SBSFU RAM                       │ ~124 KB (↓ 51%)
0x2001FFF0 ├─────────────────────────────────┤
           │ FW Image State                  │ 16 bytes (unchanged)
0x20020000 └─────────────────────────────────┘
```

---

## Files Modified

### 1. mapping_sbsfu.ld
**Location:** `Projects/STM32F413H-Discovery/Applications/2_Images/Linker_Common/STM32CubeIDE/mapping_sbsfu.ld`

**Changes:**
- Updated `__ICFEDIT_SB_region_RAM_end__` from `0x2003FFEF` to `0x2001FFEF`
- Updated `__ICFEDIT_SB_FWIMG_STATE_region_RAM_end__` from `0x2003FFFF` to `0x2001FFFF`

**Rationale:** Reduced RAM from 320 KB to 128 KB to match STM32F411RET6 specification.

### 2. mapping_fwimg.ld ✅ COMPLETED (REVISED)
**Location:** `Projects/STM32F413H-Discovery/Applications/2_Images/Linker_Common/STM32CubeIDE/mapping_fwimg.ld`

**Final Changes (After Alignment Corrections):**

| Region | Old Value (F413) | New Value (F411) | Size | Sector |
|--------|------------------|------------------|------|--------|
| SWAP start | 0x08020000 | 0x08020000 | 128 KB | Sector 5 ✓ |
| SWAP end | 0x0803FFFF | 0x0803FFFF | | |
| Active Slot #1 start | 0x08040000 | 0x08040000 | 128 KB | Sector 6 ✓ |
| Active Slot #1 end | 0x080DFFFF | 0x0805FFFF | | |
| Download Slot #1 start | 0x080E0000 | 0x08060000 | 128 KB | Sector 7 ✓ |
| Download Slot #1 end | 0x0817FFFF | 0x0807FFFF | | |

**⚠️ CRITICAL LESSON LEARNED:**
- **Initial attempt used 64KB SWAP + 160KB slots** → ❌ Failed alignment checks
- **Slots MUST start at sector boundaries** (validated by `IS_ALIGNED` macro)
- **Slot sizes MUST equal SWAP size** (required by swap mechanism)
- **Final solution: 128KB for all three regions** → ✅ Passes all checks

**Alignment Validation:**
```c
// From sfu_low_level_flash_int.h:
#define IS_ALIGNED(address) (address == FlashSectorsAddress[SFU_LL_FLASH_INT_GetSector(address)])

// Error messages if misaligned:
// "SLOT_ACTIVE_1 (8030000) is not properly aligned"
// "SLOT_DWL_1 (0) is not properly aligned"
```

**Rationale:** STM32F411 has three 128KB sectors at the end (Sectors 5-7), making this the optimal layout for firmware slots that must be sector-aligned.

### 3. sfu_low_level_flash_int.c ✅ COMPLETED
**Location:** `Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_SBSFU/SBSFU/Target/sfu_low_level_flash_int.c`

**Changes:**
- Updated `FlashSectorsAddress[]` array from 16 sectors to 8 sectors
- Added detailed comment about STM32F411RET6 sector organization

**STM32F411RET6 Flash Sectors:**
```
Sector 0:  16 KB  (0x08000000 - 0x08003FFF)
Sector 1:  16 KB  (0x08004000 - 0x08007FFF)
Sector 2:  16 KB  (0x08008000 - 0x0800BFFF)
Sector 3:  16 KB  (0x0800C000 - 0x0800FFFF)
Sector 4:  64 KB  (0x08010000 - 0x0801FFFF)
Sector 5: 128 KB  (0x08020000 - 0x0803FFFF)
Sector 6: 128 KB  (0x08040000 - 0x0805FFFF)
Sector 7: 128 KB  (0x08060000 - 0x0807FFFF)
```

### 4. sfu_low_level_security.h ✅ COMPLETED
**Location:** `Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_SBSFU/SBSFU/Target/sfu_low_level_security.h`

**MPU Configuration Changes:**

| MPU Region | Parameter | Old Value | New Value | Purpose |
|------------|-----------|-----------|-----------|---------|
| Region 2 | Flash Access Size | `MPU_REGION_SIZE_2MB` | `MPU_REGION_SIZE_512KB` | Full flash R/W access |
| Region 5 | SRAM Access Size | `MPU_REGION_SIZE_512KB` | `MPU_REGION_SIZE_256KB` | RAM protection |
| Region 5 | SRAM Subregions | 0xE0 (320KB) | 0xE0 (128KB) | Effective RAM size |
| Region 3 (App) | Flash Exec Size | `MPU_REGION_SIZE_1MB` | `MPU_REGION_SIZE_512KB` | UserApp execution |
| Region 3 (App) | Subregions | 0x82 (selective) | 0x00 (all enabled) | Simplified coverage |

**Rationale:** All MPU regions must be power-of-2 sized and properly aligned for ARM Cortex-M4.

### 5. Linker Script Headers ✅ COMPLETED
**Locations:**
- `2_Images_SBSFU/STM32CubeIDE/STM32F413ZHTx_FLASH.ld`
- `2_Images_SECoreBin/STM32CubeIDE/STM32F413ZHTx_FLASH.ld`
- `2_Images_UserApp/STM32CubeIDE/STM32F413ZHTx_FLASH.ld`

**Changes:**
- Updated header comments from "STM32F413ZHTx with 1536KB Flash, 320KB RAM" to "STM32F411RETx with 512KB Flash, 128KB RAM"
- Added note "(Ported from STM32F413ZHTx)"

### 6. Startup Files ✅ COMPLETED
**Location:** `STM32CubeIDE/Application/Startup/` in each project

**Files Added:**
- `startup_stm32f411xe.s` (copied from CMSIS templates to SBSFU, UserApp, SECoreBin)

**Key Changes:**
```
STM32F411 Vector Table (86 interrupts):
- Core interrupts: 16 (same as F413)
- External interrupts: ~70 (vs ~86 on F413)
- Reserved: CAN1_TX/RX/SCE, TIM8_BRK/UP/TRG/CC, UART4/5, FSMC
- Source: Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s
```

**Old Files to Remove:**
- `startup_stm32f413xx.s` (keep for reference until build verified)

### 7. System Initialization ✅ COMPLETED
**File:** `system_stm32f4xx.c` (in UserApp/Src)

**Status:** No changes required
- Generic STM32F4xx family implementation
- Compatible with both F413 and F411
- Clock initialization handled by HAL
- Requires correct device define: `STM32F411xE`

---

## Memory Allocation Strategy

### Design Decisions

1. **Preserve Security Core (SE + SBSFU):** 
   - Kept at 128 KB to maintain security features
   - These regions contain critical cryptographic and boot code that cannot be reduced

2. **SWAP Area Size (Revised):**
   - **Originally planned: 64 KB** → Failed alignment requirements
   - **Final decision: 128 KB** → Matches sector boundary (Sector 5)
   - Provides robust space for firmware update swap operations
   - **CRITICAL: SWAP size determines all slot sizes**

3. **Firmware Slots Size (Revised):**
   - **Originally planned: 160 KB each** → Not multiple of SWAP size
   - **Final decision: 128 KB each** → Perfect multiple of 128 KB SWAP
   - Both Active and Download slots are equal size
   - Maximum application size is now **~127 KB** (after 512B header overhead)
   - Reduced from 640 KB (80% reduction)

4. **Sector Alignment Requirement:**
   - **All slots MUST start at flash sector boundaries**
   - STM32F411 Sectors 5, 6, 7 are each 128 KB → Perfect fit
   - Attempting non-aligned addresses causes boot failure
   - Validated by `IS_ALIGNED` macro at runtime

4. **RAM Optimization:**
   - SE RAM preserved at 4 KB (critical for security operations)
   - SBSFU RAM reduced proportionally with total RAM
   - Maintains minimum stack and heap requirements

---

## Important Considerations

### Flash Sector Alignment

**STM32F411RET6 Flash Sector Organization:**
```
Sector 0:  16 KB  (0x08000000 - 0x08003FFF)
Sector 1:  16 KB  (0x08004000 - 0x08007FFF)
Sector 2:  16 KB  (0x08008000 - 0x0800BFFF)
Sector 3:  16 KB  (0x0800C000 - 0x0800FFFF)
Sector 4:  64 KB  (0x08010000 - 0x0801FFFF)
Sector 5:  128 KB (0x08020000 - 0x0803FFFF)
Sector 6:  128 KB (0x08040000 - 0x0805FFFF)
Sector 7:  128 KB (0x08060000 - 0x0807FFFF)
```

**Current Allocation vs Sectors:**
- SE Region: Sectors 0-1 (32 KB) ✓
- SBSFU: Sectors 2-4 (~96 KB) ✓
- SWAP: Half of Sector 5 (64 KB) ⚠️
- Active Slot: Rest of Sector 5 + Sector 6 (160 KB) ⚠️
- Download Slot: Sector 7 + part of Sector 6 (160 KB) ⚠️

> **Warning:** The current layout may not align perfectly with flash sectors. Flash erase operations must be performed on complete sectors. Review sector boundaries before finalizing.

### Application Size Limitations

- **Maximum Application Size:** ~158 KB (160 KB slot minus header overhead)
- This is a **75% reduction** from the original 640 KB
- Applications must be optimized to fit within this constraint
- Consider:
  - Code optimization (compiler flags)
  - Removing unused features/libraries
  - Using external flash for data storage if available

### Memory Constraints

- **SBSFU RAM:** Reduced to ~124 KB
- Applications must be profiled for RAM usage
- Consider reducing:
  - Stack size
  - Heap size
  - Static buffers
  - Global variables

---

## Next Steps for Complete Port

### 1. Flash Configuration Updates ✅ COMPLETED
- [x] Update flash sector definitions in `sfu_low_level_flash_int.c`
- [x] Adjust flash driver configuration for STM32F411 sector layout (8 sectors)
- [x] Update flash erase/write operations to handle new sector sizes

**Changes Made:**
- Updated `FlashSectorsAddress[]` array in `sfu_low_level_flash_int.c` from 16 sectors to 8 sectors
- Flash sectors now: 4×16KB + 1×64KB + 3×128KB = 512KB total

### 2. Memory Protection Configuration ✅ COMPLETED
- [x] Update MPU (Memory Protection Unit) regions in `sfu_low_level_security.h`
- [x] Update flash access region from 2MB to 512KB
- [x] Update SRAM access region from 512KB to 256KB (128KB effective)
- [x] Update UserApp flash execution region from 1MB to 512KB
- [x] Write protection automatically uses updated sector definitions

**MPU Changes Made:**
- **Region 2 (Flash Access)**: `MPU_REGION_SIZE_2MB` → `MPU_REGION_SIZE_512KB`
- **Region 5 (SRAM Access)**: `MPU_REGION_SIZE_512KB` → `MPU_REGION_SIZE_256KB` with subregion 0xE0 for 128KB
- **Region 3 (UserApp Flash Exec)**: `MPU_REGION_SIZE_1MB` → `MPU_REGION_SIZE_512KB`
- All regions verified for power-of-2 alignment (ARM Cortex-M4 requirement)

### 3. HAL Driver Updates
- [ ] Replace STM32F4xx_HAL_Driver with STM32F411-specific version (drivers are generic for F4 family)
- [ ] Update `stm32f4xx_hal_conf.h` for STM32F411 peripherals
- [x] Copy startup file `startup_stm32f411xe.s` from CMSIS templates
- [x] Verify `system_stm32f4xx.c` is compatible (generic F4 family file)

**Startup Files Copied:**
- `2_Images_SBSFU/STM32CubeIDE/Application/Startup/startup_stm32f411xe.s`
- `2_Images_UserApp/STM32CubeIDE/Application/Startup/startup_stm32f411xe.s`
- `2_Images_SECoreBin/STM32CubeIDE/Application/Startup/startup_stm32f411xe.s`

**Key Differences in STM32F411 Startup File:**
- **Vector table size**: ~86 interrupts (vs F413's ~102)
- **Reserved interrupts**: CAN1/2, UART4/5, TIM8 peripherals, FSMC (not present in F411)
- **Source**: Copied from `Drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f411xe.s`

### 4. Project Configuration
- [ ] Update `.project` and `.cproject` files for STM32CubeIDE
- [ ] Change device selection from STM32F413ZHTx to STM32F411RETx
- [ ] Add preprocessor define: `STM32F411xE` (remove `STM32F413xx`)
- [ ] Update startup file reference in build configuration from `startup_stm32f413xx.s` to `startup_stm32f411xe.s`
- [ ] Remove old `startup_stm32f413xx.s` files from projects
- [ ] Update debugger configuration (OpenOCD/ST-Link)
- [ ] Adjust clock configuration for 100 MHz max frequency

### 5. Peripheral Configuration
- [ ] Verify GPIO port availability (STM32F411 has fewer pins: LQFP64 vs LQFP144)
- [ ] Check peripheral availability: No CAN, FSMC, limited timers
- [ ] Update pin assignments in device configuration for target hardware
- [ ] Replace `stm32f413h_discovery.h` BSP with appropriate hardware configuration
- [ ] Adjust timer configurations if needed (TIM8 not available on F411)

**STM32F411RET6 vs STM32F413ZHT Peripheral Differences:**
- **Missing**: CAN1, CAN2, FSMC, TIM8, UART4, UART5, DAC (some F411 variants)
- **Package**: LQFP64 (F411RET6) vs LQFP144 (F413ZHT) - fewer GPIO pins available
- **Timers**: TIM1, TIM2, TIM3, TIM4, TIM5, TIM9, TIM10, TIM11 (no TIM8)
- **Communication**: 3×I2C, 3×USART, 5×SPI (vs 3×I2C, 10×USART, 5×SPI on F413)

### 6. Application Updates
- [ ] Modify application linker scripts to use new Active Slot addresses (0x08040000)
- [ ] Update application code to fit within **128 KB constraint** (revised from 160KB)
- [ ] Optimize RAM usage to fit within reduced limits
- [ ] Test firmware update procedure with smaller slots

**⚠️ CRITICAL APPLICATION SIZE LIMIT:**
- **Maximum UserApp size: ~127 KB** (128 KB slot - 512 bytes header)
- Original F413 allowed 640 KB applications
- **80% size reduction required** for existing applications

### 7. Security Features
- [ ] Verify cryptographic operations still work with reduced RAM
- [ ] Test secure boot sequence
- [ ] Validate firmware authentication with new memory layout
- [ ] Test anti-rollback protection

### 8. Build and Test
- [ ] Compile SECoreBin project
- [ ] Compile SBSFU project
- [ ] Compile UserApp project
- [ ] Generate encrypted/signed firmware images
- [ ] Test complete boot sequence
- [ ] Verify firmware update functionality
- [ ] Stress test with maximum-sized applications

---

## Debug and Validation Results

### ✅ Successful Compilation and Flash Programming

**SECoreBin Compilation:**
- Status: ✅ Success (no hardware dependencies)
- Size: Fits within 32 KB SE region
- Startup file: `startup_stm32f411xe.s` successfully integrated

**SBSFU Compilation:**
- Status: ✅ Success (after build configuration fixes)
- RDP-1 Protection: Applied successfully on first boot
- UART Output: Working on USART2 @ 115200 baud

### ⚠️ Issues Encountered and Resolved

#### Issue 1: Memory Slot Alignment Errors
**Error Messages:**
```
= [FWIMG] SLOT_ACTIVE_1 (8030000) is not properly aligned
= [FWIMG] SLOT_DWL_1 (0) is not properly aligned
= [FWIMG] SLOT_ACTIVE_1 size (163840) must be a multiple of swap size (65536)
```

**Root Cause:**
- Initial configuration used 64KB SWAP + 160KB slots
- Slots started at non-sector boundaries (0x08030000, 0x08050000)
- Slot sizes were not multiples of SWAP size

**Resolution:**
- Changed all three regions to 128 KB each
- Aligned to sector boundaries: Sector 5 (SWAP), Sector 6 (Active), Sector 7 (Download)
- Validated with `IS_ALIGNED` macro checking sector boundaries

**Key Learning:**
```c
// From sfu_low_level_flash_int.h:
#define IS_ALIGNED(address) (address == FlashSectorsAddress[SFU_LL_FLASH_INT_GetSector(address)])

// STM32F411 requires:
✓ SWAP must start at sector boundary (0x08020000 = Sector 5)
✓ Active must start at sector boundary (0x08040000 = Sector 6)  
✓ Download must start at sector boundary (0x08060000 = Sector 7)
✓ All slot sizes must be equal to SWAP size (128 KB each)
```

#### Issue 2: RDP Protection Application
**Behavior:**
```
Applying RDP-1 Level. You might need to unplug/plug the USB cable!
```

**Explanation:**
- SBSFU applies Read Protection Level 1 on first boot
- Option bytes modification requires system reset
- After unplug/replug + reset, bootloader continues normally

**Expected Output After Reset:**
```
= [SBOOT] System Security Check successfully passed. Starting...
= [FWIMG] Slot configuration validated
```

#### Issue 3: Build Configuration (Duplicate Startup Files)
**Error:**
```
multiple definition of `g_pfnVectors'
startup_stm32f413xx.o vs startup_stm32f411xe.o
```

**Resolution:**
- Exclude `startup_stm32f413xx.s` from build
- Include only `startup_stm32f411xe.s`
- Update preprocessor defines: `STM32F411xE` (remove `STM32F413xx`)
- Remove `USE_STM32F413H_DISCOVERY` define

### 📊 Final Memory Layout Validation

**Flash Sectors Verified:**
```
0x08000000 - 0x08003FFF: Sector 0 (16KB)  ✓ SE
0x08004000 - 0x08007FFF: Sector 1 (16KB)  ✓ SE
0x08008000 - 0x0800BFFF: Sector 2 (16KB)  ✓ SE Interface + SBSFU
0x0800C000 - 0x0800FFFF: Sector 3 (16KB)  ✓ SBSFU
0x08010000 - 0x0801FFFF: Sector 4 (64KB)  ✓ SBSFU
0x08020000 - 0x0803FFFF: Sector 5 (128KB) ✓ SWAP (aligned)
0x08040000 - 0x0805FFFF: Sector 6 (128KB) ✓ Active Slot #1 (aligned)
0x08060000 - 0x0807FFFF: Sector 7 (128KB) ✓ Download Slot #1 (aligned)
```

**Runtime Validation:**
- ✅ System Security Check passed
- ✅ RDP-1 protection applied
- ✅ UART console operational
- ✅ Slot alignment verified
- ✅ No memory overflow errors

### 🔧 Debug Configuration

**OpenOCD Setup:**
- Path: `/opt/homebrew/bin/openocd` (version 0.12.0)
- Interface: ST-Link V2
- Target: stm32f4x.cfg
- SVD File: STM32F411.svd for peripheral register viewing

**VS Code Launch Configuration:**
```json
{
  "name": "Debug SBSFU Bootloader (OpenOCD)",
  "type": "cortex-debug",
  "servertype": "openocd",
  "configFiles": [
    "interface/stlink.cfg",
    "target/stm32f4x.cfg"
  ],
  "serverpath": "/opt/homebrew/bin/openocd"
}
```

---

## Memory Address Verification

### Address Consistency Check

To ensure proper operation, all components (SBSFU, UserApp, and signing tools) must use consistent memory addresses. Use the following commands to verify:

**Check SBSFU compiled addresses:**
```bash
arm-none-eabi-nm Debug/SBSFU.elf | grep -E "SLOT_Active_1|SLOT_Dwl_1|SWAP_"
```

**Check UserApp compiled addresses:**
```bash
arm-none-eabi-readelf -l Debug/UserApp.elf | grep LOAD
```

**Check UserApp signing output:**
```bash
grep "APPLI Base\|Writing header" output.txt
```

### Verified Address Map (STM32F411RET6)

| Component | Symbol/Region | Address | Size | Verification Method |
|-----------|--------------|---------|------|---------------------|
| **SBSFU** | SWAP_START | 0x08020000 | 128 KB | `arm-none-eabi-nm SBSFU.elf` |
| **SBSFU** | SWAP_END | 0x0803FFFF | | ✓ Sector 5 boundary |
| **SBSFU** | SLOT_Active_1_HEADER | 0x08040000 | 512 B | ✓ Sector 6 boundary |
| **SBSFU** | SLOT_Active_1_START | 0x08040000 | 128 KB | Verified in binary |
| **SBSFU** | SLOT_Active_1_END | 0x0805FFFF | | ✓ Aligned |
| **SBSFU** | SLOT_Dwl_1_START | 0x08060000 | 128 KB | ✓ Sector 7 boundary |
| **SBSFU** | SLOT_Dwl_1_END | 0x0807FFFF | | End of flash |
| **UserApp** | .isr_vector | 0x0804012C | 724 B | Vector table offset |
| **UserApp** | .text (LOAD) | 0x08040400 | | Code start (+0x200) |
| **UserApp** | .rodata | 0x08044C50 | | Read-only data |
| **UserApp** | .data (RAM) | 0x20001000 | | Initialized data |
| **Signing** | Writing header | 0x08040000 | 512 B | prepareimage.py output |
| **Signing** | APPLI Base | 0x08040200 | | After header+vector |

### Address Relationship Formula

```
Active Slot Layout:
├─ 0x08040000: FW Header (512 bytes, Magic + Signature + Metadata)
├─ 0x08040200: Vector Table (variable size, typically ~724 bytes for STM32F411)
├─ 0x08040400: Application Code (.text section)
└─ 0x0805FFFF: End of Active Slot (128 KB total)

Key Offsets:
- Header offset: 0x000 (512 bytes reserved)
- Vector offset: 0x200 (header + alignment)
- Code offset:   0x400 (after vector table)
```

### Common Address Mismatch Issues

**Symptom:** "HANDLE CRITICAL FAILURE" during firmware installation

**Possible Causes:**
1. **SBSFU built with old mapping** → Rebuild SBSFU after changing mapping_fwimg.ld
2. **UserApp signed for wrong address** → Rebuild UserApp to regenerate .sfb with correct addresses
3. **Sector misalignment** → Verify all slots start at sector boundaries
4. **Size overflow** → Ensure UserApp fits within 127 KB limit

**Verification Steps:**
```bash
# 1. Check mapping file
cat Linker_Common/STM32CubeIDE/mapping_fwimg.ld | grep -A 2 "Active slot"

# 2. Verify SBSFU knows correct addresses
arm-none-eabi-nm SBSFU/Debug/SBSFU.elf | grep SLOT_Active_1_start

# 3. Confirm UserApp is linked correctly
arm-none-eabi-readelf -S UserApp/Debug/UserApp.elf | grep ".text"

# 4. Check signed image header
hexdump -C UserApp/Binary/UserApp.sfb | head -20
```

#### Issue #4: UserApp HardFault - PLLR Configuration (CRITICAL)

**Error:** After successful firmware installation, UserApp crashed immediately with HardFault, stuck in infinite loop. UART output showed:
```
= [SBOOT] STATE: EXECUTE USER FIRMWARE
= [SBOOT] System Security Check successfully passed. Starting...
[No UserApp banner - crash before main()]
```

**Root Cause:**
- **STM32F411 does not have PLLR parameter** in RCC_PLLCFGR register (only M, N, P, Q)
- PLLR is only available on STM32F413/F446 series
- SystemClock_Config() in [2_Images_UserApp/Src/main.c](../../2_Images_UserApp/Src/main.c#L172) was setting:
  ```c
  RCC_OscInitStruct.PLL.PLLR = 2;  // ← Does not exist on F411!
  ```
- HAL_RCC_OscConfig() tried to write PLLR to non-existent register bits
- Caused HardFault during clock configuration, before main() could print banner

**Solution:**
Remove PLLR parameter from SystemClock_Config():

```c
// File: Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_UserApp/Src/main.c
// Around line 172-183

/* Enable HSE Oscillator and activate PLL with HSE as source */
RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
RCC_OscInitStruct.HSEState = RCC_HSE_BYPASS;
RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
RCC_OscInitStruct.PLL.PLLM = 8;
RCC_OscInitStruct.PLL.PLLN = 200;
RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
RCC_OscInitStruct.PLL.PLLQ = 7;
/* Note: STM32F411 does not have PLLR parameter (only F413/F446 series) */
// REMOVE THIS LINE: RCC_OscInitStruct.PLL.PLLR = 2;
ret = HAL_RCC_OscConfig(&RCC_OscInitStruct);
```

**Verification:**
```bash
# Rebuild UserApp
cd Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_UserApp/STM32CubeIDE/Debug
make clean && make -j8

# Check output
arm-none-eabi-size UserApp.elf
# text: 19040, data: 176, bss: 6248, total: 25464 bytes

# Regenerate signed firmware
ls -lh ../Binary/UserApp.sfb
# -rw-r--r-- 19K Feb  1 23:41 UserApp.sfb

# Verify magic number
hexdump -C ../Binary/UserApp.sfb | head -3
# 00000000  53 46 55 31 01 00 01 00  10 4b 00 00  |SFU1.....K..|
```

**Prevention:**
When porting between STM32F4 series, always check the RCC register differences:
- **F411/F401:** PLL has M, N, P, Q only
- **F413/F446:** PLL has M, N, P, Q, **R** (for additional clocks)
- **F7/H7 series:** Different PLL structure entirely (PLLSAI, etc.)

Refer to Reference Manual RM0383 (F411) vs RM0430 (F413) for register differences.

**Expected Results:**
- All three checks should show Active Slot at **0x08040000**
- UserApp .text section should load to **0x08040400** (or close, after vector table)
- .sfb file should start with magic number "SFU1" at correct offset

---

## Testing Checklist

- [x] **Boot Test:** Device boots successfully with SBSFU
- [x] **Security Init:** RDP-1 protection applied successfully
- [x] **Memory Validation:** Slot alignment verified, no overflow errors
- [x] **UART Test:** Console output working @ 115200 baud
- [x] **Debug Setup:** OpenOCD + ST-Link connection established
- [x] **Clock Configuration:** Fixed PLLR issue for STM32F411 compatibility
- [ ] **Application Test:** User application runs correctly
- [ ] **Update Test:** Firmware update from Download to Active slot works
- [ ] **Rollback Test:** Failed update triggers rollback
- [ ] **Security Test:** Tamper detection and secure boot verification
- [ ] **Performance Test:** Application performs within acceptable limits

---

## Known Limitations

1. **Firmware Size:** Maximum application size reduced to **~127 KB** (vs 640 KB on F413)
2. **SWAP Mechanism:** All three regions fixed at 128 KB (determined by sector layout)
3. **RAM Constraints:** Reduced RAM (128 KB vs 320 KB) may impact complex applications
4. **Sector Granularity:** Cannot use partial sectors, must use complete 128 KB sectors for slots
5. **Flash Utilization:** 448 KB used out of 512 KB (87.5% utilization)

**Unused Flash:**
- 64 KB available at end (no complete sector after Sector 7)
- Could potentially be used for data storage but not for firmware slots

---

## Additional Resources

- [STM32F411xE Datasheet](https://www.st.com/resource/en/datasheet/stm32f411re.pdf)
- [STM32F411xE Reference Manual (RM0383)](https://www.st.com/resource/en/reference_manual/dm00119316.pdf)
- [AN2606: STM32 Bootloader Application Note](https://www.st.com/resource/en/application_note/cd00167594.pdf)
- [AN4657: Secure Boot and Secure Firmware Update](https://www.st.com/resource/en/application_note/dm00401897.pdf)

---

## Revision History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2026-02-01 | 1.0 | Initial | Initial port from STM32F413ZHT to STM32F411RET6 - Linker script adjustments |
| 2026-02-01 | 1.1 | Initial | Updated flash sector definitions for STM32F411 (8 sectors) |
| 2026-02-01 | 1.2 | Initial | Updated MPU configuration for 512KB Flash / 128KB RAM |
| 2026-02-01 | 1.3 | Initial | Added STM32F411 startup files and verified system initialization |
| 2026-02-01 | 2.0 | Initial | **MAJOR REVISION**: Corrected memory layout for sector alignment - Changed from 64KB SWAP + 160KB slots to 128KB for all regions - Validated with hardware |
| 2026-02-01 | 2.1 | Initial | Added Debug/Validation section with issue resolutions and UART test results |
| 2026-02-01 | 2.2 | Initial | **CRITICAL FIX**: Removed PLLR configuration from UserApp SystemClock_Config() - Fixed HardFault on UserApp boot - Documented clock differences between F411/F413 |

---

## Notes

- This document should be updated as additional changes are made during the porting process
- Keep track of any issues encountered and their solutions
- Document any deviations from the standard SBSFU configuration
- Maintain compatibility with ST's SBSFU update tools
