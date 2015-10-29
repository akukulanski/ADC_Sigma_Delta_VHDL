
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

	/// Variables for serial port config
	sUartConfig uartConfig;
	uartConfig.cport_nr=ttyUSB0;	//Caso CONVERSOR UART-USB en /dev/ttyUSB0
	uartConfig.bdrate=921600;		//Default: 9600 baud
	uartConfig.mode[0]='8';
	uartConfig.mode[1]='N'; 
	uartConfig.mode[2]='1'; 
	uartConfig.mode[3]=0;
	
	//general config
	sGeneralConfig generalConfig;
	generalConfig.timeout=0;
	generalConfig.syncSamples=1000; //number of samples to use for autoSync
	generalConfig.numSamples=10000;
	generalConfig.fileName=string("");
	generalConfig.fileNameLog=string(LOG_FILENAME);
	generalConfig.pipeName=string(PIPE_NAME);
	
	if(getParam(argc,argv,generalConfig,uartConfig)) return 1;

	sFiles Files;

	if(generalConfig.fileName==string(""))
		generalConfig.fileName = string("./") + getTimeStr() + string(BIN_EXT);
	showConfig(generalConfig, uartConfig);
	
	// Opening Serial Port
	if(RS232_OpenComport(uartConfig.cport_nr, uartConfig.bdrate, uartConfig.mode)){
		cout << "Can not open serial port. Don't worry! Data files will be saved anyway." << endl;
	}else{
		cout << "Connected to Serial Port!" << endl << endl;
	}

	openFiles(generalConfig, Files, uartConfig);
	
	cout << endl << "*** RECEPTION STARTED ***" << endl << endl;
	int cant=receiveUart(generalConfig, uartConfig, Files);
	cout << endl << endl << "*** RECEPTION FINISHED ***" << endl << endl;

	Files.fBin.close();
	
	if(!cant){
		cout << "Empty file (0 bytes) --> Deleting..." << endl;
		remove (generalConfig.fileName.c_str());
	}else{
		cout << "Total received: " << cant << " bytes (" << cant/KB << " KB)" << endl;
		cout << "Binary Saved to: " << generalConfig.fileName << endl;
		cout << "Acquisition info added to: " << generalConfig.fileNameLog << endl;
	}

  return 0;
}