function [] = adc_simulation( )
        close all; 
        clear;
        
        %% A que frecuencias simular
        frec_vec=[1000,4000,8000,9000,10000,11000,22000];
        %frec_vec=[1000,4000,8000,9000,10000,11000];
        %% Parámetros del modulador 
        fclk = 90.6e6/2; % Frecuencia de clk
        time = 10000e-6; % Tiempo de simulacion
        dt = (1/fclk)/5; % Paso de la simulacion analogica
        R1 = 150e3;
        R2 = 150e3;
        C = .1e-9;
        
        Vth = 1.65;
        Vhist = 0.0;   % Histeresis
        
        %% Parámetros fiteo
        fit_t = fittype('sin1');
        
        %% Comienza for
        for frec=frec_vec
        close all;    
        func = @(t) 3.3/2 + 3.3/2 *sin(2*pi*frec*t) + 0.0 * rand(1,numel(t)); % Input

        %% Simulación del Modulador
        %filtrado con el cic
        sig_delt = sigma_delta_modulator(func,fclk,dt,time,R1,R2,C,Vth,Vhist);
        
        %% Simulación del filtro cic
        cic_out = cic(sig_delt);
        res_cic = cic_out.int;
        
        % lo que sigue imita lo que hicimos en la fpga para dejar en ca2
        % y aprovechando full scale
        res_cic(res_cic == 2^16)= 2^16-1; % la unica salida que usa los 17 bits
        % 10000000000000000 pasa a ser 1111111111111111
        res_cic = bitxor(res_cic,2^15);  % invierto bit 16 (pasa de bin desplazado a Ca2)
        res_cic = typecast(uint16(res_cic),'int16'); % dejar esto así
        % lo que hace es dejar los bits como estan y pasarlo a interpretar
        % como int16 (antes era int32). NO modificar.
        
        %% Simulación del FIR
        
        %coeficientes fir (filtro que ecualiza a respuesta CIC hecho por
        %ventaneo con ventana keiser beta=9 y pasados coeficientes a 16 bits)
        hz= [0,0,0,-1,-1,-1,0,2,2,2,1,-2,-4,-4,-3,1,5,8,7,2,-6,-11,-12,-7,3,14,20,17,4,-13,-26,-29,-17,6,29,42,35,10,-25,-53,-58,-35,10,56,81,69,20,-46,-98,-107,-65,16,100,144,123,37,-78,-168,-185,-113,24,165,241,206,66,-123,-273,-304,-188,33,261,385,332,111,-189,-426,-478,-301,42,399,596,520,181,-279,-649,-736,-472,50,598,907,802,293,-409,-981,-1129,-738,54,900,1392,1251,481,-608,-1517,-1780,-1196,46,1412,2247,2074,849,-964,-2553,-3102,-2181,-12,2543,4285,4191,1922,-1896,-5759,-7762,-6303,-755,8159,18463,27498,32767];
        hz= [hz,fliplr(hz)];
        %filtro fir(direct form)
        res_cic = double(res_cic);
        res_fir=conv(res_cic,hz);
        res_fir=res_fir(200:length(res_fir)-length(hz));
        res_fir= int64(res_fir/2^19);
        res_fir= double(res_fir);
        %res_fir = round(res_fir*(power(2,16-1)-1)/max(abs(res_fir)));
%         FIR_filter=dfilt.dffir(hz);
%         %filtrado con fir
%         res_fir = filter(FIR_filter,res_cic);
%         res_fir = round(res_fir*(power(2,16-1)-1)/max(abs(res_fir)));
%         %paso a double para fft y plotear
%         res_fir = double(res_fir);
%         res_cic = double(res_cic);
        %% Ploting Results %%
        
        t= 0:dt:time;
        signal = func(t);
        
        % Input Signal
        N = numel(signal);
        per_sig = abs(fft(signal)).^2/N;
        fs = 1/dt;
        f = 0:fs/N:(N-1)*fs/N;
        
        figure;
        subplot (211);
        plot(t,signal);
        title('Input Signal');
        subplot (212);
        plot(f,db(per_sig/max(per_sig)));

        % Sigma delta
        
        N= numel(sig_delt);
        ts = 1/fclk;
        t = ts*(0:N-1);
        
        per_sig = abs(fft(sig_delt)).^2/N;
        fs = fclk;
        f = 0:fs/N:(N-1)*fs/N;
        
        figure;
        a(1) = subplot(211);
        plot(t,sig_delt);
        title('Sigma delta Output');
        a(2) = subplot(212);
        plot(f,db(per_sig/max(per_sig)));
        
        
        % CIC Output
        
        N= numel(res_cic);
        ts = 1/(fclk/512);
        t = ts*(0:N-1);
        
        per_sig = abs(fft(res_cic)).^2/N;
        fs = fclk/512;
        f = 0:fs/N:(N-1)*fs/N;
        
        figure;
        a(1) = subplot(211);
        plot(t,res_cic);
        title('Cic Output');
        a(2) = subplot(212);
        plot(f,db(per_sig/max(per_sig)));
        
        
        % FIR Output
        %res_fir=res_fir(200:numel(res_fir));        %saco transitorios

        
        N= numel(res_fir);
        ts = 1/(fclk/512);
        t = ts*(0:N-1);
        
        per_sig = abs(fft(res_fir)).^2/N;
        fs = fclk/512;
        f = 0:fs/N:(N-1)*fs/N;
        
        figure;
        a(1) = subplot(211);
        plot(t,res_fir);
        title('Fir Output');
        a(2) = subplot(212);
        plot(f,db(per_sig/max(per_sig)));
        
        %% Fiteo de los resultados y calculo SNR
        
        %fiteo
        fit_curve = fit(t',res_fir,fit_t);
        %obtengo curva fiteada
        seno = fit_curve.a1*sin(fit_curve.b1*t+fit_curve.c1);
        %saco curva error
        e = res_fir'-seno;
        %ploteo
        figure();
        plot(t,res_fir,'-');
        hold on;
        plot(t,seno,'o');
        plot(t,e,'r');
        hold off;
        %calculo snr
        fprintf ('Freq: %f, SNR: %f,\n',fit_curve.b1/(2*pi),10*log10(sum((seno).^2)/sum((e).^2)));
        
        %% Fin del for
        end
end

