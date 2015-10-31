%% Global variables
fileExec = '/home/ariel/git/vhdl-adc/testbench_files/tempPAUNOGATO';
coef = [-7,-31,-12,-10,2,13,17,13,0,-15,-24,-21,-5,15,31,32,14,-13,-37,-44,-27,7,40,57,44,4,-41,-70,-63,-22,37,82,86,45,-26,-89,-111,-74,8,93,135,109,21,-87,-158,-149,-59,72,176,193,108,-44,-184,-238,-167,1,181,279,233,59,-162,-314,-308,-135,124,337,384,228,-63,-344,-460,-337,-23,327,528,459,137,-282,-582,-591,-281,204,616,728,456,-84,-619,-864,-661,-84,583,990,894,308,-495,-1098,-1157,-594,340,1176,1449,960,-99,-1209,-1773,-1426,-261,1180,2140,2037,797,-1051,-2576,-2889,-1632,757,3156,4229,3100,-108,-4131,-6932,-6504,-1745,6922,17517,27093,32767,32767,27093,17517,6922,-1745,-6504,-6932,-4131,-108,3100,4229,3156,757,-1632,-2889,-2576,-1051,797,2037,2140,1180,-261,-1426,-1773,-1209,-99,960,1449,1176,340,-594,-1157,-1098,-495,308,894,990,583,-84,-661,-864,-619,-84,456,728,616,204,-281,-591,-582,-282,137,459,528,327,-23,-337,-460,-344,-63,228,384,337,124,-135,-308,-314,-162,59,233,279,181,1,-167,-238,-184,-44,108,193,176,72,-59,-149,-158,-87,21,109,135,93,8,-74,-111,-89,-26,45,86,82,37,-22,-63,-70,-41,4,44,57,40,7,-27,-44,-37,-13,14,32,31,15,-5,-21,-24,-15,0,13,17,13,2,-10,-12,-31,-7];


%% GENERATING SINUSOIDAL INPUTS

Fs=90.6e6/512/2;
Ts=1/Fs;
A=10000; %2^16

% Fs_clk_fast = 90.6/2 MHz = 45.3  MHz
% Fs_out = 22KHz
% Dec = 4
% Fs_in = 88 KHz
% Fc = 0.25 * Fs_in/2 = 11 KHz  % Normalizado a 1/4
% Testear en Fin>=11KHz
taps=256;
halftaps=taps/2;
for fin=1000:1000:30000;
    %t=0:Ts:50/fin;
    t=0:Ts:5/fin+taps*Ts;
    input = A*sin(2*pi*fin*(t-halftaps*Ts));
    temp=[];
    temp=sprintf('%s%d%s', './inputs/fir_input_', fin, '.txt');
    fd=fopen(temp, 'wb');
    %fd=fprintf('%s\n', dec2bin(input,16));
    for i=1:1:numel(t);
        fprintf(fd,'%s\n', dec2bin(typecast(int16(input(i)),'uint16'),16));%,16));
    end
    fclose(fd);
end

%% CONVERTING TO PLOT (only to check what was generated)
%exec = ['./uart_rx -p 16 -bd 460800 -numsamples ' num2str(nsamples) ' -to 30 -filename ' file_name];
%[status, ~] = system(exec);
figure();
for fin=1000:1000:30000;
    filename=sprintf('./inputs/fir_input_%d.txt',fin);
    exec=[];
    exec=sprintf('%s %s',fileExec, filename);
    [status, ~] = system(exec);
    filename2=sprintf('./inputs/fir_input_%d_int16.txt',fin);
    fd=fopen(filename2);
    frewind(fd)
    out = fread(fd,'int16')
    fclose(fd);
    %stem(out);
    subplot(211);
    plot(out);
    grid on;
    subplot(212);
    plot(abs(fft(out)));
    grid on;
    pause(0.1);
end

%% CHECKING FIR INPUT SIGNAL
freq = 1000;
temp = [];
filename=sprintf('./inputs/fir_input_%d.txt',freq);
exec=[];
exec=sprintf('%s %s',fileExec, filename);
[status, ~] = system(exec);
filename2=sprintf('./inputs/fir_input_%d_int16.txt',freq);
fd=fopen(filename2);
frewind(fd)
out = fread(fd,'int16')
fclose(fd);
figure();
%stem(out);
subplot(211);
plot(out);
grid on;
subplot(212);
plot(abs(fft(out)));
grid on;

%% READING TESTBENCH OUTPUTS
figure();
freq = 10000;	
temp = [];
filename=sprintf('./outputs/fir_output_%d.txt', freq);
%filename=sprintf('./outputs/fir_output_TEST.txt');
exec=sprintf('%s %s', fileExec, filename);
[status, ~] = system(exec);
filename2=sprintf('./outputs/fir_output_%d_int16.txt', freq);
%filename2=sprintf('./outputs/fir_output_TEST_int16.txt');
fd=fopen(filename2);
frewind(fd)
out = fread(fd,'int16')
fclose(fd);
figure();
%stem(out);
subplot(211);
plot(out);
grid on;
subplot(212);
plot(abs(fft(out)));
grid on;

%% SEÑAL RAMPA GENERACION
cant = 1023;
t=0:1:cant;
temp=sprintf('%s%d%s', './inputs/fir_input_rampa.txt');
fd=fopen(temp, 'wb');
for i=0:1:numel(t);
    fprintf(fd,'%s\n', dec2bin(typecast(int16(i),'uint16'),16));
end
fclose(fd);

%% SALIDA SEÑAL RAMPA LECTURA
figure();
filename=sprintf('./outputs/fir_output_rampa.txt');
exec=sprintf('%s %s', fileExec, filfclose(fd);ename);
[status, ~] = system(exec);
filename2=sprintf('./outputs/fir_output_rampa_int16.txt');
fd=fopen(filename2);
frewind(fd)
out = fread(fd,'int16')
fclose(fd);
stem(out);
grid on;


%% CHECK FILTER CONVOLUTION WITH MATLAB
freq = 10000;
temp = [];
filename=sprintf('./inputs/fir_input_%d.txt',freq);
exec=[];
exec=sprintf('%s %s',fileExec, filename);
[status, ~] = system(exec);
filename2=sprintf('./inputs/fir_input_%d_int16.txt',freq);
fd=fopen(filename2);
frewind(fd)
input = fread(fd,'int16')
fclose(fd);
figure();
subplot(511);
%stem(input);
plot(input);
grid on;
subplot(512);
plot(abs(fft(input)));
grid on;
output=conv(input,coef);
subplot(513);
stem(coef);
grid on;
subplot(514);
plot(output);
grid on;
subplot(515);
plot(abs(fft(output)));
grid on;

