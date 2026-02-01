################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_interface_application.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_interface_bootloader.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_interface_common.c 

OBJS += \
./Middlewares/STM32_Secure_Engine/se_interface_application.o \
./Middlewares/STM32_Secure_Engine/se_interface_bootloader.o \
./Middlewares/STM32_Secure_Engine/se_interface_common.o 

C_DEPS += \
./Middlewares/STM32_Secure_Engine/se_interface_application.d \
./Middlewares/STM32_Secure_Engine/se_interface_bootloader.d \
./Middlewares/STM32_Secure_Engine/se_interface_common.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/STM32_Secure_Engine/se_interface_application.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_interface_application.c Middlewares/STM32_Secure_Engine/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_STM32G0XX_NUCLEO -DUSE_HAL_DRIVER -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../1_Image_SECoreBin/Inc -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Middlewares/STM32_Secure_Engine/se_interface_bootloader.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_interface_bootloader.c Middlewares/STM32_Secure_Engine/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_STM32G0XX_NUCLEO -DUSE_HAL_DRIVER -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../1_Image_SECoreBin/Inc -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Middlewares/STM32_Secure_Engine/se_interface_common.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_interface_common.c Middlewares/STM32_Secure_Engine/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_STM32G0XX_NUCLEO -DUSE_HAL_DRIVER -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../1_Image_SECoreBin/Inc -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Middlewares-2f-STM32_Secure_Engine

clean-Middlewares-2f-STM32_Secure_Engine:
	-$(RM) ./Middlewares/STM32_Secure_Engine/se_interface_application.cyclo ./Middlewares/STM32_Secure_Engine/se_interface_application.d ./Middlewares/STM32_Secure_Engine/se_interface_application.o ./Middlewares/STM32_Secure_Engine/se_interface_application.su ./Middlewares/STM32_Secure_Engine/se_interface_bootloader.cyclo ./Middlewares/STM32_Secure_Engine/se_interface_bootloader.d ./Middlewares/STM32_Secure_Engine/se_interface_bootloader.o ./Middlewares/STM32_Secure_Engine/se_interface_bootloader.su ./Middlewares/STM32_Secure_Engine/se_interface_common.cyclo ./Middlewares/STM32_Secure_Engine/se_interface_common.d ./Middlewares/STM32_Secure_Engine/se_interface_common.o ./Middlewares/STM32_Secure_Engine/se_interface_common.su

.PHONY: clean-Middlewares-2f-STM32_Secure_Engine

