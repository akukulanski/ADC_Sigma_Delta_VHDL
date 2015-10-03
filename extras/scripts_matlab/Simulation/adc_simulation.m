function [ cic_out ] = adc_simulation( )
        close all; 
        fclk = 90.6e6; % Frecuencia de clk
        time = 1000e-6; % Tiempo de simulacion
        dt = (1/fclk)/30; % Paso de la simulacion analogica
        func = @(t) 3.3/2 + 3.3/2 *sin(2*pi*1000*t) + 0.01 * rand(1,numel(t)); % Input
        R1 = 2e3;
        R2 = 2e3;
        C = 2.2e-9;
        
        wo = 1/(C*(R1+R2))  % Frecuencia de corte, filtro analogico
        Vth = 3.3/2;   
        Vhist = 0.03;   % Histeresis        
        
        sig_delt = sigma_delta_modulator(func,fclk,dt,time,R1,R2,C,Vth,Vhist);
        cic_out = cic(sig_delt);
        res = cic_out.int;
        res = double(res);
        
        res = res - mean(res);
        
        
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
        
        N= numel(res);
        ts = 1/(fclk/256);
        t = ts*(0:N-1);
        
        per_sig = abs(fft(res)).^2/N;
        fs = fclk/256;
        f = 0:fs/N:(N-1)*fs/N;
        
        figure;
        a(1) = subplot(211);
        plot(t,res);
        title('Cic Output');
        a(2) = subplot(212);
        plot(f,db(per_sig/max(per_sig)));
        
     
end

