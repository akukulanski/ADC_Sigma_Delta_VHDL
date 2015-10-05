%permission — File access type
%'r' (default) | 'w' | 'a' | 'r+' | 'w+' | 'a+' | 'A' | 'W' | ...
%fd=fopen('/home/ariel/Descargas/pipes_matlab/c_code/hola', 'r');

%% Start
fileName='/tmp/pipeUartAdc';
len = 100;


%% Open
[fileID,errmsg]=fopen(fileName);
%% Load/Plot
data=[0];
data=fread(fileID,len,'short'); %'int16'
figure(1);
plot(data);
grid on;
%% Close
fclose(fileID);

%% Open
[fileID,errmsg]=fopen(fileName);
%% Load/Plot
data2=[0];
data2=fread(fileID,len,'short'); %'int16'
figure(2);
plot(data2);
grid on;
%% Close
fclose(fileID);

%% Open
[fileID,errmsg]=fopen(fileName);
%% Load/Plot
data3=[0];
data3=fread(fileID,len,'short'); %'int16'
figure(3);
plot(data3);
grid on;
%% Close
fclose(fileID);

%% Open
[fileID,errmsg]=fopen(fileName);
%% Load/Plot
data4=[0];
data4=fread(fileID,len,'short'); %'int16'
figure(4);
plot(data4);
grid on;
%% Close
fclose(fileID);

%% Open
[fileID,errmsg]=fopen(fileName);
%% Load/Plot
data5=[0];
data5=fread(fileID,len,'short'); %'int16'
figure(5);
plot(data5);
grid on;
%% Close
fclose(fileID);
