
/**************************************************

file: demo_rx.c
purpose: simple demo that receives characters from
the serial port and print them on the screen,
exit the program by pressing Ctrl-C

compile with the command: gcc demo_rx.c rs232.c -Wall -Wextra -o2 -o test_rx

**************************************************/

// Standard
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <sys/select.h>

#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif

// Serial Port
#include "rs232.h"
#include "uart_rx.h"

#include "functions.h"

using namespace std;


// vector::data
#include <iostream>
#include <vector>
	
int main(int argc, char* argv[]){
/*
  std::vector<int> myvector (5);
  int* p = myvector.data();
  *p = 10;
	++p;
  *p = 20;
  p[2] = 100;
  std::cout << "myvector contains:";
  for (unsigned i=0; i<myvector.size(); ++i)
    std::cout << ' ' << myvector[i];
  std::cout << '\n';
  return 0;
*/
	/*
	short a=1000;
	char * c=(char *)&a;
	printf("a=%x\tc[0]=%x\tc[1]=%x\n", a, c[0]&0xFF, c[1]&0xFF);
	char b[2];
	b[0] = a&0x00FF;
	b[1] = (a>>8)&0x00FF;
	printf("b=%d\tb[0]=%x\tb[1]=%x\n", *(short *)b, b[0]&0xFF, b[1]&0xFF);
	//llegan al revés!
	char High=(a>>8)&0xFF, Low=a&0xFF;
	printf("\tHIGH=%x\tLOW=%x\n", High&0xFF, Low&0xFF);
	return 0;*/
	
	
	int flagErr=0x00000000;
	/// Variables for serial port config
	sUartConfig uartConfig;
	uartConfig.cport_nr=ttyUSB0;	//Caso CONVERSOR UART-USB en /dev/ttyUSB0
	uartConfig.bdrate=9600;		//Default: 9600 baud
	//uartConfig.mode[]={'8','N','1',0};
	uartConfig.mode[0]='8';
	uartConfig.mode[1]='N'; 
	uartConfig.mode[2]='1'; 
	uartConfig.mode[3]=0;
	
	//general config
	sGeneralConfig generalConfig;
	generalConfig.timeout=0;
	generalConfig.syncSamples=1000; //number of samples to use for autoSync
	generalConfig.flagErr=0;
	generalConfig.maxSize=KB;
	generalConfig.name=string(NAME);
	generalConfig.fileNameLog=string(LOG_FILENAME);
	generalConfig.pipeName=string(PIPE_NAME);
	generalConfig.ow=false;	//overwrite files
	generalConfig.bin=false; //binary output
	generalConfig.autoPlot=false; //real time (read-plot-read-plot...) (unused so far)
	generalConfig.configure=true;
	if(getParam(argc,argv,generalConfig,uartConfig)) return 1;

	//files (txt,bin,log), pipes
	sFiles Files;
	
	char buffer[200]; char cc;
	
	// Creating Pipe
	createPipe(generalConfig);
	
	clrbuf();
	//main loop
	do{
		showConfig(generalConfig);
		cout << "Press m to go to config menu.\nPress q to exit.\nPress any other key to to start new acquisition." << endl;
		readUntil(buffer,'\n',200);
		cc=buffer[0];
		if(cc=='m') generalConfig.configure=true; else generalConfig.configure = false;
		if(cc=='q') break;
		
		showMenu(generalConfig);
		flagErr |= openFiles(generalConfig, Files);

		// Opening Serial Port
		if(RS232_OpenComport(uartConfig.cport_nr, uartConfig.bdrate, uartConfig.mode)){
			cout << "Can not open port" << endl;
			flagErr |= 0x08;
		}
		cout << "Connected to Serial Port!" << endl << endl;
		showUartConfig(uartConfig);
		cout << "Press any key to start" << endl;
		
		//waitForAnyKey();
		readUntil(buffer,'\n',200);
		cout << "Sincronization..." << endl;
		
		//Catch-Sequence: (Siempre FIRST-HIGH. Se busca ver si llegó 1H,1L,2H,2L,... o 1L,2H,2L,3H,...)
		if(generalConfig.syncSamples){
			int ret=sync(uartConfig.cport_nr, generalConfig.syncSamples, 15);
			cout << "sync=" << ret << endl;
			if(ret < 0){
				cout << "Unable to syncronize." << endl;
				flagErr |= 0x10;
			}else if(ret){
				getUartDummies(uartConfig.cport_nr, 1, generalConfig.timeout);
			}
		}
		//si no quedó sincronizado, se deberá editar después el archivo. (opcional levantarlo corregido)

		writeLog(Files.fLog, generalConfig, uartConfig);
		Files.fLog.close();

		cout << endl << "*** RECEPTION STARTED ***" << endl << endl;
		std::vector<short> myData (generalConfig.maxSize*KB/2);
		int cant=receiveUart(generalConfig, uartConfig, Files, myData);
		cout << endl << endl << "*** RECEPTION FINISHED ***" << endl << endl;

		Files.fTxt.close();
		Files.fBin.close();
		
		if(!cant){
			cout << "Empty file (0 bytes) --> Deleting..." << endl;
			remove(generalConfig.fileNameTxt.c_str());
			if(generalConfig.bin) remove (generalConfig.fileNameBin.c_str());
			flagErr |= 0x80;
		}else{
			cout << "Total received: " << cant << " bytes (" << cant/KB << " KB)" << endl;
			cout << "Txt Saved to: " << generalConfig.fileNameTxt << endl;
			cout << "Binary Saved to: " << generalConfig.fileNameBin << endl;
			cout << "Acquisition info added to: " << generalConfig.fileNameLog << endl;
		}
		if(generalConfig.autoPlot){
			send2Matlab(myData, generalConfig);
		}
	}while(1);
	
  return 0;
}


/*
txtFile.open ("example.bin", ios::out | ios::app | ios::binary); 
ios::in	Open for input operations.
ios::out	Open for output operations.
ios::binary	Open in binary mode.
ios::ate	Set the initial position at the end of the file.
If this flag is not set, the initial position is the beginning of the file.
ios::app	All output operations are performed at the end of the file, appending the content to the current content of the file.
ios::trunc	If the file is opened for output operations and it already existed, its previous content is deleted and replaced by the new one.

*/
