/**
  ******************************************************************************
  * @file    main.c
  * @author  MCD Application Team
  * @brief   Main application file.
  *          This application demonstrates Firmware Update, protections
  *          and crypto testing functionalities.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2017 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file in
  * the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */

#define MAIN_C

/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "loader.h"
#include "loader_low_level.h"
#include "loader_low_level_flash.h"
#include "sfu_standalone_loader.h"            /* Standalone loader states definition in SHARED RAM */

/* Global variables ----------------------------------------------------------*/
/* List of slot header address */
const uint32_t  SlotHeaderAdd[NB_SLOTS] = { 0U,
                                            SLOT_ACTIVE_1_HEADER,
                                            SLOT_ACTIVE_2_HEADER,
                                            SLOT_ACTIVE_3_HEADER,
                                            SLOT_DWL_1_START,
                                            SLOT_DWL_2_START,
                                            SLOT_DWL_3_START,
                                            SWAP_START,
                                          };
/* List of slot start address */
const uint32_t  SlotStartAdd[NB_SLOTS]  = { 0U,
                                            SLOT_ACTIVE_1_START,
                                            SLOT_ACTIVE_2_START,
                                            SLOT_ACTIVE_3_START,
                                            SLOT_DWL_1_START,
                                            SLOT_DWL_2_START,
                                            SLOT_DWL_3_START,
                                            SWAP_START,
                                          };
/* List of slot end address */
const uint32_t  SlotEndAdd[NB_SLOTS]    = { 0U,
                                            SLOT_ACTIVE_1_END,
                                            SLOT_ACTIVE_2_END,
                                            SLOT_ACTIVE_3_END,
                                            SLOT_DWL_1_END,
                                            SLOT_DWL_2_END,
                                            SLOT_DWL_3_END,
                                            SWAP_END,
                                          };

/* Private function prototypes -----------------------------------------------*/
static void SystemClock_Config(void);

/* Functions Definition ------------------------------------------------------*/
/**
  * @brief  Main program
  * @param  None
  * @retval None
  */
int main(void)
{
  LOADER_StatusTypeDef e_ret_status;
  uint32_t rx_size;
  uint32_t dwl_type;
  uint32_t dwl_slot;


  /* STM32WBxx HAL library initialization:
  - Configure the Flash prefetch
  - Systick timer is configured by default as source of time base, but user
  can eventually implement his proper time base source (a general purpose
  timer for example or other time source), keeping in mind that Time base
  duration should be kept 1ms since PPP_TIMEOUT_VALUEs are defined and
  handled in milliseconds basis.
  - Set NVIC Group Priority to 4
  - Low Level Initialization
  */
  (void) HAL_Init();

  /* Configure the system clock */
  SystemClock_Config();

  /* Initialize external flash interface (OSPI/QSPI) */
  (void) LOADER_LL_FLASH_Init();

  /* If the SecureBoot configured the IWDG, loader must reload IWDG counter with value defined in the reload register */
  WRITE_REG(IWDG->KR, IWDG_KEY_RELOAD);

  /* Configure Communication module */
  (void) LOADER_LL_UART_Init();

  TRACE("\r\n======================================================================");
  TRACE("\r\n=                           Loader                                   =");
  TRACE("\r\n======================================================================");
  TRACE("\r\n");

  /* Loader initialization */
  e_ret_status = LOADER_Init();
  if (e_ret_status != LOADER_OK)
  {
    TRACE("Initialization failure : reset !");
    NVIC_SystemReset();
  }

  /* Standalone loader communication : do not memorize the DWL request
     to avoid to be stuck in DWL state in case of reset */
  STANDALONE_LOADER_STATE = STANDALONE_LOADER_NO_REQ;

  /* Download new firmware */
  e_ret_status = LOADER_DownloadNewUserFw(&rx_size, &dwl_slot, &dwl_type);

  if (e_ret_status == LOADER_OK)
  {
    if (dwl_type == DWL_OTHER)
    {
      /* Standalone loader communication : By-pass requested */
      STANDALONE_LOADER_STATE = STANDALONE_LOADER_BYPASS_REQ;
    }
    else
    {
      /* Standalone loader communication : FW installation requested */
      STANDALONE_LOADER_STATE = STANDALONE_LOADER_INSTALL_REQ;
      TRACE("\r\nDownload successful : %d bytes received\r\n", rx_size);
    }
  }
  else
  {
    TRACE("\r\nDownload failed (%d)\r\n", e_ret_status);
    (void) LOADER_LL_FLASH_Erase_Size((uint8_t *) SlotStartAdd[dwl_slot], SLOT_SIZE(dwl_slot));
  }

  /* Reset to restart SBSFU */
  NVIC_SystemReset();
}

/**
  * @brief  System Clock Configuration
  *         The system Clock is configured as follow :
  *            System Clock source            = PLL (MSI)
  *            SYSCLK(Hz)                     = 64000000
  *            HCLK1(Hz)                      = 64000000
  *            HCLK2(Hz)                      = 32000000
  *            HCLK1 Prescaler                = 1
  *            HCKL2 Prescaler                = 2
  *            APB1 Prescaler                 = 1
  *            APB2 Prescaler                 = 1
  *            MSI Frequency(Hz)              = 4000000
  *            PLL_M                          = 1
  *            PLL_N                          = 32
  *            PLL_P                          = 2
  *            PLL_Q                          = 2
  *            PLL_R                          = 2
  *            Flash Latency(WS)              = 3
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};
  RCC_PeriphCLKInitTypeDef PeriphClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);
  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI|RCC_OSCILLATORTYPE_MSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.MSIState = RCC_MSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.MSICalibrationValue = RCC_MSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.MSIClockRange = RCC_MSIRANGE_6;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_MSI;
  RCC_OscInitStruct.PLL.PLLM = RCC_PLLM_DIV1;
  RCC_OscInitStruct.PLL.PLLN = 32;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLR = RCC_PLLR_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = RCC_PLLQ_DIV2;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    /* Initialization Error */
    while (1);
  }
  /** Configure the SYSCLKSource, HCLK, PCLK1 and PCLK2 clocks dividers
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK4|RCC_CLOCKTYPE_HCLK2
                              |RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.AHBCLK2Divider = RCC_SYSCLK_DIV2;
  RCC_ClkInitStruct.AHBCLK4Divider = RCC_SYSCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_3) != HAL_OK)
  {
    /* Initialization Error */
    while (1);
  }
  /** Initializes the peripherals clocks
  */
  PeriphClkInitStruct.PeriphClockSelection = RCC_PERIPHCLK_SMPS;
  PeriphClkInitStruct.SmpsClockSelection = RCC_SMPSCLKSOURCE_HSI;
  PeriphClkInitStruct.SmpsDivSelection = RCC_SMPSCLKDIV_RANGE1;
  if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInitStruct) != HAL_OK)
  {
    /* Initialization Error */
    while (1);
  }
}



#ifdef  USE_FULL_ASSERT

/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* User can add his own implementation to report the file name and line number,
     ex: TRACE("Wrong parameters value: file %s on line %d\r\n", file, line) */

  /* Infinite loop */
  while (1)
  {
  }
}
#endif /* USE_FULL_ASSERT */

/**
  * @}
  */

/**
  * @}
  */
