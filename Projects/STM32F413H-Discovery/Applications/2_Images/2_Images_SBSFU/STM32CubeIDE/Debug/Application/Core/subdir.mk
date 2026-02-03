################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_SBSFU/Core/Src/main.c \
../Application/Core/sfu_secorebin_Inc.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_SBSFU/Core/Src/stm32f4xx_hal_msp.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_SBSFU/Core/Src/stm32f4xx_it.c \
../Application/Core/syscalls.c 

OBJS += \
./Application/Core/main.o \
./Application/Core/sfu_secorebin_Inc.o \
./Application/Core/stm32f4xx_hal_msp.o \
./Application/Core/stm32f4xx_it.o \
./Application/Core/syscalls.o 

C_DEPS += \
./Application/Core/main.d \
./Application/Core/sfu_secorebin_Inc.d \
./Application/Core/stm32f4xx_hal_msp.d \
./Application/Core/stm32f4xx_it.d \
./Application/Core/syscalls.d 


# Each subdirectory must supply rules for building sources it contributes
Application/Core/main.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_SBSFU/Core/Src/main.c Application/Core/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DSTM32F413xx -DUSE_HAL_DRIVER -DUSE_STM32F413H_DISCOVERY -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../../../../../Drivers/CMSIS/Include -I../../../../../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32F413H-Discovery -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Utilities/Fonts -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../2_Images_SECoreBin/Inc -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../Linker_Common/STM32CubeIDE -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Application/Core/%.o Application/Core/%.su Application/Core/%.cyclo: ../Application/Core/%.c Application/Core/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DSTM32F413xx -DUSE_HAL_DRIVER -DUSE_STM32F413H_DISCOVERY -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../../../../../Drivers/CMSIS/Include -I../../../../../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32F413H-Discovery -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Utilities/Fonts -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../2_Images_SECoreBin/Inc -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../Linker_Common/STM32CubeIDE -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Application/Core/stm32f4xx_hal_msp.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_SBSFU/Core/Src/stm32f4xx_hal_msp.c Application/Core/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DSTM32F413xx -DUSE_HAL_DRIVER -DUSE_STM32F413H_DISCOVERY -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../../../../../Drivers/CMSIS/Include -I../../../../../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32F413H-Discovery -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Utilities/Fonts -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../2_Images_SECoreBin/Inc -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../Linker_Common/STM32CubeIDE -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"
Application/Core/stm32f4xx_it.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_SBSFU/Core/Src/stm32f4xx_it.c Application/Core/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DSTM32F413xx -DUSE_HAL_DRIVER -DUSE_STM32F413H_DISCOVERY -c -I../../../../../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../../../../../Drivers/CMSIS/Include -I../../../../../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32F413H-Discovery -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Utilities/Fonts -I../../Core/Inc -I../../SBSFU/App -I../../SBSFU/Target -I../../../2_Images_SECoreBin/Inc -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Interface -I../../../Linker_Common/STM32CubeIDE -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Application-2f-Core

clean-Application-2f-Core:
	-$(RM) ./Application/Core/main.cyclo ./Application/Core/main.d ./Application/Core/main.o ./Application/Core/main.su ./Application/Core/sfu_secorebin_Inc.cyclo ./Application/Core/sfu_secorebin_Inc.d ./Application/Core/sfu_secorebin_Inc.o ./Application/Core/sfu_secorebin_Inc.su ./Application/Core/stm32f4xx_hal_msp.cyclo ./Application/Core/stm32f4xx_hal_msp.d ./Application/Core/stm32f4xx_hal_msp.o ./Application/Core/stm32f4xx_hal_msp.su ./Application/Core/stm32f4xx_it.cyclo ./Application/Core/stm32f4xx_it.d ./Application/Core/stm32f4xx_it.o ./Application/Core/stm32f4xx_it.su ./Application/Core/syscalls.cyclo ./Application/Core/syscalls.d ./Application/Core/syscalls.o ./Application/Core/syscalls.su

.PHONY: clean-Application-2f-Core

