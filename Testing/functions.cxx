
#include <math.h>
// Serial Port
#include "rs232.h"
#include "uart_rx.h"
#include "functions.h"

using namespace std;

/**	@brief get a number of bytes from uart (blocking) with timeout
 * 	@param bytes number of bytes
 * 	@param timeout tries before return. -1 for inf
 */
int getUartDummies(int cport_nr, int bytes, int timeout){
	if(!bytes) return 0;
	int n=0,total=0;
	unsigned char dummy[bytes];
	while(total<bytes){
		n=RS232_PollComport(cport_nr, dummy, bytes-total);
		if(n>0) total+=n;
		if(total<bytes) usleep(100);
		if(!--timeout) return 0x01;
	};
	if(total!=bytes) return 0x02;
	return 0;
}


/** @brief get command line parameters
 */
int getParam(int argc, char **argv, sGeneralConfig & generalConfig, sUartConfig & uartConfig){
	int numarg=1;
	do{
		string param(argv[numarg]);
		if(param==string("-h") || param==string("--help")){	// show help
			cout << MODO_USO << endl;
			cout << "\tNo\tDevice" << endl;
			for(int i=0;i<16;i++) cout << "\t" << i << "\t" << "ttyS" << i << endl;
			for(int i=0;i<6;i++) cout << "\t" << i+16 << "\t" << "ttyS" << i << endl;
		}else if(param==string("-to")){	// timeout <value in seconds>
			generalConfig.timeout = atoi(argv[++numarg]);
		}else if(param==string("-numsamples")){ // max file size in KB
			generalConfig.numSamples = atoi(argv[++numarg]);
		}else if(param==string("-filename")){
			generalConfig.fileName = argv[++numarg];
		}else if(param==string("-pipename")){
			generalConfig.pipeName = argv[++numarg];
		}else if(param==string("-p")){	// uart port <number> (see header for number references)
			uartConfig.cport_nr = atoi(argv[++numarg]);
		}else if(param==string("-bd")){	// baudrate
			uartConfig.bdrate = atoi(argv[++numarg]);
		}else{
			cout << "Unknown parameter: \'" << param << "\'" << endl;
			cout << MODO_USO << endl;	
			return 1;
		}
		numarg++;
	}while(numarg<argc);
	return 0;
}

int showConfig(sGeneralConfig generalConfig, sUartConfig uartConfig){
	cout << "*** GENERAL CONFIG ***" << endl;
	cout << endl << "File Name: " << generalConfig.fileName << endl;
	cout << "Number of samples: " << generalConfig.numSamples<< endl;
	cout << "Timeout: " << generalConfig.timeout << " seconds" << endl;

	cout << "*** SERIAL RECEIVER CONFIG ***" << endl;
	cout << "port: \t\t" << uartConfig.cport_nr << endl;
	cout << "baudrate:\t" << uartConfig.bdrate << endl;
	cout << "mode: \t" << string(uartConfig.mode) << endl;
	return 0;
}

/// ****************************
/// *** Files functions ********

int openFiles(sGeneralConfig generalConfig, sFiles & Files, sUartConfig uartConfig){
	//Files.fBin.open(generalConfig.fileName.c_str(), ios::binary);
	Files.fBin.open(generalConfig.fileName.c_str(), ios::out);
	if (!(Files.fBin.is_open())){
		cout << "Error al abrir archivo " << generalConfig.fileName << "." << endl;
		exit(1);
	}
	
	Files.fLog.open(generalConfig.fileNameLog.c_str(), ios::app);
	if(!Files.fLog.is_open()){
		cout << "Error al abrir archivo " << generalConfig.fileNameLog << "." <<endl;
		return 1;
	}

	if(Files.fLog.is_open()){
		Files.fLog << endl;
		Files.fLog << "*** NEW ACQUISITION ***" << endl;
		Files.fLog << "filename=" << generalConfig.fileName << endl;
		Files.fLog << "timeout=" << generalConfig.timeout << endl;
		Files.fLog << "samples=" << generalConfig.numSamples << endl;
		Files.fLog << "port=" << uartConfig.cport_nr << endl;
		Files.fLog << "baudrate=" << uartConfig.bdrate << endl;
		Files.fLog << "mode=" << uartConfig.mode << endl;
		Files.fLog << "*** END ***" << endl;
		Files.fLog.close();
	}
	return 0;
}


/// ***************************
/// *** Time functions ********
string getTimeStr(){
	char ss[20];
	std::time_t myTime; time(&myTime);
	strftime(ss, 20, "%Y%m%d_%H%M%S",localtime(&myTime));//timeinfo);
	return string(ss);
}

/// ************************************
/// *** Communication functions ********

int receiveUart(sGeneralConfig generalConfig, sUartConfig uartConfig, sFiles & Files){
	enum nState{LOW=0, HIGH=1};
	int state=HIGH;
	unsigned char last=0x00;
	int cant=0;

	cout << "Clearing buffer!" << endl;
	const unsigned char START_BYTE='s';
	const unsigned char PAUSE_BYTE='p';
	// Forcing uart to stop
	RS232_SendByte(uartConfig.cport_nr, PAUSE_BYTE);
	sleep(1);
	//clear BUFFER!!
	int n=1;
	while(n>0){
		unsigned char dummy[4096];
		n = RS232_PollComport(uartConfig.cport_nr, dummy, 4095);
	}
	// sending Start byte
	RS232_SendByte(uartConfig.cport_nr, START_BYTE);
	
	while(cant < 2*generalConfig.numSamples){ //máximo tamaño archivo de datos
		unsigned char buf[4096];
		int n = RS232_PollComport(uartConfig.cport_nr, buf, 4095);
		if(n > 0){ //recibió byte(s)
			cant+=n;
			// Conversión 2bytes -> 1short
			for(int i=0;i<n;i++){
				if(state==LOW){
					//signed short int myValue=0x0000;
					//myValue = 0x00FF & buf[i];
					//myValue |= 0xFF00 & (((unsigned short)last)<<8);
					//myData.push_back(myValue);
					//Files.fBin.write((char *)&myValue, 2);
					Files.fBin.write((char *)&buf[i], 1);
					Files.fBin.write((char *)&last, 1);
					state=HIGH;
				}else{
					last = buf[i];
					state=LOW;
				}
			}
		  cout << endl;
		}
	}
    RS232_SendByte(uartConfig.cport_nr, PAUSE_BYTE);
	return cant;
}
