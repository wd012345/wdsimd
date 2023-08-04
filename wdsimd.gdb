## definition file for gdb - The GNU Debugger

## define executable
file /home/datatools/Projects/wdsimd/wdavx256/wdavx256-test-library
set disassembly-flavor intel

## set breakpoints for debugging 32 bit functions
## remove hashtags to activate breakpoint, then run command 'make debug'
break source/iavx.d:670

## run debug
run
