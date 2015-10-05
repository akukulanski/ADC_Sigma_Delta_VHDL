
#include <iostream>
#include <string>
#include <stdio.h>
#include <math.h>
#include <fstream>
#include <sstream>

const double pi=3.14159265358979;

using namespace std;



int main(int argc, char **argv){
	
	if(argc < 2) return 1;
	
	char *fileName = argv[1];
	ifstream file, fileB;
	fileB.open(fileName, ios::binary);
	if(!fileB.is_open()){//|| !file.is_open())
		cout << "Error. Could not open file." << endl;
		return 1;
	}
	FILE * gnuplotPipe = popen ("gnuplot -persistent", "w");
	if(!gnuplotPipe){//|| !file.is_open())
		cout << "Error. Could not open gnuplot pipe." << endl;
		return 1;
	}

	const double Fc=90e6;
	const double Ts=1.0/Fc;
	const double Amp = 1.65; //0x00007FFF, 0x00001000, 32767, -32768
	const double maxShort = 32767.0;
	int i=0, cant=0;
	
	// Cantidad de muestras
	while(!fileB.eof()){
		signed short buffer;// buffer[2];
		fileB.read((char *)&buffer, 2);
		cant++;
	}
	cout << "cant=" << cant << endl;
	fileB.clear();
	fileB.seekg(0, ios::beg) ;
	
	stringstream commands;
	/*
	fprintf(gnuplotPipe, "set term png\n");
	fprintf(gnuplotPipe, "set output \"./printme.png\"\n");
	//fprintf(gnuplotPipe, "replot\n");
	fprintf(gnuplotPipe, "set term x11\n");*/
	commands << "set title \"TITLEEEEE\" " << endl;
	commands << "set yrange [" << -Amp << ":" << Amp << "] " << endl;
	commands << "set xrange [0:" << Ts*cant << "] " << endl;
	/*
	commands	<< "set term png" << endl
						<< "set output \"./printme.png\"" << endl
						<< "replot" << endl
						<< "set term x11" << endl;
	*/	 
	commands << "plot '-' with dots pt 7 ps 1" << endl;
	fprintf(gnuplotPipe, commands.str().c_str());
	commands.str("");
	i=0;
	bool invertir=false;
	while(!fileB.eof()){
		signed short buffer;
		fileB.read((char *)&buffer, 2);
		if(invertir){
				signed short temp=0x0000;
				temp |= (0x00FF) & (buffer>>8);
				temp |= (0xFF00) & (buffer<<8);
				buffer = temp;
		}
		double value = Amp * (double)buffer / 32767.0;
		double time = Ts*i++;
		fprintf(gnuplotPipe, "%f %f\n", time, value);		// Convertidos a Volt y Segundos
		//fprintf(gnuplotPipe, "%d %d\n", i++, buffer);	// Sin conversión a Volt y Segundos
	}
	fprintf(gnuplotPipe, "e\n");

	/*commands	<< "set term png" << endl
						<< "set output \"./printme.png\"" << endl
						<< "replot" << endl
						<< "set term x11" << endl;
						*/
	
	fflush(gnuplotPipe);
	pclose(gnuplotPipe);
	fileB.close();
	
	cout << "Ts=" << Ts << "\tTime=" << Ts*i << endl;
	
	return 0;
}