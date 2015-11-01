%% READ INPUTS OF FIR TESTBENCH

path_fir='./inputs/fir/';
%path_cic_fir='./outputs/cic+fir/';
name_fir='fir_input_';
%name_cic_fir='cic_output_';

path=path_fir;
name_prefix=name_fir;
name_ext='.txt';

close all;
figure();
for freq=1000:1000:30000;
    filename = sprintf('%s%s%d%s',path,name_prefix, freq, name_ext);
    fd = fopen(filename);
    if fd<3
        fprintf(1,'Error. No existe el archivo: %s\n',filename);
        continue
    end
    frewind(fd)
    leido = fscanf(fd,'%16c\n'); %lee todo de corrido
    fclose(fd);
    leido2 = vec2mat(leido,16); %separa en filas de 16 bits
    input_int16=typecast(uint16(bin2dec(leido2)),'int16'); %convierte a ca2
    input=double(input_int16); %necesario para imprimir en matlab
    tit=sprintf('Frequency: %d Hz', freq);
    set(gcf,'name',tit,'numbertitle','off');
    %stem(out);
    subplot(211);
    plot(input);
    grid on;
    subplot(212);
    plot(abs(fft(input)));
    grid on;
    pause(0.1);
end