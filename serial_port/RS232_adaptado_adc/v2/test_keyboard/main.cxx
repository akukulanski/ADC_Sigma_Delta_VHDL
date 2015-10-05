
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
#include <unistd.h>

using namespace std;

int clrbuf(int fd);
int keyPressed(int fd);
char waitForAnyKey();
int readUntil(char *cad, char delimiter, int max=200);

int main(int argc, char* argv[]){
	
	
	
	/*int num,num2;
	cin >> str;
	cin >> cad;
	cin >> num;
	cin >> num2;
	cout << str << endl << cad << endl << num << endl << num2 << endl;*/
	
	/*
	string str; char cad[100], cad2[100],cad3[100];
	cout << "Not pressed 1" << endl;
	while(!keyPressed(0)){
	};
	cout << "Pressed 1" << endl;
	cin.readsome(cad, 40);
	cad[cin.gcount()]=0;
	cout << "Not pressed 2" << endl;
	while(!keyPressed(0)){
	};
	cout << "Pressed 2" << endl;
	cout << "Not pressed 3" << endl;
	cin.readsome(cad2, 40);
	cad2[cin.gcount()]=0;
	while(!keyPressed(0)){
	};
	cout << "Pressed 3" << endl;
	cin.readsome(cad3, 40);
	cad3[cin.gcount()]=0;
	cout << cad << endl << cad2 << endl << cad3 << endl;
	*/
	
	char cad[100];// cad2[100],cad3[100];
	readUntil(cad, '\n', 100);
	cout << cad << endl;
	
  return 0;
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

char waitForAnyKey(){
	#define STDIN 0
	char dummy;
	read(STDIN,&dummy,1); //cin >> dummy;
	clrbuf(0);
	return dummy;
}