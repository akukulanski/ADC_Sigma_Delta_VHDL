%% READ OUTPUTS FROM TESTBENCHS

path_fir='./outputs/fir/'; %_001/
path_cic_fir='./outputs/cic+fir/';
name_fir='fir_output_';
name_cic_fir='cic_output_';

path=path_fir;
name_prefix=name_fir;
name_ext='.txt';

close all;
for freq=[1000,10000,11000,15000];
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
    out_int16=typecast(uint16(bin2dec(leido2)),'int16'); %convierte a ca2
    out=double(out_int16);
    figure();
    tit=sprintf('Frequency: %d Hz', freq);
    set(gcf,'name',tit,'numbertitle','off');
    %stem(out);
    subplot(211);
    plot(out);
    grid on;
    subplot(212);
    plot(abs(fft(out)));
    grid on;
end