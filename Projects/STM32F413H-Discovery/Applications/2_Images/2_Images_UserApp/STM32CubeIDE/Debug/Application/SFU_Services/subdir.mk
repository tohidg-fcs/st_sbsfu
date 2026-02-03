################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (13.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
/Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_UserApp/Src/sfu_app_new_image.c 

OBJS += \
./Application/SFU_Services/sfu_app_new_image.o 

C_DEPS += \
./Application/SFU_Services/sfu_app_new_image.d 


# Each subdirectory must supply rules for building sources it contributes
Application/SFU_Services/sfu_app_new_image.o: /Users/tohid/stm32Projects/sbsfu/st_sbsfu/Projects/STM32F413H-Discovery/Applications/2_Images/2_Images_UserApp/Src/sfu_app_new_image.c Application/SFU_Services/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DSTM32F413xx -DUSE_HAL_DRIVER -DUSE_STM32F413H_DISCOVERY -c -I../../Inc -I../../../../../../../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../../../../../../../Drivers/CMSIS/Include -I../../../../../../../Drivers/STM32F4xx_HAL_Driver/Inc -I../../../../../../../Drivers/BSP/STM32F413H-Discovery -I../../../../../../../Drivers/BSP/Components/Common -I../../../../../../../Utilities/Fonts -I../../../../../../../Middlewares/ST/STM32_Secure_Engine/Core -I../../../2_Images_SECoreBin/Inc -I../../../2_Images_SBSFU/SBSFU/App -I../../../Linker_Common/STM32CubeIDE -Os -ffunction-sections -Wall -Wno-format -Wno-strict-aliasing -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Application-2f-SFU_Services

clean-Application-2f-SFU_Services:
	-$(RM) ./Application/SFU_Services/sfu_app_new_image.cyclo ./Application/SFU_Services/sfu_app_new_image.d ./Application/SFU_Services/sfu_app_new_image.o ./Application/SFU_Services/sfu_app_new_image.su

.PHONY: clean-Application-2f-SFU_Services

