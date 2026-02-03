################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Drivers/BSP/STM32F413H-Discovery/stm32f413h_discovery.c 

OBJS += \
./Drivers/BSP/STM32F413H-Discovery/stm32f413h_discovery.o 

C_DEPS += \
./Drivers/BSP/STM32F413H-Discovery/stm32f413h_discovery.d 


# Each subdirectory must supply rules for building sources it contributes
Drivers/BSP/STM32F413H-Discovery/stm32f413h_discovery.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Drivers/BSP/STM32F413H-Discovery/stm32f413h_discovery.c Drivers/BSP/STM32F413H-Discovery/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DSTM32F413xx -DUSE_HAL_DRIVER -DUSE_STM32F413H_DISCOVERY -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../../../../../Drivers/CMSIS/Include -I../../../../../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32F413H-Discovery -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Utilities/Fonts -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../2_Images_SECoreBin/Inc -I../../../2_Images_SBSFU/SBSFU/App -I../../../Linker_Common/STM32CubeIDE -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Drivers-2f-BSP-2f-STM32F413H-2d-Discovery

clean-Drivers-2f-BSP-2f-STM32F413H-2d-Discovery:
	-$(RM) ./Drivers/BSP/STM32F413H-Discovery/stm32f413h_discovery.cyclo ./Drivers/BSP/STM32F413H-Discovery/stm32f413h_discovery.d ./Drivers/BSP/STM32F413H-Discovery/stm32f413h_discovery.o ./Drivers/BSP/STM32F413H-Discovery/stm32f413h_discovery.su

.PHONY: clean-Drivers-2f-BSP-2f-STM32F413H-2d-Discovery

