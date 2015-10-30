%% Global variable
fileExec = '/home/ariel/git/vhdl-adc/testbench_files/tempPAUNOGATO';

%% GENERATING SINUSOIDAL INPUTS

Fs=90.6e6/512/2;
Ts=1/Fs;
A=1000; %2^16

% Fs_clk_fast = 90.6/2 MHz = 45.3  MHz
% Fs_out = 22KHz
% Dec = 4
% Fs_in = 88 KHz
% Fc = 0.25 * Fs_in/2 = 11 KHz  % Normalizado a 1/4
% Testear en Fin>=11KHz

for fin=1000:1000:30000;
    t=0:Ts:5/fin;
    input = A*sin(2*pi*fin*t);
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

for fin=1000:1000:30000;
    filename=sprintf('./inputs/fir_input_%d.txt',fin);
    exec=[];
    exec=sprintf('%s %s',fileExec, filename);
    [status, ~] = system(exec);
    filename2=sprintf('./inputs/fir_input_%d_int16.txt',fin);
    fd=fopen(filename2);
    frewind(fd)
    out = fread(fd,'int16')
    stem(out);
    %plot(out);
    grid on;
    fclose(fd);
    pause(0.1);
end

%% CHECKING FIR INPUT SIGNAL
figure();
freq = 15000;
temp = [];
filename=sprintf('./inputs/fir_input_%d.txt',freq);
exec=[];
exec=sprintf('%s %s',fileExec, filename);
[status, ~] = system(exec);
filename2=sprintf('./inputs/fir_input_%d_int16.txt',freq);
fd=fopen(filename2);
frewind(fd)
out = fread(fd,'int16')
stem(out);
%plot(out);
grid on;
fclose(fd);

%% READING TESTBENCH OUTPUTS
figure();
freq = 15000;
temp = [];
filename=sprintf('./outputs/fir_output_%d.txt', freq);
exec=sprintf('%s %s', fileExec, filename);
[status, ~] = system(exec);
filename2=sprintf('./outputs/fir_output_%d_int16.txt', freq);
fd=fopen(filename2);
frewind(fd)
out = fread(fd,'int16')
stem(out);
%plot(out);
grid on;
fclose(fd);