%% READ OUTPUTS FROM TESTBENCHS
clear;

path_fir='./outputs/fir/'; %_001/
path_cic_fir='./outputs/cic+fir/';
name_fir='fir_output_';
name_cic='cic_output_';

path=path_cic_fir;
name_prefix=name_fir;
name_ext='.txt';
%close all;
for freq=[11000];%[1000,10000,11000,15000,22000,44000];
    filename_cic = sprintf('%s%s%d%s',path,name_cic, freq, name_ext);
    filename_fir = sprintf('%s%s%d%s',path,name_fir, freq, name_ext);%['_direc',name_ext]);

    fd_cic = fopen(filename_cic);
    fd_fir = fopen(filename_fir);

    if fd_cic<3 
        fprintf(1,'Error. No existe el archivo: %s\n',filename_cic);
        continue
    end
    
        if fd_fir<3 
        fprintf(1,'Error. No existe el archivo: %s\n',filename_fir);
        continue
    end
    
    frewind(fd_cic)
    frewind(fd_fir)

    leido_cic = fscanf(fd_cic,'%16c\n'); %lee todo de corrido
    fclose(fd_cic);

    leido2_cic = vec2mat(leido_cic,16); %separa en filas de 16 bits
    out_int16_cic=typecast(uint16(bin2dec(leido2_cic)),'uint16'); %convierte a uint_16
    out_cic=double(out_int16_cic);
    figure();
    tit_cic=sprintf('CIC_OUT, Frequency: %d Hz', freq);
    set(gcf,'name',tit_cic,'numbertitle','off');
    %stem(out);
    subplot(211);
    plot(out_cic);
    grid on;
    subplot(212);
    plot(abs(fft(out_cic)));
    grid on;
    
    leido_fir = fscanf(fd_fir,'%16c\n'); %lee todo de corrido
    fclose(fd_fir);
    leido2_fir = vec2mat(leido_fir,16); %separa en filas de 16 bits
    out_int16_fir=typecast(uint16(bin2dec(leido2_fir)),'int16'); %convierte a ca2
    out_fir=double(out_int16_fir);
    figure();
    tit_fir=sprintf('FIR_OUT, Frequency: %d Hz', freq);
    set(gcf,'name',tit_fir,'numbertitle','off');
    %stem(out);
    subplot(211);
    plot(out_fir);
    grid on;
    subplot(212);
    plot(abs(fft(out_fir)));
    grid on;
end