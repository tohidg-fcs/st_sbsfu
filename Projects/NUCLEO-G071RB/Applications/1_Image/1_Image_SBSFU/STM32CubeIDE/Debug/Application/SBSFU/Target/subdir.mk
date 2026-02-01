################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/SBSFU/Target/sfu_low_level.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/SBSFU/Target/sfu_low_level_flash.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/SBSFU/Target/sfu_low_level_flash_ext.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/SBSFU/Target/sfu_low_level_flash_int.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/SBSFU/Target/sfu_low_level_security.c 

OBJS += \
./Application/SBSFU/Target/sfu_low_level.o \
./Application/SBSFU/Target/sfu_low_level_flash.o \
./Application/SBSFU/Target/sfu_low_level_flash_ext.o \
./Application/SBSFU/Target/sfu_low_level_flash_int.o \
./Application/SBSFU/Target/sfu_low_level_security.o 

C_DEPS += \
./Application/SBSFU/Target/sfu_low_level.d \
./Application/SBSFU/Target/sfu_low_level_flash.d \
./Application/SBSFU/Target/sfu_low_level_flash_ext.d \
./Application/SBSFU/Target/sfu_low_level_flash_int.d \
./Application/SBSFU/Target/sfu_low_level_security.d 


# Each subdirectory must supply rules for building sources it contributes
Application/SBSFU/Target/sfu_low_level.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/SBSFU/Target/sfu_low_level.c Application/SBSFU/Target/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_STM32G0XX_NUCLEO -DUSE_HAL_DRIVER -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../1_Image_SECoreBin/Inc -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/SBSFU/Target/sfu_low_level_flash.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/SBSFU/Target/sfu_low_level_flash.c Application/SBSFU/Target/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_STM32G0XX_NUCLEO -DUSE_HAL_DRIVER -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../1_Image_SECoreBin/Inc -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/SBSFU/Target/sfu_low_level_flash_ext.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/SBSFU/Target/sfu_low_level_flash_ext.c Application/SBSFU/Target/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_STM32G0XX_NUCLEO -DUSE_HAL_DRIVER -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../1_Image_SECoreBin/Inc -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/SBSFU/Target/sfu_low_level_flash_int.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/SBSFU/Target/sfu_low_level_flash_int.c Application/SBSFU/Target/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_STM32G0XX_NUCLEO -DUSE_HAL_DRIVER -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../1_Image_SECoreBin/Inc -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/SBSFU/Target/sfu_low_level_security.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SBSFU/SBSFU/Target/sfu_low_level_security.c Application/SBSFU/Target/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_STM32G0XX_NUCLEO -DUSE_HAL_DRIVER -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../1_Image_SECoreBin/Inc -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Application-2f-SBSFU-2f-Target

clean-Application-2f-SBSFU-2f-Target:
	-$(RM) ./Application/SBSFU/Target/sfu_low_level.cyclo ./Application/SBSFU/Target/sfu_low_level.d ./Application/SBSFU/Target/sfu_low_level.o ./Application/SBSFU/Target/sfu_low_level.su ./Application/SBSFU/Target/sfu_low_level_flash.cyclo ./Application/SBSFU/Target/sfu_low_level_flash.d ./Application/SBSFU/Target/sfu_low_level_flash.o ./Application/SBSFU/Target/sfu_low_level_flash.su ./Application/SBSFU/Target/sfu_low_level_flash_ext.cyclo ./Application/SBSFU/Target/sfu_low_level_flash_ext.d ./Application/SBSFU/Target/sfu_low_level_flash_ext.o ./Application/SBSFU/Target/sfu_low_level_flash_ext.su ./Application/SBSFU/Target/sfu_low_level_flash_int.cyclo ./Application/SBSFU/Target/sfu_low_level_flash_int.d ./Application/SBSFU/Target/sfu_low_level_flash_int.o ./Application/SBSFU/Target/sfu_low_level_flash_int.su ./Application/SBSFU/Target/sfu_low_level_security.cyclo ./Application/SBSFU/Target/sfu_low_level_security.d ./Application/SBSFU/Target/sfu_low_level_security.o ./Application/SBSFU/Target/sfu_low_level_security.su

.PHONY: clean-Application-2f-SBSFU-2f-Target

