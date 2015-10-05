#!/bin/sh

#file name (ommit file extention. program automatically adds .txt)
name="./logs/test"

# Pipe Name
pipename="-pipename /tmp/pipeUartAdc"

# Port:
# /dev/ttyUSB0 = 16
port="-p 16"

#baudrate
#baudrate="-bd 115200"
baudrate="-bd 921600"

# Max file Size (KB)
#max="-max 25"
max="-max 10"

# Timeout:
# Reception ends automatically after X seconds without new received information
timeout="-to 30"

# AutoSync
syncsamples="-syncsamples 100"

# Autoplot (comment to disable)
autoplot="-autoplot"

# Help
# Shows help
h="-h"
help="--helṕ"

#FLAGS: INCLUDE ONLY THE ONES YOU WANT
flags="$name $pipename $port $baudrate $max $timeout $syncsamples $autoplot"

#execute:
#echo "sudo ./uart_rx $filename $flags"
sudo ./uart_rx $flags

#clear
#aa="hola tarolas"
#echo $aa
#echo hola
#echo $port $timeout
#echo $flags