
/**************************************************

file: demo_rx.c
purpose: simple demo that receives characters from
the serial port and print them on the screen,
exit the program by pressing Ctrl-C

compile with the command: gcc demo_rx.c rs232.c -Wall -Wextra -o2 -o test_rx

**************************************************/

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

#include <stdlib.h>
#include <stdio.h>

#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif

#include "rs232.h"
#include "demo_rx.h"

#include <sys/time.h>
#include <sys/select.h>

#define MODO_USO "Modo de uso: ./uart_rx file_name [-ow] [-bd <baudrate>] [-to <timeout>] [-p <port>] [-max <max_file_size_KB>] [-fast]"
#define HELP_COMMANDS ""

using namespace std;

int clrbuf(int fd);
int keyPressed();

int main(int argc, char* argv[]){
	int cport_nr=0,bdrate=9600,maxSize=1024;
	unsigned char buf[4096];
	char mode[]={'8','N','1',0};

	int n=0,cant=0,sleepCounter=0,timeout=0;
	unsigned char c=0;
	stringstream fileName;
	bool ow=false, fast=false;
	string dummy;
	int numarg=2;
		
	//Default: 9600 baud, /dev/ttyS0 (0) or COM1
	//Caso CONVERSOR UART-USB en /dev/ttyUSB0
	cport_nr = ttyUSB0;	/* /dev/ttyUSB0  --> 16*/
	fstream outputFile,fileDummy;
	//fstream outputFile, fileDummy;

	if(argc<2){
		cout << "Error. " << MODO_USO << endl;
		return 0;
	}

	ow=false;
	numarg=2;
	do{
		string param(argv[numarg]);
		if(param==string("-h") || param==string("--help")){
			cout << "Modo de uso: ./uart_rx file_name [-ow] [-bd <baudrate>] [-to <timeout_sec>] [-p <port_number>]" << endl;
			cout << "\tNo\tDevice" << endl;
			for(int i=0;i<16;i++) cout << "\t" << i << "\t" << "ttyS" << i << endl;
			for(int i=0;i<6;i++) cout << "\t" << i+16 << "\t" << "ttyS" << i << endl;
		}else if(param==string("-ow")){
			ow=true;
		}else if(param==string("-bd")){
			bdrate = atoi(argv[++numarg]);
		}else if(param==string("-to")){
			timeout = atoi(argv[++numarg]);
		}else if(param==string("-p")){
			cport_nr = atoi(argv[++numarg]);
		}else if(param==string("-max")){
			maxSize = atoi(argv[++numarg]);
		}else if(param==string("-fast")){
			fast=true;
		}else{
			cout << "Unknown parameter: \'" << param << "\'" << endl;
			cout << MODO_USO << endl;	
			return 1;
		}
		numarg++;
	}while(numarg<argc);
	
	fileName << argv[1] << ".dat";
	if(!ow){
		c=0;
		fileDummy.open(fileName.str().c_str(), ios::in);
		while(++c && fileDummy.is_open()){ //existe y no hubo no overflow (256 máx)
			fileDummy.close();
			fileName.str("");
			fileName << argv[1] << (c-1) << ".dat";
			fileDummy.open(fileName.str().c_str(), ios::in);
		}
		if(!c){
			cout << "Máximo 256 archivos con el mismo nombre. Usar otro." << endl;
			return 1;
		}
	}
	
	outputFile.open(fileName.str().c_str(), ios::out);
	if (!(outputFile.is_open())){
		cout << "Error al abrir archivo " << fileName.str() << "." <<endl; return(1); }
	
	if(RS232_OpenComport(cport_nr, bdrate, mode)){
		cout << "Can not open comport" << endl; return(1); }

	cout << "Connected to Serial Port!" << endl << endl;
	cout << "*** SERIAL RECEIVER CONFIG ***" << endl;
	cout << "file: \t\t" << fileName.str() << endl;
	cout << "port: \t\t" << cport_nr << endl;
	cout << "baudrate:\t" << bdrate << endl;
	cout << "timeout: \t" << timeout << endl;

	if(!fast){
		cout << "Press any key to start" << endl;
		char abc[2];
		read(0,abc,1); //cin >> dummy;
		clrbuf(0);
	}
	cout << endl << "*** RECEPTION STARTED ***" << endl;
	outputFile << "*** SERIAL RECEIVER CONFIG ***" << endl;
	outputFile << "file: \t\t" << fileName.str() << endl;
	outputFile << "port: \t\t" << cport_nr << endl;
	outputFile << "baudrate:\t" << bdrate << endl;
	outputFile << "timeout: \t" << timeout << endl;
	outputFile << "*** DATA ***" << endl;



	if(!fast){
		while(cant < 1024*maxSize){ //máximo tamaño archivo de datos
			n = RS232_PollComport(cport_nr, buf, 4095);
			cant+=n;
			//cout << "n=" << n << endl << "cant=" << cant << endl;
			if(n > 0){
				buf[n] = '\0';   //always put a "null" at the end of a string!
				system("clear");
				//cout << "Timeout in --- seconds..." << endl;
				cout << endl;
				cout << "Total received so far: " << cant << "bytes (" << cant/1024 << " KB)" << endl;
				cout << "Last reception: " << n << " new bytes:" << endl << "\"\t" << buf << "\"" << endl;
				sleepCounter = 0;
				outputFile.write ((char *)buf, n);
			}else{
				if(timeout && sleepCounter >= timeout*10) break; // sale si no recibió nada durante 5segs
				if(! (sleepCounter % 10)){
					system("clear");
					cout << "Timeout in " << timeout-sleepCounter/10 << " seconds..." << endl;
					cout << "Total received so far: " << cant << "bytes (" << cant/1024 << " KB)" << endl;
					cout << "Last reception: " << n << " new bytes:" << endl << "\t" << buf << endl;
				}
				sleepCounter++;
				#ifdef _WIN32
						Sleep(100);
				#else
						usleep(100000);  // sleep for 100 milliSeconds
				#endif
			}
			if(keyPressed()){clrbuf(0); break;}
		}
	}else{ //FAST!!
		while(cant < 1024*maxSize){
			n = RS232_PollComport(cport_nr, buf, 4095);
			cant+=n;
			outputFile.write ((char *)buf, n);
			if(!n){
				sleepCounter++;
				if(timeout && sleepCounter >= timeout*1000) break; // sale si no recibió nada durante 5segs
				if(! (sleepCounter % 1000)) cout << "Timeout in " << timeout-sleepCounter/1000 << " seconds..." << endl;
				#ifdef _WIN32
						Sleep(1);
				#else
						usleep(1000);  // sleep for 1 milliSeconds
				#endif	
			}
			else
				sleepCounter=0;
			if(keyPressed()){clrbuf(0); break;}
		}
	}
	
	outputFile.close();
	cout << "*** RECEPTION FINISHED ***" << endl << endl;
	if(!cant){
		cout << "Empty file (0 bytes) --> Deleting..." << endl;
		remove(fileName.str().c_str());
		return 0;
	}
	cout << "Total received: " << cant << " bytes (" << cant/1024 << " KB)" << endl;
	cout << "Saved to: " << fileName.str() << endl;
	
  return 0;
}


