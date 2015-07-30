#!/bin/sh

#file name (ommit file extention. program automatically adds .txt)
filename="./logs/test"

# Overwrite file:
# if this flag is sent, any existing file with the same name will be reeplaced with the new one.
# if not, numerated files will be created in order to avoid overwritting the existing ones.
ow=-ow

#baudrate
baudrate="-bd 115200"

# Timeout:
# Reception ends automatically after X seconds without new received information
timeout="-to 30"

# Port:
# /dev/ttyUSB0 = 16
port="-p 16"

# Max file Size (KB)
max="-max 25"

# Fast:
# Avoids some messages and sleep set to 1ms instead of 100ms
fast="-fast"


# Help
# Shows help
h="-h"
help="--helṕ"

#FLAGS: INCLUDE ONLY THE ONES YOU WANT
flags="$baudrate $timeout $port"

#execute:
#echo "sudo ./uart_rx $filename $flags"
sudo ./uart_rx $filename $flags

#clear
#aa="hola tarolas"
#echo $aa
#echo hola
#echo $port $timeout
#echo $flags