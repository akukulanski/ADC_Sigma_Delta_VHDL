%% GENERATING SINUSOIDAL INPUTS

path_fir='./inputs/fir/';
name_fir='fir_input_';
path=path_fir;
name_prefix=name_fir;
name_ext='.txt';

Fsmax=90.6e6;
Fs=Fsmax/2/512; % Fs_input_fir=88KHz (/2 por pll)(/512 por decim cic)
Ts=1/Fs;
A=10000; %da salida de amplitud aprox 3000
TAPS=256;
% Dec = 4
% Fc = 0.25 * Fs_input/2 = 11 KHz  % Normalizado a 1/4
HALFTAPS=TAPS/2;

for freq=1000:1000:30000;
    t=0:Ts:10/freq+TAPS*Ts; %10 períodos + tamaño filtro
    input = A*sin(2*pi*freq*(t-HALFTAPS*Ts));
    temp=[];
    filename = sprintf('%s%s%d%s',path,name_prefix, freq, name_ext);
    fd=fopen(filename, 'wb');
    for i=1:1:numel(t);
        fprintf(fd,'%s\n', dec2bin(typecast(int16(input(i)),'uint16'),16));
    end
    fclose(fd);
end