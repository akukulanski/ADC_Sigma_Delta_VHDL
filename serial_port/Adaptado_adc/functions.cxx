
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
	do{
		string param(argv[numarg]);
		if(param==string("-h") || param==string("--help")){	// show help
			cout << MODO_USO << endl;
			cout << "\tNo\tDevice" << endl;
			for(int i=0;i<16;i++) cout << "\t" << i << "\t" << "ttyS" << i << endl;
			for(int i=0;i<6;i++) cout << "\t" << i+16 << "\t" << "ttyS" << i << endl;
		}else if(param==string("-to")){	// timeout <value in seconds>
			generalConfig.timeout = atoi(argv[++numarg]);
		}else if(param==string("-max")){ // max file size in KB
			generalConfig.maxSize = atoi(argv[++numarg]);
		}else if(param==string("-autoplot")){ // real-time plot (unused so far)
			generalConfig.autoPlot = true;
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
		}else if(param==string("-vpp")){
			generalConfig.vpp = atoi(argv[++numarg]);
		}else if(param==string("-offset")){
			generalConfig.offset = atoi(argv[++numarg]);
		}else if(param==string("-res")){
			generalConfig.res = atoi(argv[++numarg]);
		}else if(param==string("-cap")){
			generalConfig.cap = atoi(argv[++numarg]);
		}else if(param==string("-tau")){
			generalConfig.tau = atoi(argv[++numarg]);
		}else if(param==string("-frec")){
			generalConfig.frec = atoi(argv[++numarg]);
		}else if(param==string("-tipo")){ //tipo señal entrada
			generalConfig.tipo = atoi(argv[++numarg]);
		}else if(param==string("-duty")){
			generalConfig.duty = atoi(argv[++numarg]);
		}else if(param==string("-vref")){
			generalConfig.vref = atoi(argv[++numarg]);
		}else if(param==string("-instr")){
			generalConfig.instrumentos = string(argv[++numarg]);
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
	cout << endl << "Name: " << generalConfig.name << endl;
	cout << "Description: " << generalConfig.textDescription << endl;
	cout << "Max. Size: " << generalConfig.maxSize << " KB" << endl;
	cout << "Timeout: " << generalConfig.timeout << " seconds" << endl;
	cout << "Sync. Samples: " << generalConfig.syncSamples << endl;
	cout << "AutoPlot: " << ((generalConfig.autoPlot) ? string("Y") : string("N")) << endl;
	cout << "vpp=" << generalConfig.vpp << "\tVoffset=" <<generalConfig. offset << "\tVref=" << generalConfig.vref << endl;
	cout << "R=" << generalConfig.res << "\tC=" << generalConfig.cap << "\ttau=" << generalConfig.tau << endl;
	cout << "frecInput=" << generalConfig.frec << "\ttipoSignal=" << generalConfig.tipo << "\tDuty=" << generalConfig.duty << endl;
	cout << "Instrumentos: " << generalConfig.instrumentos << endl;

	cout << "*** SERIAL RECEIVER CONFIG ***" << endl;
	cout << "port: \t\t" << uartConfig.cport_nr << endl;
	cout << "baudrate:\t" << uartConfig.bdrate << endl;
	cout << "mode: \t" << string(uartConfig.mode) << endl;
	return 0;
}

/// ****************************
/// *** Files functions ********

int openFiles(sGeneralConfig generalConfig, sFiles & Files, sUartConfig uartConfig){
	// Opening files
	int err=0x00;
	generalConfig.fileNameTxt = getFileName(generalConfig.name, TEXT_EXT);
	Files.fTxt.open(generalConfig.fileNameTxt.c_str(), ios::out);
	if (!(Files.fTxt.is_open())){
		cout << "Error al abrir archivo " << generalConfig.fileNameTxt << "." <<endl;
		err |= 0x01;
	}
	generalConfig.fileNameBin = getFileName(generalConfig.name, BIN_EXT);
	//Files.fBin.open(generalConfig.fileNameBin.c_str(), ios::binary);
	Files.fBin.open(generalConfig.fileNameBin.c_str(), ios::out);
	if (!(Files.fBin.is_open())){
		cout << "Error al abrir archivo " << generalConfig.fileNameBin << "." <<endl;
		err |= 0x02;
	}
	Files.fLog.open(generalConfig.fileNameLog.c_str(), ios::app);
	if(!Files.fLog.is_open()){
		cout << "Error al abrir archivo " << generalConfig.fileNameLog << "." <<endl;
		err |= 0x04;
	}

	if(Files.fLog.is_open()){
		Files.fLog << endl;
		Files.fLog << "*** NEW ACQUISITION ***" << endl;
		Files.fLog << "name=" << generalConfig.name << endl;
		Files.fLog << "description=" << generalConfig.textDescription << endl;
		Files.fLog << "txtfilename=" << generalConfig.fileNameTxt << endl;
		Files.fLog << "binfilename=" << generalConfig.fileNameBin << endl;
		Files.fLog << "timeout=" << generalConfig.timeout << endl;
		Files.fLog << "maxsize=" << generalConfig.maxSize << endl;
		Files.fLog << "syncsamples=" << generalConfig.syncSamples << endl;
		Files.fLog << "port=" << uartConfig.cport_nr << endl;
		Files.fLog << "baudrate=" << uartConfig.bdrate << endl;
		Files.fLog << "mode=" << uartConfig.mode << endl;
		Files.fLog << "vpp=" << generalConfig.vpp << endl << "offset=" << generalConfig.offset << endl << "vref=" << generalConfig.vref << endl;
		Files.fLog << "res=" << generalConfig.res << endl << "cap=" << generalConfig.cap << endl << "tau=" << generalConfig.tau << endl;
		Files.fLog << "frec=" << generalConfig.frec << endl << "tipo=" << generalConfig.tipo << endl << "duty=" << generalConfig.duty << endl;
		Files.fLog << "Instrumentos: " << generalConfig.instrumentos << endl;
	#ifdef	FIRST_HIGH
		Files.fLog << "order=FIRST_HIGH" << endl;
	#else
		Files.fLog << "order=FIRST_LOW" << endl;
	#endif
		Files.fLog << "*** END ***" << endl;
		Files.fLog.close();
	}
	return err;
}

/// *******************************
/// *** Keyboard functions ********

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

/// ***************************
/// *** Time functions ********

string getTimeStr(void){
	char ss[20];
	std::time_t myTime; time(&myTime);
	strftime(ss, 20, "%Y%m%d_%H%M%S",localtime(&myTime));//timeinfo);
	return string(ss);
}
string getFileName(string name, string ext){
	bool ow=false;
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

/// ************************************
/// *** Communication functions ********

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
	#ifdef FIRST_HIGH
				// Si llega primero el byte HIGH, no se modifica el orden. Sale directo con fritas.
				//txt.put(buf[i]);
				if(state==LOW){
					myValue = 0x00FF & buf[i];
					myValue |= 0xFF00 & (((unsigned short)last)<<8);
					Files.fTxt << (signed short int) myValue << '\n';
					Files.fBin.write((char *)&myValue, 2);
					printf("%7d\t", myValue); //cout << (short) myValue << "\t";
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
					myValue = 0x00FF & last;
					myValue |= 0xFF00 & (((unsigned short)buf[i])<<8) ;
					Files.fTxt << (signed short int) myValue << '\n';
					Files.fBin.write((char *)&myValue, 2);
					cout << (signed short int) myValue << endl;
					myData.push_back(myValue);
					state=LOW;
				}
	#endif
			}
			cout << endl;
		}
		//if(keyPressed(0)){
			//char dummy[30];
			//readUntil(dummy,'\n',30);
			//clrbuf(0);
			//break;
		//}
	}
	
	return cant;
}

