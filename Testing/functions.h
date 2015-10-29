#ifndef	FUNCTIONS_H_
#define	FUNCTIONS_H_


// User Defines
#define FIRST_HIGH
	// Indica que los bytes de cada dato se envían en orden HIGH-LOW.
#define MODO_USO "Modo de uso: ./uart_rx file_name [-ow] [-bd <baudrate>] [-to <timeout>] [-p <port>] [-samples <number_of_samples>] [-fast]\nParameters between brackets are optional."
#define HELP_COMMANDS ""
#define	TEXT_EXT	".txt"
#define	BIN_EXT		".bin"
#define KB 1024
//default values
#define LOG_FILENAME	"./logs/log.txt"
#define	PIPE_NAME	"/tmp/pipeUartAdc"


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
		numSamples;
	string fileNameLog,
		fileName,
		pipeName;
};

struct sFiles{
	fstream	fBin,
		fLog;
};

int receiveUart(sGeneralConfig generalConfig, sUartConfig uartConfig, sFiles & Files);
int getUartDummies(int cport_nr, int bytes, int timeout);

int getParam(int argc, char **argv, sGeneralConfig & generalConfig, sUartConfig & uartConfig);
int openFiles(sGeneralConfig generalConfig, sFiles & Files, sUartConfig uartConfig);
int showConfig(sGeneralConfig generalConfig, sUartConfig uartConfig);
string getTimeStr();



#endif