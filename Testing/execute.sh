#!/bin/sh

#file name (ommit file extention. program automatically adds .txt)
#filename="./logs/test"

# Pipe Name
#pipename="-pipename /tmp/pipeUartAdc"

# Port:
# /dev/ttyUSB0 = 16
port="-p 16"

#baudrate
#baudrate="-bd 115200"
baudrate="-bd 921600"

# Number of samples
numsamples="-numsamples 10000"

# Timeout:
# Reception ends automatically after X seconds without new received information
timeout="-to 30"

# Help
# Shows help
h="-h"
help="--helṕ"

#FLAGS: INCLUDE ONLY THE ONES YOU WANT
flags="$filename $pipename $port $baudrate $numsamples $timeout"

#execute:
#echo "sudo ./uart_rx $filename $flags"
sudo ./uart_rx $flags
#sudo ./uart_rx -numsamples 50 -to 30 -p 16 -bd 921600

#clear
#aa="hola tarolas"
#echo $aa
#echo hola
#echo $port $timeout
#echo $flags
