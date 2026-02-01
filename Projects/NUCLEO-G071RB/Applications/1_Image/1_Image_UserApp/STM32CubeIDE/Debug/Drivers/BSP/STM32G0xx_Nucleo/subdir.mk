################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Drivers/BSP/STM32G0xx_Nucleo/stm32g0xx_nucleo.c 

OBJS += \
./Drivers/BSP/STM32G0xx_Nucleo/stm32g0xx_nucleo.o 

C_DEPS += \
./Drivers/BSP/STM32G0xx_Nucleo/stm32g0xx_nucleo.d 


# Each subdirectory must supply rules for building sources it contributes
Drivers/BSP/STM32G0xx_Nucleo/stm32g0xx_nucleo.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Drivers/BSP/STM32G0xx_Nucleo/stm32g0xx_nucleo.c Drivers/BSP/STM32G0xx_Nucleo/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_STM32G0XX_NUCLEO -DUSE_HAL_DRIVER -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../1_Image_SECoreBin/Inc -I../../../1_Image_SBSFU/SBSFU/App -I../../../../../../../Drivers/CMSIS/Include -I../../../Linker_Common/STM32CubeIDE -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Drivers-2f-BSP-2f-STM32G0xx_Nucleo

clean-Drivers-2f-BSP-2f-STM32G0xx_Nucleo:
	-$(RM) ./Drivers/BSP/STM32G0xx_Nucleo/stm32g0xx_nucleo.cyclo ./Drivers/BSP/STM32G0xx_Nucleo/stm32g0xx_nucleo.d ./Drivers/BSP/STM32G0xx_Nucleo/stm32g0xx_nucleo.o ./Drivers/BSP/STM32G0xx_Nucleo/stm32g0xx_nucleo.su

.PHONY: clean-Drivers-2f-BSP-2f-STM32G0xx_Nucleo

