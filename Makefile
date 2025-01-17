#############################################
# Setup Build Environment / Variables       #
#############################################

# Things you might need to change:
#   - MONITOR_PORT / AVRDUDE_UART_PORT (see NOTE below)
#   - BOARD_TAG / BOARD_SUB
#   - AVR_TOOLS_PATH
#   - AVRDUDE
#
# If you have trouble, look at those values first.

### Base directory for project
PROJECT_DIR        = $(shell readlink -f .)

### Emit assembly / Enablie compiler debugging (1=enable, 0=disable)
ASM_EXPORT         = 0
DEBUG_FLAG         = 0

### Hardware Settings
# NOTE: You might just want to comment this whole block out and set the values
# for `MONITOR_PORT` and `AVRDUDE_UART_PORT` manually. This is trying to be fancy
# and detect if the host OS is Linux or MacOS, but it's really just brittle...
ifneq "$(shell uname)" "Linux"
    ifeq "0" "$(shell test -a /dev/cu.SLAB_USBtoUART; echo $$?)"
        MONITOR_PORT         = /dev/cu.SLAB_USBtoUART
        AVRDUDE_UART_PORT    = -P /dev/cu.SLAB_USBtoUART
    else
        MONITOR_PORT         = /dev/tty.usbmodem*
        AVRDUDE_USB_PORT     = -P /dev/tty.usbmodem*
    endif
else
    ifeq "0" "$(shell test -a /dev/ttyUSB0; echo $$?)"
        MONITOR_PORT         = /dev/ttyUSB0
        AVRDUDE_UART_PORT    = -P /dev/ttyUSB0
    endif
    ifeq "0" "$(shell for f in /sys/bus/hid/devices/*; do grep -q 'Arduino Keyboard' $$f/uevent && echo 0 && break; done)"
        MONITOR_PORT         = /dev/hidraw2
        AVRDUDE_USB_PORT     = -P /hidraw2
    endif
    ifeq "0" "$(shell test -a /dev/ttyACM0; echo $$?)"
        MONITOR_PORT         = /dev/ttyACM0
        AVRDUDE_UART_PORT    = -P /dev/ttyACM0
    endif
endif

GET_MONITOR_PORT       = $(if $(wildcard $(MONITOR_PORT)),              \
                              $(firstword $(wildcard $(MONITOR_PORT))), \
                              $(error Arduino port $(MONITOR_PORT) not found!))

AVRDUDE_DEFAULT_OPTS   = -q -v -p $(MCU) -C $(AVRDUDE_CONF) -D \
                           -c $(AVRDUDE_ARD_PROGRAMMER) -b $(AVRDUDE_ARD_BAUDRATE)
AVRDUDE_DEFAULT_PORT   = -P $(call GET_MONITOR_PORT)
AVRDUDE_UPLOAD_HEX     = -U flash:w:$(TARGET_HEX):i
AVRDUDE_UPLOAD_EEP     = -U eeprom:w:$(TARGET_EEP):i


### Set to the board you are currently using.
### (i.e BOARD_TAG = uno, mega, etc. & BOARD_SUB = atmega2560, etc.)
### Note: for the Arduino Uno, only BOARD_TAG is mandatory.
ARDUINO_VERSION    = 100
BOARD_TAG          = uno
BOARD_SUB          = 

### File Paths
AVR_TOOLS_PATH     = /usr/bin
LIB_PATH           = lib
INCLUDE_PATH       = include
TARGET             = $(notdir $(subst $(shell echo " "),_,$(PROJECT_DIR)))
OBJ_DIR            = obj
BIN_DIR            = bin
USER_SRC_DIR       = src
HARDWARE_DIR       = etc
AVRDUDE_CONF       = $(HARDWARE_DIR)/avrdude.conf
CORE_PATH          = core

### Executables used throughout the build process
CC                 = $(AVR_TOOLS_PATH)/avr-gcc
CXX                = $(AVR_TOOLS_PATH)/avr-g++
OBJCOPY            = $(AVR_TOOLS_PATH)/avr-objcopy
OBJDUMP            = $(AVR_TOOLS_PATH)/avr-objdump
AR                 = $(AVR_TOOLS_PATH)/avr-gcc-ar
SIZE               = $(AVR_TOOLS_PATH)/avr-size
NM                 = $(AVR_TOOLS_PATH)/avr-nm
AVRDUDE            = $(AVR_TOOLS_PATH)/avrdude
REMOVE             = rm -rf
COPY               = cp -f
ECHO               = printf
MKDIR              = mkdir -p


