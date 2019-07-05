#
# Copyright 2019 AbbeyCatUK
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

#.SILENT:

# common
BIN2C				= ./bin2c

# 32-bit toolchain
GCC_PATH_32			= ~/Downloads/Software/ARM/32-bit/gcc-arm-8.2-2019.01-x86_64-arm-eabi
GCC_32      			= $(GCC_PATH_32)/bin/arm-eabi-gcc
AS_32       			= $(GCC_PATH_32)/arm-eabi/bin/as
AR_32       			= $(GCC_PATH_32)/arm-eabi/bin/ar
LD_32       			= $(GCC_PATH_32)/arm-eabi/bin/ld
OBJDUMP_32  			= $(GCC_PATH_32)/arm-eabi/bin/objdump
OBJCOPY_32  			= $(GCC_PATH_32)/arm-eabi/bin/objcopy

# 64-bit toolchain
GCC_PATH_64			= ~/Downloads/Software/ARM/64-bit/gcc-arm-8.2-2019.01-x86_64-aarch64-elf
GCC_64      			= $(GCC_PATH_64)/bin/aarch64-elf-gcc
AS_64       			= $(GCC_PATH_64)/aarch64-elf/bin/as
AR_64       			= $(GCC_PATH_64)/aarch64-elf/bin/ar
LD_64       			= $(GCC_PATH_64)/aarch64-elf/bin/ld
OBJDUMP_64  			= $(GCC_PATH_64)/aarch64-elf/bin/objdump
OBJCOPY_64  			= $(GCC_PATH_64)/aarch64-elf/bin/objcopy

# 32/64 bit flags for Assembler/Compiler
FLAGS_OBJDUMP_64		= -maarch64
FLAGS_C_64  			= 

FLAGS_OBJDUMP_32		= -marm
FLAGS_C_32  			= -march=armv7-a

# -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

# all
all : armstub.bin armstub7.bin armstub8-32.bin armstub8.bin

# -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  

# clean
clean:
	rm -f *.o *.out *.tmp *.bin *.ds *.C armstubs.h bin2c *~

# -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  


# assembler files
%8.o: %8.S
	$(GCC_64) $(FLAGS_C_64) -c $< -o $@

%8-32.o: %7.S
	$(GCC_32) $(FLAGS_C_32) -DBCM2710=1 -c $< -o $@

%.o: %.S
	$(GCC_32) $(FLAGS_C_32) -DBCM2710=0 -c $< -o $@

# object files
%8.elf: %8.o
	$(LD_64) --section-start=.text=0 $< -o $@

%.elf: %.o
	$(LD_32) --section-start=.init=0 $< -o $@

# ELF files
%8.tmp: %8.elf
	$(OBJCOPY_64) $< -O binary $@

%.tmp: %.elf
	$(OBJCOPY_32) $< -O binary $@

# tmp files
%.bin: %.tmp
	dd if=$< ibs=256 count=1 of=$@ conv=sync

# bin files
%8.ds: %8.bin
	$(OBJDUMP_64) $(FLAGS_OBJDUMP_64) -D --target binary $< > $@

%.ds: %.bin
	$(OBJDUMP_32) $(FLAGS_OBJDUMP_64) -D --target binary $< > $@

%.C: %.bin bin2c
	$(BIN2C) $< > $@

$(BIN2C): bin2c.c
	gcc $< -o $@

armstubs.h: armstub.C armstub7.C armstub8-32.C armstub8.C
	echo 'static const unsigned armstub[] = {' > $@
	cat armstub.C >> $@
	echo '};' >> $@
	echo 'static const unsigned armstub7[] = {' >> $@
	cat armstub7.C >> $@
	echo '};' >> $@
	echo 'static const unsigned armstub8_32[] = {' >> $@
	cat armstub8-32.C >> $@
	echo '};' >> $@
	echo 'static const unsigned armstub8[] = {' >> $@
	cat armstub8.C >> $@
	echo '};' >> $@

