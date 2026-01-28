/**
  ******************************************************************************
  * @file    loader_low_level_flash_ext.c
  * @author  MCD Application Team
  * @brief   SFU Flash Low Level Interface module
  *          This file provides set of firmware functions to manage SFU external
  *          flash low level interface.
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

/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "loader_low_level_flash.h"

/* Private defines -----------------------------------------------------------*/

/* Functions Definition ------------------------------------------------------*/

/* No external flash available on this product
   ==> return HAL_ERROR except for LOADER_LL_FLASH_EXT_Init which is called systematically during startup phase */

HAL_StatusTypeDef LOADER_LL_FLASH_EXT_Init(void)
{
  return HAL_OK;
}

HAL_StatusTypeDef LOADER_LL_FLASH_EXT_Erase_Size(uint8_t *pStart, uint32_t Length)
{
  UNUSED(pStart);
  UNUSED(Length);
  return HAL_ERROR;
}

HAL_StatusTypeDef LOADER_LL_FLASH_EXT_Write(uint8_t  *pDestination, const uint8_t *pSource, uint32_t Length)
{
  UNUSED(pDestination);
  UNUSED(pSource);
  UNUSED(Length);
  return HAL_ERROR;
}

HAL_StatusTypeDef LOADER_LL_FLASH_EXT_Read(uint8_t *pDestination, const uint8_t *pSource, uint32_t Length)
{
  UNUSED(pDestination);
  UNUSED(pSource);
  UNUSED(Length);
  return HAL_ERROR;
}

