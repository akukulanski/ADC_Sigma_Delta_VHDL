Fs=90.6e6/512/2;
Ts=1/Fs;
A=1000;

for fin=1000:1000:30000;
    t=0:Ts:5/fin;
    %input = 2^16-A*sin(2*pi*fin*t);
    input = A*sin(2*pi*fin*t);
    temp=[];
    temp=sprintf('%s%d%s', '/home/ariel/git/vhdl-adc/testbench_files/inputs/fir_', fin, '.txt');
    fd=fopen(temp, 'wb');
    %fd=fprintf('%s\n', dec2bin(input,16));
    for i=1:1:numel(t);
        fprintf(fd,'%s\n', dec2bin(typecast(int16(input(i)),'uint16'),16));%,16));
    end
    fclose(fd);
end


%input = A * sin(2*pi*fin/Fs*