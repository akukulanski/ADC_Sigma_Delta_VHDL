#!/bin/sh

#file name (ommit file extention. program automatically adds .txt)
name="./logs/test"

# Overwrite file:
# if this flag is sent, any existing file with the same name will be reeplaced with the new one.
# if not, numerated files will be created in order to avoid overwritting the existing ones.
ow=-ow

#baudrate
#baudrate="-bd 115200"
baudrate="-bd 921600"

# Timeout:
# Reception ends automatically after X seconds without new received information
timeout="-to 30"

# Port:
# /dev/ttyUSB0 = 16
port="-p 16"

# Max file Size (KB)
#max="-max 25"
max="-max 10000"

# Autoplot (comment to disable)
autoplot="-autoplot"

# Not configure (comment to disable)
noconf="-noconf"

# AutoSync
syncsamples="-syncsamples 10"

# Pipe Name
pipename="-pipename /tmp/pipeUartAdc"

# Help
# Shows help
h="-h"
help="--helṕ"

#FLAGS: INCLUDE ONLY THE ONES YOU WANT
flags="$name $baudrate $timeout $port $autoplot $noconf $syncsamples $pipename"

#execute:
#echo "sudo ./uart_rx $filename $flags"
sudo ./uart_rx $flags

#clear
#aa="hola tarolas"
#echo $aa
#echo hola
#echo $port $timeout
#echo $flags