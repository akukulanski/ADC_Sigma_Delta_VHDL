
#include <iostream>
#include <string>
#include <stdio.h>
#include <math.h>
#include <fstream>

const double pi=3.14159265358979;

using namespace std;

int testTypes(void);
int generateSignalUart(void);

int main(void){
	return generateSignalUart();
}

#define	AMP		0x7FFF
#define	SIZE	1000.0
#define	PER		100.0
#define NUM_COMMANDS 1
int generateSignalUart(void){
	int i=0;
	const short Amp		= AMP;
	const int		Size	= SIZE;
	const double w0 = 2*pi/PER;
	short value;
	
	ofstream file, fileB;
	file.open("reception_example.txt", ios::out);
	fileB.open("reception_example.bin", ios::binary);
	

	FILE * gnuplotPipe = popen ("gnuplot -persistent", "w");
	char * commandsForGnuplot[] = {"set title \"TITLEEEEE\""};//, "plot 'data.temp'"};
	for(int i=0; i < NUM_COMMANDS; i++){
		fprintf(gnuplotPipe, "%s \n", commandsForGnuplot[i]); //Send commands to gnuplot one by one.
	}
	fprintf(gnuplotPipe, "set xrange [0:%d] \n", Size);
	fprintf(gnuplotPipe, "plot '-' \n");

	for(int i=0;i<SIZE;i++){
		value = (short) (Amp * sin(w0*i));
		file.write((char *)&value, 2);
		fileB.write((char *)&value, 2);
		fprintf(gnuplotPipe, "%d %d\n", (int)i, (int)value);
	}
	fprintf(gnuplotPipe, "e");
	fflush(gnuplotPipe);

	return 0;	
}



int testTypes(void){
	unsigned char c[256];
	for(int i=0;i<256;i++)
		c[i] = i;

	unsigned char c1=1, c2=255;
	printf("%x\t%x\t%x\t%x\t%x\n", c1, (unsigned short int) c1, (signed short int)c1, ((signed short int)c1)<<8, (unsigned short int)(((signed short int)c1)<<8));
	printf("%x\t%x\t%x\t%x\t%x\n", c2, (unsigned short int) c2, (signed short int)c2, ((signed short int)c2)<<8, (unsigned short int)(((signed short int)c2)<<8));
	signed short ss[256]={0x0000};
	
	cout << endl << "non-inverting output" << endl;
	for(int i=0;i<256;i++){
		ss[i] = 0x0000;
		ss[i] |= c[i]<<8;
		ss[i] |= c[i];
		//ss[i] |= ( ((unsigned short int)c[i])<<8 );
		//ss[i] |= (unsigned short int)c[i];
		printf("%d\t%x\t%x\t%x\t%x\t%d\t%x\n", c[i], c[i], (((unsigned short int)c[i])<<8), (unsigned short int)c[i], (unsigned short)ss[i], ss[i], ss[i]);
	}
	
	cout << sizeof(unsigned short int) << endl;
	return 0;
}