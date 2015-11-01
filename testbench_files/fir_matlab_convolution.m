%% FILTER CONVOLUTION WITH MATLAB (TO COMPARE WITH TESTBENCH)
clear;

%file_path='./inputs/fir/';
file_path='./outputs/cic+fir/';
%file_prefix='fir_input_';
file_prefix='cic_output_';
file_ext='.txt';

FIR_MSB_OUT = 34;
coef = [-7,-31,-12,-10,2,13,17,13,0,-15,-24,-21,-5,15,31,32,14,-13,-37,-44,-27,7,40,57,44,4,-41,-70,-63,-22,37,82,86,45,-26,-89,-111,-74,8,93,135,109,21,-87,-158,-149,-59,72,176,193,108,-44,-184,-238,-167,1,181,279,233,59,-162,-314,-308,-135,124,337,384,228,-63,-344,-460,-337,-23,327,528,459,137,-282,-582,-591,-281,204,616,728,456,-84,-619,-864,-661,-84,583,990,894,308,-495,-1098,-1157,-594,340,1176,1449,960,-99,-1209,-1773,-1426,-261,1180,2140,2037,797,-1051,-2576,-2889,-1632,757,3156,4229,3100,-108,-4131,-6932,-6504,-1745,6922,17517,27093,32767,32767,27093,17517,6922,-1745,-6504,-6932,-4131,-108,3100,4229,3156,757,-1632,-2889,-2576,-1051,797,2037,2140,1180,-261,-1426,-1773,-1209,-99,960,1449,1176,340,-594,-1157,-1098,-495,308,894,990,583,-84,-661,-864,-619,-84,456,728,616,204,-281,-591,-582,-282,137,459,528,327,-23,-337,-460,-344,-63,228,384,337,124,-135,-308,-314,-162,59,233,279,181,1,-167,-238,-184,-44,108,193,176,72,-59,-149,-158,-87,21,109,135,93,8,-74,-111,-89,-26,45,86,82,37,-22,-63,-70,-41,4,44,57,40,7,-27,-44,-37,-13,14,32,31,15,-5,-21,-24,-15,0,13,17,13,2,-10,-12,-31,-7];
%close all;
for freq=[11000];%[1000 10000 11000 15000 22000 44000];
    filename=sprintf('%s%s%d%s',file_path,file_prefix,freq,file_ext);
    fd=fopen(filename);
    leido = fscanf(fd,'%16c\n'); %lee todo de corrido
    fclose(fd);
    leido2 = vec2mat(leido,16); %separa en filas de 16 bits
    input_uint16=typecast(uint16(bin2dec(leido2)),'uint16'); %convierte a ca2
    input=double(input_uint16)-2^15; %necesario convertir a double para convolución
    output=conv(input,coef);
    output=output(length(coef):length(output)-length(coef));
    output=output/2^(FIR_MSB_OUT-15);
    figure();
    tit=sprintf('Frequency: %d Hz', freq);
    set(gcf,'name',tit,'numbertitle','off');
    subplot(511);
    %stem(input);
    plot(input);
    grid on;
    subplot(512);
    plot(abs(fft(input)));
    grid on;
    subplot(513);
    stem(coef);
    grid on;
    subplot(514);
    plot(output);
    grid on;
    subplot(515);
    plot(abs(fft(output)));
    grid on;
    pause(0.3);
end
