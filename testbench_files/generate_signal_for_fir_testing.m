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
    temp=sprintf('%s%d%s', '/home/ariel/git/vhdl-adc/testbench_files/inputs/fir_input_', fin, '.txt');
    fd=fopen(temp, 'wb');
    %fd=fprintf('%s\n', dec2bin(input,16));
    for i=1:1:numel(t);
        fprintf(fd,'%s\n', dec2bin(typecast(int16(input(i)),'uint16'),16));%,16));
    end
    fclose(fd);
end
