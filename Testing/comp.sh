clear
rm uart_rx
echo ""
files="uart_rx.c rs232.c functions.cxx"
g++ $files -Wall -Wextra -o2 -o uart_rx
#g++ uart_rx.c rs232.c functions.cxx -Wall -o uart_rx
echo ""
echo ""
