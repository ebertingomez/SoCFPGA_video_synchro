# @file  Makefile
# @brief The project source files
# @note  This file can be edited by the user to adapt it to its project

export SYN_DIR = $(shell pwd)

# source files directory
SRC_DIR = $(SYN_DIR)/../wb_bram

# source files for synthesis
# add the path to source files ex:MCE.sv 
# separated with spaces	
SOURCE_FILES =  wshb_if.sv wb_bram.sv

VPATH = $(SYN_DIR)/../../wshb_if

# Top module for synthesis
# add the top modle for synthesis ex:MCE
export TOP_MODULE  = wb_bram

export FILES = $(patsubst %,$(SRC_DIR)/%,$(SOURCE_FILES))

# End of SOURCE_FILES
.PHONY : all clean

all:
ifeq ($(TOP_MODULE),xxxx)
	@echo "You have to define the TOP MODULE !!!"
else 
ifeq ($(SOURCE_FILES),xxxx.sv)
	@echo "You have to define the SOURCE FILES !!!"
else
	@echo "==> TOP LEVEL MODULE  : $(TOP_MODULE)"
	@echo "==> FILES : $(SOURCE_FILES)"
	precision -file synthesis.tcl
endif
endif

clean:
	@rm -rf $(TOP_MODULE)
	@rm -rf $(PART_MODULE)
	@rm -fr *.log *.psp impl*
	@rm -fr *_temp_*
