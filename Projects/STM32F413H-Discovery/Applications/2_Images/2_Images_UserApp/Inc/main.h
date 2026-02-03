/**
  ******************************************************************************
  * @file    main.h
  * @author  MCD Application Team
  * @brief   This file contains definitions for main application file.
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

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef MAIN_H
#define MAIN_H

/* Includes ------------------------------------------------------------------*/
#include "stm32f4xx_hal.h"
/* #include "stm32f413h_discovery.h" */ /* Removed - using NUCLEO-F411RE configuration */
#include "com.h"

/* NUCLEO-F411RE Hardware Definitions */
/* User LED (LD2) - PA5 */
#define LED_GREEN_PIN GPIO_PIN_5
#define LED_GREEN_GPIO_PORT GPIOA
#define LED_GREEN_GPIO_CLK_ENABLE() __HAL_RCC_GPIOA_CLK_ENABLE()

/* User Button (B1) - PC13 */
#define BUTTON_PIN GPIO_PIN_13
#define BUTTON_GPIO_PORT GPIOC
#define BUTTON_GPIO_CLK_ENABLE() __HAL_RCC_GPIOC_CLK_ENABLE()

/* BSP-like LED macros for compatibility */
typedef enum
{
    LED_GREEN = 0
} Led_TypeDef;

#define LEDn 1
#define BSP_LED_Init(Led)                                                      \
    do                                                                         \
    {                                                                          \
        LED_GREEN_GPIO_CLK_ENABLE();                                           \
        GPIO_InitTypeDef GPIO_InitStruct = {0};                                \
        GPIO_InitStruct.Pin = LED_GREEN_PIN;                                   \
        GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;                            \
        GPIO_InitStruct.Pull = GPIO_NOPULL;                                    \
        GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;                           \
        HAL_GPIO_Init(LED_GREEN_GPIO_PORT, &GPIO_InitStruct);                  \
        HAL_GPIO_WritePin(LED_GREEN_GPIO_PORT, LED_GREEN_PIN, GPIO_PIN_RESET); \
    } while (0)
#define BSP_LED_Toggle(Led) HAL_GPIO_TogglePin(LED_GREEN_GPIO_PORT, LED_GREEN_PIN)
#define BSP_LED_On(Led) HAL_GPIO_WritePin(LED_GREEN_GPIO_PORT, LED_GREEN_PIN, GPIO_PIN_SET)
#define BSP_LED_Off(Led) HAL_GPIO_WritePin(LED_GREEN_GPIO_PORT, LED_GREEN_PIN, GPIO_PIN_RESET)

/* Button macros */
#define BUTTON_INIT()                                      \
    do                                                     \
    {                                                      \
        BUTTON_GPIO_CLK_ENABLE();                          \
        GPIO_InitTypeDef GPIO_InitStruct = {0};            \
        GPIO_InitStruct.Pin = BUTTON_PIN;                  \
        GPIO_InitStruct.Mode = GPIO_MODE_INPUT;            \
        GPIO_InitStruct.Pull = GPIO_NOPULL;                \
        HAL_GPIO_Init(BUTTON_GPIO_PORT, &GPIO_InitStruct); \
    } while (0)
#define BUTTON_PUSHED() (HAL_GPIO_ReadPin(BUTTON_GPIO_PORT, BUTTON_PIN) == GPIO_PIN_SET)

/* Exported types ------------------------------------------------------------*/
/* Exported constants --------------------------------------------------------*/
/* User can use this section to tailor UARTx instance used and associated
   resources */

/* Definition for USARTx clock resources - NUCLEO-F411RE uses USART2 on PA2/PA3 */
#define SFU_UART USART2
#define SFU_UART_CLK_ENABLE() __HAL_RCC_USART2_CLK_ENABLE()
#define SFU_UART_CLK_DISABLE() __HAL_RCC_USART2_CLK_DISABLE()

#define SFU_UART_TX_AF GPIO_AF7_USART2
#define SFU_UART_TX_GPIO_PORT GPIOA
#define SFU_UART_TX_PIN GPIO_PIN_2
#define SFU_UART_TX_GPIO_CLK_ENABLE() __HAL_RCC_GPIOA_CLK_ENABLE()
#define SFU_UART_TX_GPIO_CLK_DISABLE() __HAL_RCC_GPIOA_CLK_DISABLE()

#define SFU_UART_RX_AF GPIO_AF7_USART2
#define SFU_UART_RX_GPIO_PORT GPIOA
#define SFU_UART_RX_PIN GPIO_PIN_3
#define SFU_UART_RX_GPIO_CLK_ENABLE() __HAL_RCC_GPIOA_CLK_ENABLE()
#define SFU_UART_RX_GPIO_CLK_DISABLE() __HAL_RCC_GPIOG_CLK_DISABLE()

/* Maximum Timeout values for flags waiting loops.
   You may modify these timeout values depending on CPU frequency and application
   conditions (interrupts routines ...). */
#define SFU_UART_TIMEOUT_MAX 1000U

/* Exported macro ------------------------------------------------------------*/
/* Exported functions ------------------------------------------------------- */

#endif /* MAIN_H */
