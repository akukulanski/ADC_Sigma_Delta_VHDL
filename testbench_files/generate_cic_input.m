path='./inputs/cic+fir/'
file_prefix='cic_input_';
file_ext='.txt';

for fin=[12000];%[1000,10000,11000,15000];
    filename=sprintf('%s%s%d%s',path,file_prefix,fin,file_ext);
    TAPS=256;
    fclk = 90.6e6/2; % Frecuencia de clk
    time = 5/fin+2*TAPS/fclk+5000e-6; % Tiempo de simulacion
    dt = (1/fclk)/5; % Paso de la simulacion analogica
    func = @(t) 3.3/2 + 2.6/2 *sin(2*pi*fin*t) + 0.0 * rand(1,numel(t)); % Input
    R1 = 150e3;
    R2 = 150e3;
    C = .1e-9;

    Vth = 1.65;
    Vhist = 0.0;   % Histeresis        

    %filtrado con el cic
    sig_delt = sigma_delta_modulator(func,fclk,dt,time,R1,R2,C,Vth,Vhist);

    fd=fopen(filename,'w');

    for i=1:1:numel(sig_delt);
        fprintf(fd,'%d\n',int16(sig_delt(i)));
    end

    fclose(fd);
end;