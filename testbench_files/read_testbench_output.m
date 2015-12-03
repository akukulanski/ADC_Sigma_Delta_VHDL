%% READ OUTPUTS FROM TESTBENCHS
Fs=90.6e6/2/512;
Ts=1/Fs;

path_fir='./outputs/fir/'; %_001/
path_cic_fir='./outputs/cic+fir/';
name_fir='fir_output_';
name_cic_fir='cic_fir_output_';

path=path_cic_fir;
name_prefix=name_cic_fir;
name_ext='.txt';

freq_vector=[1000 2000 4000 8000 8500 9000 9500 10000 11000];%[1000,10000,11000,15000,22000];
%freq_vector=[11000];
close all;
for freq=freq_vector;
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
    
   
    %out=out(300:400);
    x=0:Ts:Ts*(numel(out)-1);

    figure();
    tit=sprintf('Frequency: %d Hz', freq);
    set(gcf,'name',tit,'numbertitle','off');
    %stem(out);
    subplot(211);
    plot(x,out);
    xlabel('Time [s]');
    %ylimits([-32768 32767]);
    ylim([-32768 32767]);
    grid on;
    subplot(212);
    plot(abs(fft(out)));
    grid on;    
end