###### STOP ######
# you probably don't need to change anything past here.

#############################################
# Setup Hardware Variables                  #
#############################################

BOARD_TAG               := $(strip $(BOARD_TAG))
BOARD_SUB               := $(strip $(BOARD_SUB))
BOARDS_TXT               = $(HARDWARE_DIR)/boards.txt
PARSE_BOARD              = $(shell grep -Ev '^\#' $(BOARDS_TXT) \
                                   | grep -P '^$(1)\.(\w+\.)*$(2)\.?(\w+\.)*$(3)=(\w|\d|\/|\_|\.)+\s*$$'  \
                                   | sed 's/.*=\(.*\)/\1/')
MCU                     := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),build.mcu)
F_CPU                   := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),build.f_cpu)
AVRDUDE_ARD_PROGRAMMER  := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),upload.protocol)
ifeq '$(strip $(AVRDUDE_ARD_PROGRAMMER))' ''
    AVRDUDE_ARD_PROGRAMMER  = arduino
endif
AVRDUDE_ARD_BAUDRATE    := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),upload.speed)
HEX_MAXIMUM_SIZE        := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),upload.maximum_size)


#############################################
# Configure Source Code & Library Structure #
#############################################

USER_C_SRCS     = $(wildcard *.c) $(wildcard $(USER_SRC_DIR)/*.c)
USER_CXX_SRCS   = $(wildcard *.cpp) $(wildcard $(USER_SRC_DIR)/*.cpp)
USER_CC_SRCS    = $(wildcard *.cc) $(wildcard $(USER_SRC_DIR)/*.cc)
USER_AS_SRCS    = $(wildcard *.S) $(wildcard $(USER_SRC_DIR)/*.S)
USER_SRCS       = $(USER_C_SRCS)   $(USER_CXX_SRCS)  \
		      $(USER_CC_SRCS)   $(USER_AS_SRCS)
USER_OBJ_FILES  = $(USER_C_SRCS:.c=.c.o)   $(USER_CXX_SRCS:.cpp=.cpp.o)  \
		      $(USER_CC_SRCS:.cc=.cc.o)   $(USER_AS_SRCS:.S=.S.o)
USER_OBJS       = $(patsubst $(USER_SRC_DIR)/%, $(OBJ_DIR)/%, $(USER_OBJ_FILES))

CORE_C_SRCS     = $(wildcard $(CORE_PATH)/*.c)
CORE_CXX_SRCS   = $(wildcard $(CORE_PATH)/*.cpp)
CORE_AS_SRCS    = $(wildcard $(CORE_PATH)/*.S)
CORE_OBJ_FILES  = $(CORE_C_SRCS:.c=.c.o) $(CORE_CXX_SRCS:.cpp=.cpp.o) $(CORE_AS_SRCS:.S=.S.o)
CORE_OBJS       = $(patsubst $(CORE_PATH)/%, $(OBJ_DIR)/core/%, $(CORE_OBJ_FILES))

ifeq ($(words $(USER_SRCS)), 0)
    $(error At least one source file is needed)
endif


#############################################
# Prepare Libraries and Headers to Include  #
#############################################

USER_LIBS              = $(shell find $(LIB_PATH) -type d | sed s/^/-I/)  \
                             $(shell find $(INCLUDE_PATH) -type d | sed s/^/-I/)
CORE_LIBS              = $(shell find $(CORE_PATH) -type d | sed s/^/-I/)

USER_LIB_CXX_SRCS     := $(shell find $(LIB_PATH) -type f -name "*.[cC][pP][pP]" | tr "\n" " ")
USER_LIB_C_SRCS       := $(shell find $(LIB_PATH) -type f -name "*.[cC]" | tr "\n" " ")
USER_LIB_AS_SRCS      := $(shell find $(LIB_PATH) -type f -name "*.[sS]" | tr "\n" " ")
USER_LIB_OBJS         := $(patsubst $(LIB_PATH)/%.cpp, $(OBJ_DIR)/%.cpp.o, $(USER_LIB_CXX_SRCS))  \
                             $(patsubst $(LIB_PATH)/%.c, $(OBJ_DIR)/%.c.o, $(USER_LIB_C_SRCS))    \
                             $(patsubst $(LIB_PATH)/%.S, $(OBJ_DIR)/%.S.o, $(USER_LIB_AS_SRCS))


#############################################
# Set the Build Flags                       #
#############################################

#%SoftwareSerial.cpp.o : OPTIMIZATION_FLAGS = -Os
OPTIMIZATION_FLAGS = -Os
ifeq  "$(DEBUG_FLAG)" "1"
    OPTIMIZATION_LEVEL = 0
    OPTIMIZATION_FLAGS = -O$(OPTIMIZATION_LEVEL) -g -pedantic -Wall -Wextra 
else
    OPTIMIZATION_LEVEL = s
    OPTIMIZATION_FLAGS = -O$(OPTIMIZATION_LEVEL)
endif

COMMON_FLAGS           = -DF_CPU=$(F_CPU) -DARDUINO=$(ARDUINO_VERSION) -DARDUINO_ARCH_AVR -D__PROG_TYPES_COMPAT__    \
                             -mmcu=$(MCU) -I$(CORE_PATH) -I$(INCLUDE_PATH) $(USER_LIBS) $(CORE_LIBS) \
                             -Wall -ffunction-sections -fdata-sections -flto 
CXXFLAGS               = $(COMMON_FLAGS) -std=c++11 $(OPTIMIZATION_FLAGS) -fpermissive -fno-exceptions 
CFLAGS                 = $(COMMON_FLAGS) -std=gnu11 -fno-fat-lto-objects $(OPTIMIZATION_FLAGS)
ASFLAGS                = $(COMMON_FLAGS) -x assembler-with-cpp 
LDFLAGS                = -mmcu=$(MCU) -Wl,--gc-sections -O$(OPTIMIZATION_LEVEL) -flto -fuse-linker-plugin
SIZEFLAGS              = --mcu=$(MCU)

ifeq "$(ASM_EXPORT)" "1"
    CFLAGS            += -S
    CXXFLAGS          += -S
endif

avr_size               = $(SIZE) $(SIZEFLAGS) --format=avr $(1)


#############################################
# Main Build Targets                        #
#############################################

TARGET_HEX   = $(OBJ_DIR)/$(TARGET).hex
TARGET_ELF   = $(OBJ_DIR)/$(TARGET).elf
TARGET_EEP   = $(OBJ_DIR)/$(TARGET).eep
LIB_CORE     = $(OBJ_DIR)/libcore.a


#############################################
# Implicit Build Rules                      #
#############################################

# library sources
$(OBJ_DIR)/%.cpp.o: $(LIB_PATH)/%.cpp | $(OBJ_DIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CXXFLAGS) $< -o $@

$(OBJ_DIR)/%.c.o: $(LIB_PATH)/%.c | $(OBJ_DIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CFLAGS) $< -o $@

$(OBJ_DIR)/%.S.o: $(LIB_PATH)/%.S | $(OBJ_DIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(ASFLAGS) $< -o $@

ifdef COMMON_DEPS
    COMMON_DEPS := $(COMMON_DEPS) $(MAKEFILE_LIST)
else
    COMMON_DEPS := $(MAKEFILE_LIST)
endif

# normal local sources
$(OBJ_DIR)/%.c.o: $(USER_SRC_DIR)/%.c $(COMMON_DEPS) | $(OBJ_DIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CFLAGS) $< -o $@

$(OBJ_DIR)/%.cc.o: $(USER_SRC_DIR)/%.cc $(COMMON_DEPS) | $(OBJ_DIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CXXFLAGS) $< -o $@

$(OBJ_DIR)/%.cpp.o: $(USER_SRC_DIR)/%.cpp $(COMMON_DEPS) | $(OBJ_DIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CXXFLAGS) $< -o $@

$(OBJ_DIR)/%.S.o: $(USER_SRC_DIR)/%.S $(COMMON_DEPS) | $(OBJ_DIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(ASFLAGS) $< -o $@

$(OBJ_DIR)/%.s.o: $(USER_SRC_DIR)/%.s $(COMMON_DEPS) | $(OBJ_DIR)
	@$(MKDIR) $(dir $@)
	$(CC) -c $(ASFLAGS) $< -o $@

# core files
$(OBJ_DIR)/core/%.c.o: $(CORE_PATH)/%.c $(COMMON_DEPS) | $(OBJ_DIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CFLAGS) $< -o $@

$(OBJ_DIR)/core/%.cpp.o: $(CORE_PATH)/%.cpp $(COMMON_DEPS) | $(OBJ_DIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CXXFLAGS) $< -o $@

$(OBJ_DIR)/core/%.S.o: $(CORE_PATH)/%.S $(COMMON_DEPS) | $(OBJ_DIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(ASFLAGS) $< -o $@


# various object conversions
$(OBJ_DIR)/%.hex: $(OBJ_DIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(OBJCOPY) -O ihex -R .eeprom $< $@
	@$(ECHO) '\n'
	$(call avr_size,$<,$@)
ifneq ($(strip $(HEX_MAXIMUM_SIZE)),)
	@if [ `$(SIZE) $@ | awk 'FNR == 2 {print $$2}'` -le $(HEX_MAXIMUM_SIZE) ]; then touch $@.sizeok; fi
else
	@$(ECHO) "Maximum flash memory of $(BOARD_TAG) is not specified."
	@$(ECHO) "Make sure the size of $@ is less than $(BOARD_TAG)\'s flash memory"
	@touch $@.sizeok
endif
	$(COPY) $@ $(BIN_DIR)/$(TARGET).hex

$(OBJ_DIR)/%.eep: $(OBJ_DIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom='alloc,load' \
		--no-change-warnings --change-section-lma .eeprom=0 -O ihex $< $@
	$(COPY) $@ $(BIN_DIR)/$(TARGET).eep

$(OBJ_DIR)/%.lss: $(OBJ_DIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(OBJDUMP) -h --source --demangle --wide $< > $@

$(OBJ_DIR)/%.sym: $(OBJ_DIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(NM) --size-sort --demangle --reverse-sort --line-numbers $< > $@


#############################################
# Explicit Build Targets                    #
#############################################

all: $(TARGET_EEP) $(TARGET_HEX)

# Rule to create $(OBJ_DIR) automatically. All rules with recipes that
# create a file within it, but do not already depend on a file within it
# should depend on this rule. They should use a "order-only
# prerequisite" (e.g., put "| $(OBJ_DIR)" at the end of the prerequisite
# list) to prevent remaking the target when any file in the directory
# changes.
$(OBJ_DIR): 
	$(MKDIR) $(OBJ_DIR)

$(TARGET_ELF): $(USER_OBJS) $(LIB_CORE) $(OTHER_OBJS)
	$(MKDIR) $(BIN_DIR)
	$(CC) $(LDFLAGS) -o $@ $(USER_OBJS) $(LIB_CORE) $(OTHER_OBJS) $(OTHER_LIBS) -lc -lm $(LINKER_SCRIPTS)
	$(COPY) $@ $(BIN_DIR)/$(TARGET).elf

$(LIB_CORE): $(CORE_OBJS) $(USER_LIB_OBJS) $(USER_OBJS)
	$(AR) rcs $@ $(CORE_OBJS) $(USER_LIB_OBJS) $(USER_OBJS)

upload:	$(TARGET_HEX)
	$(RESET_CMD)
	$(AVRDUDE) $(AVRDUDE_DEFAULT_OPTS) $(AVRDUDE_DEFAULT_PORT) $(AVRDUDE_UPLOAD_HEX)

eeprom:	$(TARGET_HEX) $(TARGET_EEP) $(TARGET_HEX)
	$(RESET_CMD)
	$(AVRDUDE) $(AVRDUDE_DEFAULT_OPTS) $(AVRDUDE_UPLOAD_EEP)

clean:
	$(REMOVE) $(OBJ_DIR)
	$(REMOVE) $(BIN_DIR)/$(TARGET).hex
	$(REMOVE) $(BIN_DIR)/$(TARGET).elf
	$(REMOVE) $(BIN_DIR)/$(TARGET).eep

size: $(TARGET_HEX)
	$(call avr_size,$(TARGET_ELF),$(TARGET_HEX))

disasm: $(OBJ_DIR)/$(TARGET).lss
	@$(ECHO) "The compiled ELF file has been disassembled to $(OBJ_DIR)/$(TARGET).lss\n\n"

symbol_sizes: $(OBJ_DIR)/$(TARGET).sym
	@$(ECHO) "A symbol listing sorted by their size have been dumped to $(OBJ_DIR)/$(TARGET).sym\n\n"

help:
	@$(ECHO) "\nAvailable targets:\n\
  make                   - compile the code\n\
  make upload            - upload to board using default port\n\
  make eeprom            - upload the eep file\n\
  make clean             - remove all our dependencies\n\
  make size              - show the size of the compiled output (relative to\n\
                           resources, if you have a patched avr-size).\n\
  make symbol_sizes      - generate a .sym file containing symbols and their\n\
                           sizes.\n\
  make disasm            - generate a .lss file that contains disassembly\n\
                           of the compiled file interspersed with your\n\
                           original source code.\n\
  make asm               - output the resulting assembly code for the main\n\
                           user-defined source file, into the OBJ_DIR directory\n\
        (NOTE: Need to implement 'asm')\n\n"

