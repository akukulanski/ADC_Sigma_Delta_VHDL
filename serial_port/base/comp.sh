rm uart_rx
g++ demo_rx.c rs232.c -Wall -Wextra -o2 -o uart_rx
g++ demo_tx.c rs232.c -Wall -Wextra -o2 -o uart_tx