################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_callgate.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_crypto_common.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_exception.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_fwimg.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_startup.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_user_application.c \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_utils.c 

OBJS += \
./Middlewares/STM32_Secure_Engine/se_callgate.o \
./Middlewares/STM32_Secure_Engine/se_crypto_common.o \
./Middlewares/STM32_Secure_Engine/se_exception.o \
./Middlewares/STM32_Secure_Engine/se_fwimg.o \
./Middlewares/STM32_Secure_Engine/se_startup.o \
./Middlewares/STM32_Secure_Engine/se_user_application.o \
./Middlewares/STM32_Secure_Engine/se_utils.o 

C_DEPS += \
./Middlewares/STM32_Secure_Engine/se_callgate.d \
./Middlewares/STM32_Secure_Engine/se_crypto_common.d \
./Middlewares/STM32_Secure_Engine/se_exception.d \
./Middlewares/STM32_Secure_Engine/se_fwimg.d \
./Middlewares/STM32_Secure_Engine/se_startup.d \
./Middlewares/STM32_Secure_Engine/se_user_application.d \
./Middlewares/STM32_Secure_Engine/se_utils.d 


# Each subdirectory must supply rules for building sources it contributes
Middlewares/STM32_Secure_Engine/se_callgate.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_callgate.c Middlewares/STM32_Secure_Engine/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Key -I../../../1_Image_SBSFU/SBSFU/App -I../../../1_Image_SBSFU/SBSFU/Target -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Inc -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Middlewares/STM32_Secure_Engine/se_crypto_common.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_crypto_common.c Middlewares/STM32_Secure_Engine/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Key -I../../../1_Image_SBSFU/SBSFU/App -I../../../1_Image_SBSFU/SBSFU/Target -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Inc -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Middlewares/STM32_Secure_Engine/se_exception.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_exception.c Middlewares/STM32_Secure_Engine/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Key -I../../../1_Image_SBSFU/SBSFU/App -I../../../1_Image_SBSFU/SBSFU/Target -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Inc -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Middlewares/STM32_Secure_Engine/se_fwimg.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_fwimg.c Middlewares/STM32_Secure_Engine/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Key -I../../../1_Image_SBSFU/SBSFU/App -I../../../1_Image_SBSFU/SBSFU/Target -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Inc -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Middlewares/STM32_Secure_Engine/se_startup.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_startup.c Middlewares/STM32_Secure_Engine/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Key -I../../../1_Image_SBSFU/SBSFU/App -I../../../1_Image_SBSFU/SBSFU/Target -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Inc -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Middlewares/STM32_Secure_Engine/se_user_application.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_user_application.c Middlewares/STM32_Secure_Engine/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Key -I../../../1_Image_SBSFU/SBSFU/App -I../../../1_Image_SBSFU/SBSFU/Target -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Inc -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"
Middlewares/STM32_Secure_Engine/se_utils.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Middlewares/ST/STM32_Secure_Engine/Core/se_utils.c Middlewares/STM32_Secure_Engine/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m0plus -std=gnu11 -g3 -DSTM32G071xx -DUSE_HAL_DRIVER -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32G0xx/Include -I../../../../../../../Drivers/STM32G0xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32G0xx_Nucleo -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Key -I../../../1_Image_SBSFU/SBSFU/App -I../../../1_Image_SBSFU/SBSFU/Target -I../../../Linker_Common/STM32CubeIDE -I../../../../../../../Middlewares/ST/STM32_Cryptographic/Fw_Crypto/STM32G0/Inc -I../../../../../../../Drivers/CMSIS/Include -Os -ffunction-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-Middlewares-2f-STM32_Secure_Engine

clean-Middlewares-2f-STM32_Secure_Engine:
	-$(RM) ./Middlewares/STM32_Secure_Engine/se_callgate.cyclo ./Middlewares/STM32_Secure_Engine/se_callgate.d ./Middlewares/STM32_Secure_Engine/se_callgate.o ./Middlewares/STM32_Secure_Engine/se_callgate.su ./Middlewares/STM32_Secure_Engine/se_crypto_common.cyclo ./Middlewares/STM32_Secure_Engine/se_crypto_common.d ./Middlewares/STM32_Secure_Engine/se_crypto_common.o ./Middlewares/STM32_Secure_Engine/se_crypto_common.su ./Middlewares/STM32_Secure_Engine/se_exception.cyclo ./Middlewares/STM32_Secure_Engine/se_exception.d ./Middlewares/STM32_Secure_Engine/se_exception.o ./Middlewares/STM32_Secure_Engine/se_exception.su ./Middlewares/STM32_Secure_Engine/se_fwimg.cyclo ./Middlewares/STM32_Secure_Engine/se_fwimg.d ./Middlewares/STM32_Secure_Engine/se_fwimg.o ./Middlewares/STM32_Secure_Engine/se_fwimg.su ./Middlewares/STM32_Secure_Engine/se_startup.cyclo ./Middlewares/STM32_Secure_Engine/se_startup.d ./Middlewares/STM32_Secure_Engine/se_startup.o ./Middlewares/STM32_Secure_Engine/se_startup.su ./Middlewares/STM32_Secure_Engine/se_user_application.cyclo ./Middlewares/STM32_Secure_Engine/se_user_application.d ./Middlewares/STM32_Secure_Engine/se_user_application.o ./Middlewares/STM32_Secure_Engine/se_user_application.su ./Middlewares/STM32_Secure_Engine/se_utils.cyclo ./Middlewares/STM32_Secure_Engine/se_utils.d ./Middlewares/STM32_Secure_Engine/se_utils.o ./Middlewares/STM32_Secure_Engine/se_utils.su

.PHONY: clean-Middlewares-2f-STM32_Secure_Engine

