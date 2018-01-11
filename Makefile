
#############################################
# Useful Functions                          #
#############################################

# recursive wildcard function, call with params:
#  - start directory (finished with /) or empty string for current dir
#  - glob pattern
rwildcard = 
    $(foreach d,$(wildcard $1*), \
        $(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# Run a shell script if it exists. Stops make on error.
runscript_if_exists =                                                                      \
    $(if $(wildcard $(1)),                                                                 \
         $(if $(findstring 0, $(lastword $(shell $(abspath $(wildcard $(1))); echo $$?))), \
              $(info Info: $(1) success),                                                  \
              $(error ERROR: $(1) failed)))

# Gets include flags for library
get_library_includes = $(if $(and $(wildcard $(1)/src), $(wildcard $(1)/library.properties)), \
                           -I$(1)/src, $(addprefix -I,$(1) $(wildcard $(1)/utility)))

# Gets all sources with given extension (param2) for library (path = param1)
get_library_files  = $(if $(and $(wildcard $(1)/src), $(wildcard $(1)/library.properties)), \
                        $(call rwildcard,$(1)/src/,*.$(2)), $(wildcard $(1)/*.$(2) $(1)/utility/*.$(2)))


#############################################
# Setup Build Environment / Variables       #
#############################################

### Debugging Switches
ASM_EXPORT         = 0
DEBUG_FLAG         = 0

### Base directory for project
PROJECT_DIR        = /Users/z050789/Documents/personal/github_repos/Keyboard_Over_Serial

### Libraries to be included from project lib directory
ARDUINO_LIBS       = NewSoftSerial

### Hardware Settings
ifeq "$(shell ls /dev/cu.SLAB_USBtoUART &> /dev/null; echo $$?)" "0"
    MONITOR_PORT       = /dev/cu.SLAB_USBtoUART
else
    MONITOR_PORT       = /dev/tty.usbmodem*
endif
CURRENT_OS         = MAC
AVR_TOOLS_PATH     = /usr/local/bin
ARCHITECTURE       = avr
ARDUINO_ARCH_FLAG  = -DARDUINO_ARCH_AVR
ARDMK_VENDOR       = arduino
ARDUINO_VERSION    = 10802

### File Paths
USER_LIB_PATH      = $(PROJECT_DIR)/lib
USER_INCLUDE_PATH  = $(PROJECT_DIR)/include
TARGET             = $(notdir $(subst $(shell echo " "),_,$(PROJECT_DIR)))
OBJDIR             = $(PROJECT_DIR)/obj
USER_SRC_DIR       = $(PROJECT_DIR)/src
AVRDUDE_CONF       = $(PROJECT_DIR)/etc/avrdude.conf
ARDUINO_DIR        = $(PROJECT_DIR)/Arduino
ARDUINO_LIB_PATH   = $(ARDUINO_DIR)/libraries
ARDU_PLAT_LIB_PATH = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/libraries
ARDUINO_CORE_PATH  = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/cores/$(CORE)
ARDUINO_VAR_PATH   = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/variants
BOARDS_TXT         = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/boards.txt
PRE_BUILD_HOOK     = pre-build-hook.sh

### Executables used throughout the build process
CC                 = $(AVR_TOOLS_PATH)/avr-gcc
CXX                = $(AVR_TOOLS_PATH)/avr-g++
AS                 = $(AVR_TOOLS_PATH)/avr-as
OBJCOPY            = $(AVR_TOOLS_PATH)/avr-objcopy
OBJDUMP            = $(AVR_TOOLS_PATH)/avr-objdump
AR                 = $(AVR_TOOLS_PATH)/avr-gcc-ar
SIZE               = $(AVR_TOOLS_PATH)/avr-size
NM                 = $(AVR_TOOLS_PATH)/avr-nm
AVRDUDE            = $(AVR_TOOLS_PATH)/avrdude
REMOVE             = rm -rf
MV                 = mv -f
CAT                = cat
ECHO               = printf
MKDIR              = mkdir -p


#############################################
# Setup Hardware Variables                  #
#############################################

### Set to the board you are currently using. (i.e BOARD_TAG = uno, mega, etc. & BOARD_SUB = atmega2560, etc.)
### Note: for the Arduino Uno, only BOARD_TAG is mandatory and BOARD_SUB can be equal to anything
# BOARD_TAG              = pro
# BOARD_SUB              = 16MHzatmega328
BOARD_TAG                = uno
BOARD_SUB                =
CORE                     = $(call PARSE_BOARD,$(BOARD_TAG),build.core)
VARIANT                 := $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
BOARD_TAG               := $(strip $(BOARD_TAG))
BOARD_SUB               := $(strip $(BOARD_SUB))
PARSE_BOARD              = $(shell grep -Ev '^\#' $(BOARDS_TXT) | grep -E  '^$(1)\.(\w+\.)*$(2)\.?(\w+\.)*$(3)=(\w|\d|\/|\_|\.)+\s*$$' | sed 's/.*=\(.*\)/\1/')
MCU                     := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),build.mcu)
F_CPU                   := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),build.f_cpu)
USB_PID                 := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),build.pid)
AVRDUDE_ARD_PROGRAMMER  := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),upload.protocol)
ifeq '$(strip $(AVRDUDE_ARD_PROGRAMMER))' ''
    AVRDUDE_ARD_PROGRAMMER  = arduino
endif
AVRDUDE_ARD_BAUDRATE    := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),upload.speed)
BOOTLOADER_PATH          = $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),bootloader.path)
BOOTLOADER_FILE         := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),bootloader.file)
HEX_MAXIMUM_SIZE        := $(call PARSE_BOARD,$(BOARD_TAG),$(BOARD_SUB),upload.maximum_size)
ARD_RESET_ARDUINO        = $(PROJECT_DIR)/bin/ard-reset-arduino
DEVICE_PATH              = $(MONITOR_PORT)

get_monitor_port         = $(if $(wildcard $(DEVICE_PATH)),$(firstword $(wildcard $(DEVICE_PATH))),$(error Arduino port $(DEVICE_PATH) not found!))


#############################################
# Configure Source Code & Library Structure #
#############################################

###LOCAL_OBJS: /Users/z050789/Documents/personal/github_repos/build/obj//Users/z050789/Documents/personal/github_repos/build/src/transmitter.cpp.o
###LOCAL_OBJ_FILES: /Users/z050789/Documents/personal/github_repos/build/src/transmitter.cpp.o
###LOCAL_SRCS: /Users/z050789/Documents/personal/github_repos/build/src/transmitter.cpp

LOCAL_C_SRCS     = $(wildcard *.c)
LOCAL_CPP_SRCS   = $(wildcard *.cpp)
LOCAL_CC_SRCS    = $(wildcard *.cc)
LOCAL_AS_SRCS    = $(wildcard *.S)
LOCAL_C_SRCS    += $(wildcard $(USER_SRC_DIR)/*.c)
LOCAL_CPP_SRCS  += $(wildcard $(USER_SRC_DIR)/*.cpp)
LOCAL_CC_SRCS   += $(wildcard $(USER_SRC_DIR)/*.cc)
LOCAL_AS_SRCS   += $(wildcard $(USER_SRC_DIR)/*.S)
LOCAL_SRCS       = $(LOCAL_C_SRCS)   $(LOCAL_CPP_SRCS) \
		      $(LOCAL_CC_SRCS)   $(LOCAL_AS_SRCS)
LOCAL_OBJ_FILES  = $(LOCAL_C_SRCS:.c=.c.o)   $(LOCAL_CPP_SRCS:.cpp=.cpp.o) \
		      $(LOCAL_CC_SRCS:.cc=.cc.o)   $(LOCAL_AS_SRCS:.S=.S.o)
LOCAL_OBJS       = $(patsubst $(USER_SRC_DIR)/%,$(OBJDIR)/%,$(LOCAL_OBJ_FILES))
###LOCAL_OBJS      = $(LOCAL_OBJ_FILES)

ifeq ($(words $(LOCAL_SRCS)), 0)
    $(error At least one source file is needed)
endif

CORE_C_SRCS      = $(wildcard $(ARDUINO_CORE_PATH)/*.c)
CORE_C_SRCS     += $(wildcard $(ARDUINO_CORE_PATH)/avr-libc/*.c)
CORE_CPP_SRCS    = $(wildcard $(ARDUINO_CORE_PATH)/*.cpp)
CORE_AS_SRCS     = $(wildcard $(ARDUINO_CORE_PATH)/*.S)
CORE_OBJ_FILES   = $(CORE_C_SRCS:.c=.c.o) $(CORE_CPP_SRCS:.cpp=.cpp.o) $(CORE_AS_SRCS:.S=.S.o)
CORE_OBJS        = $(patsubst $(ARDUINO_CORE_PATH)/%, $(OBJDIR)/core/%,$(CORE_OBJ_FILES))

# automatically determine included libraries
ARDUINO_LIBS    += $(filter $(notdir $(wildcard $(ARDUINO_DIR)/libraries/*)), \
                      $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))
ARDUINO_LIBS    += $(filter $(notdir $(wildcard $(USER_LIB_PATH)/*)), \
                      $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))
ARDUINO_LIBS    += $(filter $(notdir $(wildcard $(ARDU_PLAT_LIB_PATH)/*)), \
                      $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))
ARDUINO_HEADER   = Arduino.h


#############################################
# Build Rules                               #
#############################################

# General arguments
USER_LIBS             := $(sort $(wildcard $(patsubst %,$(USER_LIB_PATH)/%,$(ARDUINO_LIBS))))
USER_LIB_NAMES        := $(patsubst $(USER_LIB_PATH)/%,%,$(USER_LIBS))

# Let user libraries override system ones.
SYS_LIBS              := $(sort $(wildcard $(patsubst %,$(ARDUINO_LIB_PATH)/%,$(filter-out $(USER_LIB_NAMES),$(ARDUINO_LIBS)))))
SYS_LIB_NAMES         := $(patsubst $(ARDUINO_LIB_PATH)/%,%,$(SYS_LIBS))

# Let user libraries override platform ones.
PLATFORM_LIBS         := $(sort $(wildcard $(patsubst %,$(ARDU_PLAT_LIB_PATH)/%,$(filter-out $(USER_LIB_NAMES),$(ARDUINO_LIBS)))))
PLATFORM_LIB_NAMES    := $(patsubst $(ARDU_PLAT_LIB_PATH)/%,%,$(PLATFORM_LIBS))

LIBS_NOT_FOUND = $(filter-out $(USER_LIB_NAMES) $(SYS_LIB_NAMES) $(PLATFORM_LIB_NAMES),$(ARDUINO_LIBS))
ifneq (,$(strip $(LIBS_NOT_FOUND)))
    $(error The following libraries specified in ARDUINO_LIBS could not be found (searched USER_LIB_PATH, ARDUINO_LIB_PATH and ARDU_PLAT_LIB_PATH): $(LIBS_NOT_FOUND))
endif

SYS_INCLUDES          := $(foreach lib, $(SYS_LIBS),  $(call get_library_includes,$(lib)))
USER_INCLUDES         := $(foreach lib, $(USER_LIBS), $(call get_library_includes,$(lib))) $(foreach lib, $(USER_INCLUDE_PATH), $(call get_library_includes, $(lib)))
LIB_C_SRCS            := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),c))
LIB_CPP_SRCS          := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),cpp))
LIB_AS_SRCS           := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),S))
USER_LIB_CPP_SRCS     := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),cpp))
USER_LIB_C_SRCS       := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),c))
USER_LIB_AS_SRCS      := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),S))
LIB_OBJS               = $(patsubst $(ARDUINO_LIB_PATH)/%.c,$(OBJDIR)/libs/%.c.o,$(LIB_C_SRCS)) \
                         $(patsubst $(ARDUINO_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.cpp.o,$(LIB_CPP_SRCS)) \
                         $(patsubst $(ARDUINO_LIB_PATH)/%.S,$(OBJDIR)/libs/%.S.o,$(LIB_AS_SRCS))
USER_LIB_OBJS          = $(patsubst $(USER_LIB_PATH)/%.cpp,$(OBJDIR)/userlibs/%.cpp.o,$(USER_LIB_CPP_SRCS)) \
                         $(patsubst $(USER_LIB_PATH)/%.c,$(OBJDIR)/userlibs/%.c.o,$(USER_LIB_C_SRCS)) \
                         $(patsubst $(USER_LIB_PATH)/%.S,$(OBJDIR)/userlibs/%.S.o,$(USER_LIB_AS_SRCS))

PLATFORM_INCLUDES     := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_includes,$(lib)))
PLATFORM_LIB_CPP_SRCS := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_files,$(lib),cpp))
PLATFORM_LIB_C_SRCS   := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_files,$(lib),c))
PLATFORM_LIB_AS_SRCS  := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_files,$(lib),S))
PLATFORM_LIB_OBJS     := $(patsubst $(ARDU_PLAT_LIB_PATH)/%.cpp,$(OBJDIR)/platformlibs/%.cpp.o,$(PLATFORM_LIB_CPP_SRCS)) \
                         $(patsubst $(ARDU_PLAT_LIB_PATH)/%.c,$(OBJDIR)/platformlibs/%.c.o,$(PLATFORM_LIB_C_SRCS)) \
                         $(patsubst $(ARDU_PLAT_LIB_PATH)/%.S,$(OBJDIR)/platformlibs/%.S.o,$(PLATFORM_LIB_AS_SRCS))


#############################################
# Build Flags                               #
#############################################

%SoftwareSerial.cpp.o : OPTIMIZATION_FLAGS = -Os
ifeq  "$(DEBUG_FLAG)" "1"
    OPTIMIZATION_FLAGS = -O0 -g -pedantic -Wall -Wextra 
else
    OPTIMIZATION_FLAGS = -Os
endif

COMMON_FLAGS           =  -c -g $(OPTIMIZATION_FLAGS) -Wall -flto -MMD -ffunction-sections -fdata-sections -fdiagnostics-color
CPPFLAGS              += -mmcu=$(MCU) -DF_CPU=$(F_CPU) -DARDUINO=$(ARDUINO_VERSION) $(ARDUINO_ARCH_FLAG) \
                               -D__PROG_TYPES_COMPAT__ -I$(ARDUINO_CORE_PATH) -I$(ARDUINO_VAR_PATH)/$(VARIANT) \
                               $(SYS_INCLUDES) $(PLATFORM_INCLUDES) $(USER_INCLUDES)
CFLAGS                += $(COMMON_FLAGS) -std=gnu11 -fno-fat-lto-objects
CXXFLAGS              += $(COMMON_FLAGS) -std=gnu++11 -fpermissive -fno-threadsafe-statics -fno-exceptions 
ASFLAGS               += -x assembler-with-cpp -flto
LDFLAGS               += -mmcu=$(MCU) -Wl,--gc-sections -O$(OPTIMIZATION_LEVEL) -flto -fuse-linker-plugin
SIZEFLAGS             ?= --mcu=$(MCU) -C

ifeq "$(shell echo $(BOARD_TAG) | tr [:upper:] [:lower:])" "uno"
    CPPFLAGS          += -DARDUINO_AVR_UNO
endif

ifeq "$(ASM_EXPORT)" "1"
    CFLAGS            += -S
    CPPFLAGS          += -S
endif

avr_size               = $(SIZE) $(SIZEFLAGS) --format=avr $(1)

$(info Included Libraries:)
ifneq (,$(strip $(USER_LIB_NAMES)))
    $(foreach lib,$(USER_LIB_NAMES),$(info $(lib) [User Lib]))
endif

ifneq (,$(strip $(SYS_LIB_NAMES)))
    $(foreach lib,$(SYS_LIB_NAMES),$(info $(lib) [System Lib]))
endif

ifneq (,$(strip $(PLATFORM_LIB_NAMES)))
    $(foreach lib,$(PLATFORM_LIB_NAMES),$(info $(lib) [Platform Lib]))
endif


#############################################
# Main Build Targets                        #
#############################################

TARGET_HEX   = $(OBJDIR)/$(TARGET).hex
TARGET_ELF   = $(OBJDIR)/$(TARGET).elf
TARGET_EEP   = $(OBJDIR)/$(TARGET).eep
CORE_LIB     = $(OBJDIR)/libcore.a

#############################################
# Implicit Build Rules                      #
#############################################

# Rather than mess around with VPATH there are quasi-duplicate rules
# here for building e.g. a system C++ file and a local C++
# file. Besides making things simpler now, this would also make it
# easy to change the build options in future

# library sources
$(OBJDIR)/libs/%.c.o: $(ARDUINO_LIB_PATH)/%.c | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/libs/%.cpp.o: $(ARDUINO_LIB_PATH)/%.cpp | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/libs/%.S.o: $(ARDUINO_LIB_PATH)/%.S | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/platformlibs/%.c.o: $(ARDUINO_PLATFORM_LIB_PATH)/%.c | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/platformlibs/%.cpp.o: $(ARDUINO_PLATFORM_LIB_PATH)/%.cpp | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/platformlibs/%.S.o: $(ARDUINO_PLATFORM_LIB_PATH)/%.S | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/userlibs/%.cpp.o: $(USER_LIB_PATH)/%.cpp | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/userlibs/%.c.o: $(USER_LIB_PATH)/%.c | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/userlibs/%.S.o: $(USER_LIB_PATH)/%.S | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

ifdef COMMON_DEPS
    COMMON_DEPS := $(COMMON_DEPS) $(MAKEFILE_LIST)
else
    COMMON_DEPS := $(MAKEFILE_LIST)
endif

# normal local sources
$(OBJDIR)/%.c.o: $(USER_SRC_DIR)/%.c $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.cc.o: $(USER_SRC_DIR)/%.cc $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.cpp.o: $(USER_SRC_DIR)/%.cpp $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@
	###$(CXX) -x c++ -include $(ARDUINO_HEADER) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.S.o: $(USER_SRC_DIR)/%.S $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/%.s.o: $(USER_SRC_DIR)/%.s $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

# core files
$(OBJDIR)/core/%.c.o: $(ARDUINO_CORE_PATH)/%.c $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/core/%.cpp.o: $(ARDUINO_CORE_PATH)/%.cpp $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/core/%.S.o: $(ARDUINO_CORE_PATH)/%.S $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

# various object conversions
$(OBJDIR)/%.hex: $(OBJDIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(OBJCOPY) -O ihex -R .eeprom $< $@
	@$(ECHO) '\n'
	$(call avr_size,$<,$@)
ifneq ($(strip $(HEX_MAXIMUM_SIZE)),)
	@if [ `$(SIZE) $@ | awk 'FNR == 2 {print $$2}'` -le $(HEX_MAXIMUM_SIZE) ]; then touch $@.sizeok; fi
else
	@$(ECHO) "Maximum flash memory of $(BOARD_TAG) is not specified. Make sure the size of $@ is less than $(BOARD_TAG)\'s flash memory"
	@touch $@.sizeok
endif

$(OBJDIR)/%.eep: $(OBJDIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom='alloc,load' \
		--no-change-warnings --change-section-lma .eeprom=0 -O ihex $< $@

$(OBJDIR)/%.lss: $(OBJDIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(OBJDUMP) -h --source --demangle --wide $< > $@

$(OBJDIR)/%.sym: $(OBJDIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(NM) --size-sort --demangle --reverse-sort --line-numbers $< > $@


#############################################
# Explicit Build Targets                    #
#############################################
	
all: $(TARGET_EEP) $(TARGET_HEX)

# Rule to create $(OBJDIR) automatically. All rules with recipes that
# create a file within it, but do not already depend on a file within it
# should depend on this rule. They should use a "order-only
# prerequisite" (e.g., put "| $(OBJDIR)" at the end of the prerequisite
# list) to prevent remaking the target when any file in the directory
# changes.
$(OBJDIR): pre-build
	$(MKDIR) $(OBJDIR)

pre-build:
	$(call runscript_if_exists,$(PRE_BUILD_HOOK))

$(TARGET_ELF): $(LOCAL_OBJS) $(CORE_LIB) $(OTHER_OBJS)
	$(CC) $(LDFLAGS) -o $@ $(LOCAL_OBJS) $(CORE_LIB) $(OTHER_OBJS) $(OTHER_LIBS) -lc -lm $(LINKER_SCRIPTS)

$(CORE_LIB): $(CORE_OBJS) $(LIB_OBJS) $(PLATFORM_LIB_OBJS) $(USER_LIB_OBJS)
	$(AR) rcs $@ $(CORE_OBJS) $(LIB_OBJS) $(PLATFORM_LIB_OBJS) $(USER_LIB_OBJS)

upload:	$(TARGET_HEX)
	$(RESET_CMD)
	$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ARD_OPTS) $(AVRDUDE_UPLOAD_HEX)

eeprom:	$(TARGET_HEX) $(TARGET_EEP) $(TARGET_HEX)
	$(RESET_CMD)
	$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ARD_OPTS) $(AVRDUDE_UPLOAD_EEP)

clean:
	$(REMOVE) $(OBJDIR)
	$(REMOVE) $(PROJECT_DIR)/$(TARGET).elf
	$(REMOVE) $(PROJECT_DIR)/$(TARGET).hex
	$(REMOVE) $(PROJECT_DIR)/$(TARGET).eep

size: $(TARGET_HEX)
	$(call avr_size,$(TARGET_ELF),$(TARGET_HEX))

disasm: $(OBJDIR)/$(TARGET).lss
	@$(ECHO) "The compiled ELF file has been disassembled to $(OBJDIR)/$(TARGET).lss\n\n"

symbol_sizes: $(OBJDIR)/$(TARGET).sym
	@$(ECHO) "A symbol listing sorted by their size have been dumped to $(OBJDIR)/$(TARGET).sym\n\n"

help:
	@$(ECHO) "\nAvailable targets:\n\
  make                   - compile the code\n\
  make upload            - upload\n\
  make eeprom            - upload the eep file\n\
  make clean             - remove all our dependencies\n\
  make depends           - update dependencies\n\
  make size              - show the size of the compiled output (relative to\n\
                           resources, if you have a patched avr-size).\n\
  make symbol_sizes      - generate a .sym file containing symbols and their\n\
                           sizes.\n\
  make disasm            - generate a .lss file that contains disassembly\n\
                           of the compiled file interspersed with your\n\
                           original source code.\n\
  make asm               - output the resulting assembly code for the main\n\
                           user-defined source file, into the OBJDIR directory\n\
        (NOTE: Need to implement 'asm')\n\n"

#############################################
# Targets for Uploading to Board            #
#############################################

AVRDUDE_OPTS        = -q -V

AVRDUDE_MCU         = $(MCU)
AVRDUDE_COM_OPTS    = $(AVRDUDE_OPTS) -p $(MCU) -C $(AVRDUDE_CONF)
AVRDUDE_ARD_OPTS    = -D -c $(AVRDUDE_ARD_PROGRAMMER) -b $(AVRDUDE_ARD_BAUDRATE) -P $(call get_monitor_port)

AVRDUDE_UPLOAD_HEX  = -U flash:w:$(TARGET_HEX):i
AVRDUDE_UPLOAD_EEP  = -U eeprom:w:$(TARGET_EEP):i



.PHONY: all upload reset clean depends size disasm symbol_sizes generate_assembly help pre-build asm

# added - in the beginning, so that we don't get an error if the file is not present
DEPS = $(LOCAL_OBJS:.o=.d) $(LIB_OBJS:.o=.d) $(PLATFORM_OBJS:.o=.d) $(USER_LIB_OBJS:.o=.d) $(CORE_OBJS:.o=.d)
-include $(DEPS)

