
/**************************************************

file: demo_tx.c
purpose: simple demo that transmits characters to
the serial port and print them on the screen,
exit the program by pressing Ctrl-C

compile with the command: gcc demo_tx.c rs232.c -Wall -Wextra -o2 -o test_tx

**************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <iostream>

#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif

#include "rs232.h"
#include "math.h"
#include "demo_rx.h"

int clrbuf(int fd=0);
int keyPressed(int fd=0);

const double pi=3.14159265358979;
using namespace std;

int main()
{
  int cport_nr=0,        /* /dev/ttyS0 (COM1 on windows) */
      bdrate=921600;//9600;       /* 9600 baud */
  char mode[]={'8','N','1',0};

	// Agregado para CONVERSOR UART-USB en /dev/ttyUSB0
	cport_nr=16;	/* /dev/ttyUSB0  --> 16*/

  if(RS232_OpenComport(cport_nr, bdrate, mode)){
    printf("Can not open comport\n");
    return(0);
  }

  long long cant=0;
  /*
  int i=0; int T=100;
	while(1){
		signed short val=1000*sin(2.0*pi*i/T);
		unsigned char buf[2];//char buf[3];
		buf[1] = val&0x00FF;
		buf[0] = (val>>8)&0x00FF;
		RS232_write(cport_nr, buf, 2);	//RS232_cputs(cport_nr, buf);
		i++; i%=T; cant ++;
		if(keyPressed()){
			clrbuf(0);
			break;
		}
	};*/
	for(int i=0;i<50000;i++){
		signed short val=1000*sin(2.0*pi*i/100);
		unsigned char buf[2];//char buf[3];
		buf[1] = val&0x00FF;
		buf[0] = (val>>8)&0x00FF;
		RS232_write(cport_nr, buf, 2);
		cout << val << "\t" << buf << ";" << cport_nr << endl;
		cant++;
		usleep(100);
	}
	cout << "Sent: " << 2*cant << " bytes" << endl;
  return(0);
}


int clrbuf(int fd){
	fd_set ptrRead;
	struct timeval tt;
	FD_ZERO(&ptrRead);
	FD_SET(fd, &ptrRead);
	tt.tv_sec=0;
	tt.tv_usec=0;
	select(fd+1, &ptrRead, NULL,NULL, &tt);
	while(FD_ISSET(fd,&ptrRead)){
		char abc[50];
		read(0,abc,49);
		FD_ZERO(&ptrRead);
		FD_SET(0, &ptrRead);
		tt.tv_sec=0;
		tt.tv_usec=0;
		select(fd+1, &ptrRead, NULL,NULL, &tt);
		//if(FD_ISSET(0,&ptrRead)){ cin >> dummy;	}
	}
	return 0;
}

int keyPressed(int fd){
	fd_set ptrRead;
	struct timeval tt;
	FD_ZERO(&ptrRead);
	FD_SET(fd, &ptrRead);
	tt.tv_sec=0;
	tt.tv_usec=0;
	select(fd+1, &ptrRead, NULL,NULL, &tt);
	return (FD_ISSET(fd,&ptrRead));
}