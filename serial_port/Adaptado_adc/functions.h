#ifndef	FUNCTIONS_H_
#define	FUNCTIONS_H_


// User Defines
#define FIRST_HIGH
	// Indica que los bytes de cada dato se envían en orden HIGH-LOW.
#define MODO_USO "Modo de uso: ./uart_rx file_name [-ow] [-bd <baudrate>] [-to <timeout>] [-p <port>] [-max <max_file_size_KB>] [-fast]\nParameters between brackets are optional."
#define HELP_COMMANDS ""
#define	TEXT_EXT	".txt"
#define	BIN_EXT		".bin"
#define KB 1024
//default values
#define	NAME					"./logs/test"
#define LOG_FILENAME	"./logs/log.txt"
#define	PIPE_NAME			"/tmp/pipeUartAdc"


// Standard
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <sys/select.h>
#include <ctime>
#include <vector>
#include <sys/types.h>	//mkfifo()
#include <sys/stat.h>	//mkfifo(), umask()
#include <fcntl.h>  //open()

#ifdef _WIN32
#include <Windows.h>
#else
#include <unistd.h>
#endif

using namespace std;

struct sUartConfig{
	/// Variables for serial port config
	int cport_nr;//=ttyUSB0;
	int bdrate;//=9600;
	char mode[4];//={'8','N','1',0};
};

struct sGeneralConfig{
	int	timeout,
			syncSamples,
			maxSize;
	string	fileNameTxt,
					fileNameBin,
					textDescription,
					fileNameLog,
					name,
					pipeName;
	bool	autoPlot; //plot without asking
	string vpp,offset,res,cap,tau,frec,tipo,duty,vref;
	string instrumentos;
	//Agregar al log:
	/* Instrumentos (osciloscopio, generador, )
		* Condiciones circuitales (R,C,Tau?, Fclk,)
		* Señal medida (Vpp, offset, frec, tipo, duty)
		* */
};

struct sFiles{
	fstream	fTxt,
					fBin,
					fLog;
};


// keyboard and other interface functions
int clrbuf(int fd=0);
int keyPressed(int fd=0);
int readUntil(char *cad, char delimiter='\n', int max=50);
int readUntil(string & str, char delimiter='\n', int max=200);

int getParam(int argc, char **argv, sGeneralConfig & generalConfig, sUartConfig & uartConfig);

/// sync bytes of trama?
int receiveUart(sGeneralConfig generalConfig, sUartConfig uartConfig, sFiles & Files, vector<short int> & myData);
int send2Matlab(vector<short> x, sGeneralConfig generalConfig, int cport_nr);
int sync(int cport_nr, int cant, int timeout=0);
int getUartDummies(int cport_nr, int bytes, int timeout);
int descartarPares(int cport_nr);


// other functions
int openFiles(sGeneralConfig generalConfig, sFiles & Files, sUartConfig uartConfig);
int openPipe(const char * pipeName);
int createPipe(sGeneralConfig generalConfig);
int showConfig(sGeneralConfig generalConfig, sUartConfig uartConfig);
string getTimeStr();
string getFileName(string name, string ext);

//HACER!!
int Load(); //from file.


#endif