/*
outputFile.open ("example.bin", ios::out | ios::app | ios::binary); 
ios::in	Open for input operations.
ios::out	Open for output operations.
ios::binary	Open in binary mode.
ios::ate	Set the initial position at the end of the file.
If this flag is not set, the initial position is the beginning of the file.
ios::app	All output operations are performed at the end of the file, appending the content to the current content of the file.
ios::trunc	If the file is opened for output operations and it already existed, its previous content is deleted and replaced by the new one.

*/
// EXAMPLE OF SELECT FOR NONBLOCKING INPUT
/*
	fd_set ptrRead;
	struct timeval tt; tt.tv_sec=1;
	do{
		cout << "." <<endl;
		FD_SET(0, &ptrRead);
		select(1, &ptrRead, NULL,NULL, &tt);
		tt.tv_sec=1;
	}while(!FD_ISSET(0,&ptrRead));
	cout << "salio" << endl;
	return 0;
 */

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

int keyPressed(){
	fd_set ptrRead;
	struct timeval tt;
	FD_ZERO(&ptrRead);
	FD_SET(0, &ptrRead);
	tt.tv_sec=0;
	tt.tv_usec=0;
	select(1, &ptrRead, NULL,NULL, &tt);
	return (FD_ISSET(0,&ptrRead));
}