################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Application/User/data_init.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/Src/se_crypto_bootloader.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/Src/se_low_level.c \
../Application/User/syscalls.c 

OBJS += \
./Application/User/data_init.o \
./Application/User/se_crypto_bootloader.o \
./Application/User/se_low_level.o \
./Application/User/syscalls.o 

C_DEPS += \
./Application/User/data_init.d \
./Application/User/se_crypto_bootloader.d \
./Application/User/se_low_level.d \
./Application/User/syscalls.d 


# Each subdirectory must supply rules for building sources it contributes
Application/User/%.o Application/User/%.su Application/User/%.cyclo: ../Application/User/%.c Application/User/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Key -I../../../1_Image_SBSFU/SBSFU/App -I../../../1_Image_SBSFU/SBSFU/Target -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Inc -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/User/se_crypto_bootloader.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/Src/se_crypto_bootloader.c Application/User/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Key -I../../../1_Image_SBSFU/SBSFU/App -I../../../1_Image_SBSFU/SBSFU/Target -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Inc -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Application/User/se_low_level.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/NUCLEO-G071RB/Applications/1_Image/1_Image_SECoreBin/Src/se_low_level.c Application/User/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Key -I../../../1_Image_SBSFU/SBSFU/App -I../../../1_Image_SBSFU/SBSFU/Target -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Inc -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Application-2f-User

clean-Application-2f-User:
	-$(RM) ./Application/User/data_init.cyclo ./Application/User/data_init.d ./Application/User/data_init.o ./Application/User/data_init.su ./Application/User/se_crypto_bootloader.cyclo ./Application/User/se_crypto_bootloader.d ./Application/User/se_crypto_bootloader.o ./Application/User/se_crypto_bootloader.su ./Application/User/se_low_level.cyclo ./Application/User/se_low_level.d ./Application/User/se_low_level.o ./Application/User/se_low_level.su ./Application/User/syscalls.cyclo ./Application/User/syscalls.d ./Application/User/syscalls.o ./Application/User/syscalls.su

.PHONY: clean-Application-2f-User

