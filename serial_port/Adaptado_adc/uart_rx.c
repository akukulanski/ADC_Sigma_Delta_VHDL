
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
	
	int flagErr=0;

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
	generalConfig.maxSize=KB;
	generalConfig.name=string(NAME);
	generalConfig.fileNameLog=string(LOG_FILENAME);
	generalConfig.pipeName=string(PIPE_NAME);
	generalConfig.autoPlot=true; //real time (read-plot-read-plot...) (unused so far)
	if(getParam(argc,argv,generalConfig,uartConfig)) return 1;

	//files (txt,bin,log), pipes
	sFiles Files;
	
	showConfig(generalConfig, uartConfig);

	// Creating Pipe
	if(createPipe(generalConfig)){
		cout << "Pipe not created. Don't worry! Data files will be saved anyway." << endl;
	}
	
	// Opening Serial Port
	if(RS232_OpenComport(uartConfig.cport_nr, uartConfig.bdrate, uartConfig.mode)){
		cout << "Can not open serial port. Don't worry! Data files will be saved anyway." << endl;
	}else{
		cout << "Connected to Serial Port!" << endl << endl;
	}
	
	do{
		std::vector<short> myData (generalConfig.maxSize*KB/2);
		
		flagErr |= openFiles(generalConfig, Files, uartConfig);
		
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
		
		cout << endl << "*** RECEPTION STARTED ***" << endl << endl;
		int cant=receiveUart(generalConfig, uartConfig, Files, myData);
		cout << endl << endl << "*** RECEPTION FINISHED ***" << endl << endl;

		Files.fTxt.close();
		Files.fBin.close();
		
		if(!cant){
			cout << "Empty file (0 bytes) --> Deleting..." << endl;
			remove(generalConfig.fileNameTxt.c_str());
			remove (generalConfig.fileNameBin.c_str());
			flagErr |= 0x80;
		}else{
			cout << "Total received: " << cant << " bytes (" << cant/KB << " KB)" << endl;
			cout << "Txt Saved to: " << generalConfig.fileNameTxt << endl;
			cout << "Binary Saved to: " << generalConfig.fileNameBin << endl;
			cout << "Acquisition info added to: " << generalConfig.fileNameLog << endl;
		}
		if(generalConfig.autoPlot) send2Matlab(myData, generalConfig, uartConfig.cport_nr);
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
