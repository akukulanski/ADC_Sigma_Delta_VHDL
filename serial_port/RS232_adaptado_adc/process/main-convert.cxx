
#include <iostream>
#include <string>
#include <stdio.h>
#include <math.h>
#include <fstream>

const double pi=3.14159265358979;

using namespace std;

int Convert(char *, char *);

int main(int argc, char **argv){
	if(argc<3) return 1;
	//Converts to binary
	return Convert(argv[1], argv[2]);
}
int Convert(char * input, char * output){
	ifstream fileInput; ofstream fileOutput;
	fileInput.open(input, ios::in);
	fileOutput.open(output, ios::out);
	// Busca cabecera
	const string DATA("*** DATA ***\n");
	const int LEN=DATA.size();
	int lugar=0;
	do{
		char buffer[LEN+1];
		fileInput.seekg(lugar++);
		//lugar = fileInput.tellg();
		fileInput.read(buffer, LEN);
		if(fileInput.gcount()<12){
			cout << "error!" << endl;
			return 1;
		}
		buffer[LEN]='\0';
		if(string(buffer) == DATA) break;
	}while(!fileInput.eof());
	while(!fileInput.eof()){
		char buffer[1000];
		fileInput.read(buffer, 1000);
		fileOutput.write(buffer, 1000);
	}
	fileInput.close();
	fileOutput.close();
	return 0;
}