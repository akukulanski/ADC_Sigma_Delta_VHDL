
#include <stdio.h>
#include <string.h>
#include <string>

// "/home/ariel/git/vhdl-adc/testbench_files/outputs/fir_out_1000.txt"
//"/home/ariel/git/vhdl-adc/testbench_files/outputs/fir_out_1000_int16.txt"

int ascii_to_int16(char *src, char *dst);
int int16_to_ascii(char *src, char *dst);

int main(int argc, char ** argv){

	char src[100], dst[100];
	
	//printf("argc=%d\n",argc);
	//printf("%d\n", '\n');
	
	if(argc==3){
		//printf("1=%s\n2=%s\n",argv[1],argv[2]);
		strcpy(src,argv[1]);
		strcpy(dst,argv[2]);
	}else if(argc==2){
		//printf("1=%s\n\n",argv[1]);
		strcpy(src,argv[1]);
		printf("src========%s\n",src);
		//strncpy(dst,argv[1],strlen(argv[1])-4);
		strcpy(dst,src);
		dst[strlen(argv[1])-4]='\0';
		printf("dst========%s\n",dst);
		strcat(dst,"_int16.txt");
		printf("dst========%s\n",dst);
	}else
		return -1;
	
	printf("src=%s\ndst=%s\n",src,dst);
	ascii_to_int16(src,dst);
	//int16_to_ascii(src,dst);
	
	return 0;
}

int ascii_to_int16(char *src, char *dst){
	int i=0;
	char a[50];
	int num=1;
	
	printf("%s\n%s\n",src,dst);
	FILE *in;
	FILE *out;
	in = fopen(src, "r");
	out = fopen(dst,  "w");
	if((!in) || (!out)) return -1;
	while(num!=EOF){
		num = fscanf(in, "%s",a);
		unsigned short int acum=0;
		for(int j=0; j<strlen(a) ; j++){
			acum += (a[j]=='1') ? 1<<(15-j) : 0 ;
		}
		printf("str=%s\tacum=%d\n", a, acum);
		fwrite(&acum, sizeof(short),1,out);
	}

	fclose(in);
	fclose(out);	
	return 0;
}


int int16_to_ascii(char *src, char *dst){
	int i=0;
	char a[20];

	FILE *in;
	FILE *out;
	in = fopen(src, "r");
	out = fopen(dst, "w");
	int num=1;
	while(num!=EOF){
		num = fscanf(in, "%s",a);
		unsigned short int acum=0;
		for(int j=0; j<strlen(a) ; j++){
			acum += (a[j]=='1') ? 1<<(15-j) : 0 ;
		}
		printf("str=%s\tacum=%d\n", a, acum);
		fwrite(&acum, sizeof(short),1,out);
	}

	fclose(in);fclose(out);	
	return 0;
}