int send2Matlab(vector<short> x, sGeneralConfig generalConfig, int cport_nr){
	char buffer[2*x.size()];
	for(unsigned int i=0;i<x.size();i++){
		buffer[2*i] = x[i] & 0x00FF;
		buffer[2*i+1] = ( x[i] >> 8 ) & 0x00FF;
		cout << "toWrite=" << *(short *)(buffer+2*i) << endl;
		descartarPares(cport_nr); //poner en loops!!
	}
	cout << "Opening pipe: " << generalConfig.pipeName << endl;
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
			return 1;
		}
	}
	return 0;
}
int descartarPares(int cport_nr){
	unsigned char dummy[4096];
	int n = RS232_PollComport(cport_nr, dummy, 4094);
	if(n>0){
		if(!(n%2)) return 0; //par
		int i=10000;
		while(i-- && n!=1) n = RS232_PollComport(cport_nr, dummy, 1);
	}
	return 0; //nada para leer
}

int sync(int cport_nr, int cant, int timeout){
	//getUartDummies(cport_nr, 1000, 1); //hacer: empty uart buffer!
	descartarPares(cport_nr);
	//return 0; //CORREGIR PELOTUDOOOOOOOOOOOOOOOOOOOOOOOO
	
	int n=0, leidos=0, cant_bytes=2*cant;
	unsigned char buffer[cant_bytes],dummy[50];
	//signed short *ptrA,*ptrB;
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
	sync=(leidos+1)%2; //+1
	
	long long difA=0,difB=0, corrA=0,corrB=0;
	for(int i=0;i<cant-2;i++){
		short	Anow	=	0xFF00 & ((short)buffer[2*i]<<8);
				Anow	|=	0x00FF & buffer[2*i+1];
		short Bnow	=	0xFF00 & ((short)buffer[2*i+1]<<8);
				Bnow	|=	0x00FF & buffer[2*i+2];
		short Anext	=	0xFF00 & ((short)buffer[2*i+2]<<8);
				Anext	|= 	0x00FF & buffer[2*i+3];
		short Bnext	= 0xFF00 & ((short)buffer[2*i+3]<<8);
				Bnext	|=	0x00FF & buffer[2*i+4];
		
		difA += (long long)abs(Anext-Anow);
		difB += (long long)abs(Bnext-Bnow);
		
		if((n = RS232_PollComport(cport_nr, dummy, 50)) > 0){
			sync += n;
			sync %= 2;
		}
		//descartarPares(cport_nr);
	}
	corrA = difB;
	corrB = difA;
	
	/*
	//valor medio
	int medA=0,medB=0;
	//ptrA = (signed short *) buffer;
	//ptrB = (signed short *) (buffer+1);
	for(int i=0;i<cant-2;i++){
		short	A =	0xFF00 & ((short)buffer[2*i]<<8);
					A|=	0x00FF & buffer[2*i+1];
		short B	=	0xFF00 & ((short)buffer[2*i+1]<<8);
				B	|=	0x00FF & buffer[2*i+2];
		medA += (int)A;
		medB += (int)B;
		if((n = RS232_PollComport(cport_nr, dummy, 50)) > 0){
			sync += n;
			sync %= 2;
			//sync = (n+sync)%2;
		}
		//descartarPares(cport_nr);
	}
	medA /= cant-1;
	medB /= cant-1;
	cout << "MedA=" << medA << "\tMedB=" << medB << endl;
	//getchar();
	
	//std
	long long stdA=0,stdB=0;
	//ptrA = (signed short *) buffer;
	//ptrB = (signed short *) (buffer+1);
	for(int i=0;i<cant-1;i++){ // var < 2*cant ; 2*i+2<2cant ; i<cant-1
		short	A =	0xFF00 & ((short)buffer[2*i]<<8);
					A|=	0x00FF & buffer[2*i+1];
		short B	=	0xFF00 & ((short)buffer[2*i+1]<<8);
				B	|=	0x00FF & buffer[2*i+2];
		stdA += (long long)((int)A-medA)*((int)A-medA);
		stdB += (long long)((int)B-medB)*((int)B-medB);
		if((n = RS232_PollComport(cport_nr, dummy, 50)) > 0){
			sync += n;
			sync %= 2;
		}
		//descartarPares(cport_nr);
	}
	cout << "stdA=" << stdA << "\tstdB=" << stdB << endl;
	//getchar();
	
	//autocorrelación en T=1
	double corrA=0,corrB=0;
	//ptrA = (signed short *) buffer;
	//ptrB = (signed short *) (buffer+1);
	for(int i=0;i<cant-2;i++){// var < 2*cant ; 2i+4<2cant ; i<cant-4/2; i<cant-2
		
		//Anow = (((int)*(ptrA++))-medA);
		//Anext = ((int)*(ptrA))-medA;
		//Bnow = ((int)*(ptrB++))-medB;
		//Bnext = ((int)*(ptrB))-medB;
		
		short	Anow	=	0xFF00 & ((short)buffer[2*i]<<8);
				Anow	|=	0x00FF & buffer[2*i+1];
		short Bnow	=	0xFF00 & ((short)buffer[2*i+1]<<8);
				Bnow	|=	0x00FF & buffer[2*i+2];
		short Anext	=	0xFF00 & ((short)buffer[2*i+2]<<8);
				Anext	|= 	0x00FF & buffer[2*i+3];
		short Bnext	= 0xFF00 & ((short)buffer[2*i+3]<<8);
				Bnext	|=	0x00FF & buffer[2*i+4];
		
		corrA += (double)Anext*(double)Anow/stdA;
		corrB += (double)Bnext*(double)Bnow/stdB;
		
		cout << "Anow*Anext/stdA=" << Anow << "*" << Anext << "/" << stdA << "=" << (double)Anext*Anow/stdA << "\tcorrA=" << corrA << endl;
		cout << "Bnow*Bnext/stdB=" << Bnow << "*" << Anext << "/" << stdB << "=" << (double)Bnext*Bnow/stdB << "\tcorrB=" << corrB << endl;

		if((n = RS232_PollComport(cport_nr, dummy, 50)) > 0){
			sync += n;
			sync %= 2;
		}
	}
	//corrA = abs(corrA);
	//corrB = abs(corrB);
	*/
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