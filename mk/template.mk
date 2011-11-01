## This is designed as a starting point for creating new makefiles.

 # This is a GNU makefile.

# set the argument of the cd command appropriately
ifndef PML_HOME
  export PML_HOME=$(shell cd ..; pwd)
endif

SRC=../src
BUILD=lib

CURDIR := $(shell pwd)

ifneq ($(BUILD),$(notdir $(CURDIR)))
  include $(PML_HOME)/mk/redirect.mk
else

 # The following rules are run from the build directory

.PHONY: all clean

all: 

include $(PML_HOME)/mk/common.mk

clean:
	rm -f *.cm[iox]	

ifeq (.depend,$(strip $(shell ls .depend)))
  include .depend
endif

# End of rules that are run from the build directory
endif
