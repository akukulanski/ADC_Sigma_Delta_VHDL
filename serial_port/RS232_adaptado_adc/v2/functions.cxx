
#include <math.h>
// Serial Port
#include "rs232.h"
#include "uart_rx.h"
#include "functions.h"


using namespace std;

/**	@brief Returns if samples are syncronized by calculating autocorrelation.
 *	@param cant Amount of samples to calculate correlation
 * 	@param timeout In seconds. -1 for inf.
 *	@return (int) 0 for syncronized, 1 for single-sample offset, -2 for timeout, -4 for no conclution.
 */
int sync(int cport_nr, int cant, int timeout){
	getUartDummies(cport_nr, 1000, 1); //hacer: empty uart buffer!
	return 0; //CORREGIR PELOTUDOOOOOOOOOOOOOOOOOOOOOOOO
	
	int n=0, leidos=0, cant_bytes=2*cant;
	unsigned char buffer[cant_bytes],dummy[50];
	signed short *ptrA,*ptrB;
	int sync=0;
	
	std::time_t timeStart, currentTime;
	time(&timeStart);
	time(&currentTime);
	while(leidos<cant){
		n = RS232_PollComport(cport_nr, buffer+leidos, cant_bytes-leidos);
		for(int i=0;i<n;i++){
			cout << "Received: " << (int)*(buffer+leidos+i) << endl;
		}
		if(n>0) leidos+=n;
		if(timeout && currentTime>=timeStart+timeout){
			cout << "tiomeout!" << endl;	
			return -2;
		}
	}
	sync=(leidos+1)%2;
	//+1 
	
	/*
	ptrA = (signed short *) buffer;
	ptrB = (signed short *) ((char *)buffer+1);
	int Anow,Anext,Bnow,Bnext;
	int cntA=0,cntB=0;
	for(int i=0;i<cant-1;i++){
		Anow = (int)*(ptrA++);
		Anext = (int)*(ptrA);
		Bnow = (int)*(ptrB++);
		Bnext = (int)*(ptrB);
		cntA += abs(Anext-Anow);
		cntB += abs(Bnext-Bnow);
		if((n = RS232_PollComport(cport_nr, dummy, 50)) > 0){
			sync += n;
			sync %= 2;
			//sync = (n+sync)%2;
		}
		cout << "abs(Anow-Anext) = abs(" << Anow << "-" << Anext << ") = " << abs(Anext-Anow) << '\t' << "cntA = " << cntA << endl;
		cout << "abs(Bnow-Bnext) = abs(" << Bnow << "-" << Bnext << ") = " << abs(Bnext-Bnow) << '\t' << "cntB = " << cntB << endl;
	}
	if(cntA> cntB){ //no hace falta desfasar
		cout << "cntA > cntB" << endl;
		return sync;
	}else if(cntB > cntA){ //desfasar 1 byte
		cout << "cntA < cntB" << endl;
		return ((sync+1)%2);
	}else{ //no concluye
		cout << "cntA = cntB" << endl;
		return -4; //no concluye
	}*/
	
	//valor medio
	int medA=0,medB=0;
	ptrA = (signed short *) buffer;
	ptrB = (signed short *) (buffer+1);
	for(int i=0;i<cant-1;i++){
		medA += (int)*(ptrA++);
		medB += (int)*(ptrB++);
		if((n = RS232_PollComport(cport_nr, dummy, 50)) > 0){
			sync += n;
			sync %= 2;
			//sync = (n+sync)%2;
		}
	}
	medA /= cant-1;
	medB /= cant-1;
	cout << "MedA=" << medA << "\tMedB=" << medB << endl;
	
	//std
	int stdA=0,stdB=0;
	ptrA = (signed short *) buffer;
	ptrB = (signed short *) (buffer+1);
	for(int i=0;i<cant-1;i++){
		int tempA=0,tempB=0;
		tempA = (int)*(ptrA++);
		tempB = (int)*(ptrB++);
		stdA += (tempA-medA)*(tempA-medA);
		stdB += (tempB-medB)*(tempB-medB);
		if((n = RS232_PollComport(cport_nr, dummy, 50)) > 0){
			sync += n;
			sync %= 2;
		}
	}
	cout << "stdA=" << stdA << "\tstdB=" << stdB << endl;
	
	//autocorrelación en T=1
	double corrA=0,corrB=0;
	int Anow,Anext,Bnow,Bnext;
	ptrA = (signed short *) buffer;
	ptrB = (signed short *) (buffer+1);
	for(int i=0;i<cant-2;i++){
		Anow = (((int)*(ptrA++))-medA);
		Anext = ((int)*(ptrA))-medA;
		Bnow = ((int)*(ptrB++))-medB;
		Bnext = ((int)*(ptrB))-medB;
		
		cout << "Anow*Anext/stdA=" << Anow << "*" << Anext << "/" << stdA << "=" << (double)Anext*Anow/stdA;
		corrA += (double)Anext*Anow/stdA;
		cout << "\tcorrA=" << corrA << endl;
		cout << "Bnow*Bnext/stdB=" << Bnow << "*" << Anext << "/" << stdB << "=" << (double)Bnext*Bnow/stdB;
		corrB += (double)Bnext*Bnow/stdB;
		cout << "\tcorrB=" << corrB << endl;

		if((n = RS232_PollComport(cport_nr, dummy, 50)) > 0){
			sync += n;
			sync %= 2;
		}
	}

	cout << "corrA=" << corrA << "\tcorrB=" << corrB << endl;
	if(corrA > corrB){ //no hace falta desfasar
		cout << "corrA > corrB" << endl;
		return sync;
	}else if(corrB > corrA){ //desfasar 1 byte
		cout << "corrA < corrB" << endl;
		return ((sync+1)%2);
	}else{ //no concluye
		cout << "corrA = corrB" << endl;
		return -4; //no concluye
	}
}

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
	if(argc<2){
		cout << "Error. " << MODO_USO << endl;
		return 1;
	}
	int numarg=2;
	generalConfig.ow=false;
	generalConfig.bin=false;
	generalConfig.autoPlot=false;
	do{
		string param(argv[numarg]);
		if(param==string("-h") || param==string("--help")){	// show help
			cout << MODO_USO << endl;
			cout << "\tNo\tDevice" << endl;
			for(int i=0;i<16;i++) cout << "\t" << i << "\t" << "ttyS" << i << endl;
			for(int i=0;i<6;i++) cout << "\t" << i+16 << "\t" << "ttyS" << i << endl;
		}else if(param==string("-ow")){	// overwrite files
			generalConfig.ow=true;
		}else if(param==string("-to")){	// timeout <value in seconds>
			generalConfig.timeout = atoi(argv[++numarg]);
		}else if(param==string("-max")){ // max file size in KB
			generalConfig.maxSize = atoi(argv[++numarg]);
		}else if(param==string("-bin")){ // output binary file (not generated if not specified)
			generalConfig.bin = true;
		}else if(param==string("-autoplot")){ // real-time plot (unused so far)
			generalConfig.autoPlot = true;
		}else if(param==string("-noconf")){	//no configurar. rápido,automático.
			generalConfig.configure = false;
		}else if(param==string("-name")){
			generalConfig.name = argv[++numarg];
		}else if(param==string("-pipename")){
			generalConfig.pipeName = argv[++numarg];
		}else if(param==string("-syncsamples")){
			generalConfig.syncSamples = atoi(argv[++numarg]);
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

int showConfig(sGeneralConfig & generalConfig){
		cout << endl << "Name: " << generalConfig.name << endl;
		cout << "Description: " << generalConfig.textDescription << endl;
		cout << "Max. Size: " << generalConfig.maxSize << " KB" << endl;
		cout << "Timeout: " << generalConfig.timeout << " seconds" << endl;
		cout << "AutoSync: " << generalConfig.syncSamples << endl;
		//cout << "Real Time: " << (generalConfig.autoPlot)?"Yes":"No" << endl;
		//cout << "Commands:" << endl << "Start <S>" << endl << "Stop <SP>" << endl << "Print <P>" << endl << "Reset <R>" << endl;	
		return 0;
}

int showUartConfig(sUartConfig & uartConfig){
	cout << "*** SERIAL RECEIVER CONFIG ***" << endl;
	cout << "port: \t\t" << uartConfig.cport_nr << endl;
	cout << "baudrate:\t" << uartConfig.bdrate << endl;
	cout << "mode: \t" << string(uartConfig.mode) << endl;
	return 0;
}

int showMenu(sGeneralConfig & generalConfig){
	//Menu configuración:
	if(generalConfig.configure){
		char cc=0;
		do{
			char buffer[100];
			cout << endl << "Commands:\n-Press p to load file and plot.\n-Press any other key to start acquisition." << endl;
			readUntil(buffer);
			cc=buffer[0];
			if(cc=='p'){
				string fileLoad("");
				cout << "Insert file name: ";
				readUntil(fileLoad);
				Load();//Load(File, myVector);
				//send2Matlab(myData, generalConfig);
			}
		}while(cc=='p');
		string temp("");
		do{
			temp=string("");
			
			//Name
			cout << endl << "Name [" << generalConfig.name << "]: ";
			readUntil(temp);
			
			//Description
			if(temp != string("")) generalConfig.name = temp;
			cout << "Description: ";	
			readUntil(temp);
			if(temp != string("")) generalConfig.textDescription = temp;
		
			//Max Size
			cout << "Max. Size (KB): [" << generalConfig.maxSize << "]: ";
			readUntil(temp);
			if(temp != string("")) generalConfig.maxSize=atoi(temp.c_str());

			//Timeout
			cout << "Timeout (in seconds) [" << generalConfig.timeout << "]: ";
			readUntil(temp);
			if(temp != string("")) generalConfig.timeout=atoi(temp.c_str());

			//autoPlot
			cout << "AutoPlot (Y/N) [" << string((generalConfig.autoPlot)?"Y":"N") << "]: ";
			readUntil(temp);
			if(temp != string("")){
				if(temp==string("Y") || temp==string("y")) generalConfig.autoPlot = true;
				else if (temp==string("N") || temp==string("n")) generalConfig.autoPlot = false;
				else cout << "Not recognized. Autoplot=" << string((generalConfig.autoPlot)?"Y":"N") << endl;
			}
			
			//Autoplot
			cout << "Auto Sync (0-1000) [" <<  generalConfig.syncSamples << "]: ";
			readUntil(temp);
			if(temp!=string("")) generalConfig.syncSamples = atoi(temp.c_str());
			
			cout << endl << "*** Config ***" << endl;
			showConfig(generalConfig);
			cout << "\nCommands:\n-Press e to edit.\n-Press any other key to start." << endl;
			readUntil(temp);
			cc=temp[0];
		}while(cc == 'e');
	}
	return 0;
}

int openFiles(sGeneralConfig & generalConfig, sFiles & Files){
		// Opening files
		//string getFileName(string fileName, string ext, bool ow);
		generalConfig.fileNameTxt = getFileName(generalConfig.name, TEXT_EXT, generalConfig.ow);
		Files.fTxt.open(generalConfig.fileNameTxt.c_str(), ios::out);
		if (!(Files.fTxt.is_open())){
			cout << "Error al abrir archivo " << generalConfig.fileNameTxt << "." <<endl;
			return 0x01;
		}
		if(generalConfig.bin){
			generalConfig.fileNameBin = getFileName(generalConfig.name, BIN_EXT, generalConfig.ow);
			Files.fBin.open(generalConfig.fileNameBin.c_str(), ios::binary);
			if (!(Files.fBin.is_open())){
				cout << "Error al abrir archivo " << generalConfig.fileNameBin << "." <<endl;
				return 0x02;
			}
		}
		Files.fLog.open(generalConfig.fileNameLog.c_str(), ios::app);
		if(!Files.fLog.is_open()){
				cout << "Error al abrir archivo " << generalConfig.fileNameLog << "." <<endl;
				return 0x04;
		}
		return 0;
}

int writeLog(fstream & logFile, sGeneralConfig generalConfig, sUartConfig uartConfig){
	if(!logFile.is_open()) return 1;
	logFile << endl;
	logFile << "*** NEW ACQUISITION ***" << endl;
	logFile << "name=" << generalConfig.name << endl;
	logFile << "description=" << generalConfig.textDescription << endl;
	logFile << "txtfilename=" << generalConfig.fileNameTxt << endl;
	if(generalConfig.bin) logFile << "binfilename=" << generalConfig.fileNameBin << endl;
	logFile << "timeout=" << generalConfig.timeout << endl;
	logFile << "maxsize=" << generalConfig.maxSize << endl;
	logFile << "syncsamples=" << generalConfig.syncSamples << endl;
	logFile << "port=" << uartConfig.cport_nr << endl;
	logFile << "baudrate=" << uartConfig.bdrate << endl;
#ifdef	FIRST_HIGH
	logFile << "order=FIRST_HIGH" << endl;
#else
	logFile << "order=FIRST_LOW" << endl;
#endif
	logFile << "*** END ***" << endl;
	return 0;
}

int receiveUart(sGeneralConfig generalConfig, sUartConfig uartConfig, sFiles & Files, vector<short int> &myData){
	enum nState{LOW=0, HIGH=1};
	int state=LOW;
	unsigned char last=0x00;
	signed short int myValue=0x0000;
	int cant=0;
	myData.clear();
	#ifdef FIRST_HIGH
		state=HIGH;
	#endif

	while(cant < KB*generalConfig.maxSize){ //máximo tamaño archivo de datos
		unsigned char buf[4096];
		int n = RS232_PollComport(uartConfig.cport_nr, buf, 4095);
		if(n > 0){ //recibió byte(s)
			cant+=n;
			// Conversión 2bytes -> 1short
			for(int i=0;i<n;i++){
				//cout << "char=" << buf[i] << endl;
				//continue;
				//if(!((cant+i-n)%8)) cout << endl;
	#ifdef FIRST_HIGH
				// Si llega primero el byte HIGH, no se modifica el orden. Sale directo con fritas.
				//txt.put(buf[i]);
				if(state==LOW){
					myValue &= 0x0000;
					myValue |= buf[i];
					myValue |= ((unsigned short)last)<<8;
					Files.fTxt << (signed short int) myValue << '\n';
					if(generalConfig.bin) Files.fBin.write((char *)&myValue, 2);
					cout << "myvalue=" << (short) myValue << endl;	//printf("%8d\t", myValue);
					myData.push_back(myValue);
					state=HIGH;
				}else{
					last = buf[i];
					state=LOW;
				}
	#else
				//si llega primero LOW. (no está verificado que funcione!)
				if(state==LOW){
					last = buf[i];
					state=HIGH;
				}else{
					myValue &= 0x0000;
					myValue |= last;
					myValue |= ((unsigned short)buf[i])<<8 ;
					Files.fTxt << (signed short int) myValue << '\n';
					if(generalConfig.bin) bin.write((char *)&myValue, 2);
					cout << (signed short int) myValue << endl;
					myData.push_back(myValue);
					state=LOW;
				}
	#endif
			}
		}
		if(keyPressed()){
			//char dummy[30];
			//readUntil(dummy,'\n',30);
			clrbuf(0);
			break;
		}
	}
	send2Matlab(myData, generalConfig);
	return cant;
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

int readUntil(char *cad, char delimiter, int max){
	int i=0;
	while(i+1<max){
		char c=cin.get();
		if(c==delimiter) break;
		cad[i++] = c;
	};
	cad[i]='\0';
	return i;
}

int readUntil(string & str, char delimiter, int max){
	char buffer[max];
	int ret=readUntil(buffer,delimiter,max);
	str=string(buffer);
	return ret;
}

string getTimeStr(void){
	char ss[20];
	std::time_t myTime; time(&myTime);
	strftime(ss, 20, "%Y%m%d_%H%M%S",localtime(&myTime));//timeinfo);
	return string(ss);
}
	/*
	std::time_t myTime;
	struct tm * timeinfo;
	time(&myTime);
	timeinfo = localtime(&myTime);
	char ss[20];
	strftime(ss, 20, "%Y%m%d_%H%M%S",timeinfo);*/
	//cout << timeinfo->tm_year+1900 << timeinfo->tm_mon+1 << timeinfo->tm_mday << "_" << timeinfo->tm_hour << timeinfo->tm_min << timeinfo->tm_sec << endl;
//sleep(1);
//system("clear");

string getFileName(string name, string ext, bool ow){
	stringstream fileName;
	ifstream fileDummy;
	fileName.str("");
	fileName << name << "_" << getTimeStr() << ext;
	if(!ow){
		unsigned char c=0;
		fileDummy.open(fileName.str().c_str(), ios::in);
		while(++c && fileDummy.is_open()){ //existe y no hubo no overflow (256 máx)
			fileDummy.close();
			fileName.str("");
			fileName << name << "_" << getTimeStr()  << "(" << (c-1) << ")" << ext;
			fileDummy.open(fileName.str().c_str(), ios::in);
		}
		if(!c){
			cout << "Máximo 256 archivos con el mismo nombre. Usar otro." << endl;
			return string("");
		}
	}
	return fileName.str();
}


int Load(){
	cout << "Load() never coded" << endl;
	return 0;
}

int send2Matlab(vector<short> x, sGeneralConfig generalConfig){
	char buffer[2*x.size()];
	for(unsigned int i=0;i<x.size();i++){
		buffer[2*i] = x[i] & 0x00FF;
		buffer[2*i+1] = ( x[i] >> 8 ) & 0x00FF;
		cout << "toWrite=" << *(short *)(buffer+2*i) << endl;
	}
	int pipeFD = openPipe(generalConfig.pipeName.c_str());
	if(!pipeFD){
		cout << "Error. Could not open pipe!" << endl;
		return 1;
	}
	cout << "Writing to FD=" << pipeFD << "..." << endl;
	//int i=write(pipeFD,buffer, 2*x.size());
	//int i=write(pipeFD,(void *)&x[0], 2*x.size()); //.data()
	int i=write(pipeFD,(void *)x.data(), 2*x.size());
	cout << i << " bytes written." << endl;
	close(pipeFD);
	cout << "Pipe closed. Finished!" << endl;
	return 0;
}

int openPipe(const char * pipeName){
	cout << "Opening pipe (waiting for other process -> run matlab script)" << endl;
	int pipeFD = open(pipeName, O_WRONLY);
	if(!pipeFD) cout << "Could not open file" << endl;
	else cout << "Connected!" << endl;
	return pipeFD;
}

int createPipe(sGeneralConfig generalConfig){
	cout << "Creating pipe: " << generalConfig.pipeName << endl;
	if(!mkfifo(generalConfig.pipeName.c_str(), S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH)){ //primer intento
		if(!mkfifo(generalConfig.pipeName.c_str(), S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH)){ //segundo intento
			cout << "Could not create pipe" << endl;
			//generalConfig.errPipe=true;
			return 1;
		}
	}
	//generalConfig.errPipe=true;
	return 0;
}