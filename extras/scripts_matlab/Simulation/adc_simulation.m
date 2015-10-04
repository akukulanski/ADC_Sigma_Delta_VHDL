function [ cic_out ] = adc_simulation( )
        close all; 
        fclk = 90.6e6; % Frecuencia de clk
        time = 3000e-6; % Tiempo de simulacion
        dt = (1/fclk)/30; % Paso de la simulacion analogica
        func = @(t) 3.3/2 + 2.6/2 *sin(2*pi*1000*t) + 0.01 * rand(1,numel(t)); % Input
        R1 = 2.2e3;
        R2 = 2e3;
        C = 2.2e-9;
        
        Vth = 1.5;
        Vhist = 0.03;   % Histeresis        
        
        %filtrado con el cic
        sig_delt = sigma_delta_modulator(func,fclk,dt,time,R1,R2,C,Vth,Vhist);
        cic_out = cic(sig_delt);
        res_cic = cic_out.int;
        
        %coeficientes fir
        hz=[0,-1,-1,0,0,1,1,1,-1,-2,-3,-1,1,4,5,3,-2,-7,-8,-4,3,10,12,6,-5,-15,-18,-10,7,22,26,14,-9,-31,-36,-20,12,42,50,27,-16,-56,-67,-37,20,73,88,50,-25,-94,-114,-66,30,119,146,85,-36,-150,-185,-109,42,186,231,139,-50,-229,-287,-175,57,279,353,218,-65,-338,-432,-270,73,406,525,333,-81,-487,-635,-410,88,581,767,502,-96,-693,-926,-616,101,827,1119,756,-106,-990,-1359,-934,108,1193,1664,1165,-106,-1457,-2070,-1480,96,1815,2637,1934,-74,-2341,-3503,-2660,16,3201,5011,4013,150,-4927,-8404,-7532,-1011,10156,22806,32767];
        %filtro fir(direct form)
        FIR_filter=dfilt.dffir(hz);
        %filtrado con fir
        res_fir = filter(FIR_filter,res_cic);
        %centro la respuesta del fir
        res_fir = double(res_fir);
        res_fir = res_fir - mean(res_fir);
        
        %cenctro la respuesta del cic
        res_cic = double(res_cic);
        res_cic = res_cic - mean(res_cic);
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
        ts = 1/(fclk/256);
        t = ts*(0:N-1);
        
        per_sig = abs(fft(res_cic)).^2/N;
        fs = fclk/256;
        f = 0:fs/N:(N-1)*fs/N;
        
        figure;
        a(1) = subplot(211);
        plot(t,res_cic);
        title('Cic Output');
        a(2) = subplot(212);
        plot(f,db(per_sig/max(per_sig)));
        
        
        % FIR Output
        
        N= numel(res_fir);
        ts = 1/(fclk/256);
        t = ts*(0:N-1);
        
        per_sig = abs(fft(res_fir)).^2/N;
        fs = fclk/256;
        f = 0:fs/N:(N-1)*fs/N;
        
        figure;
        a(1) = subplot(211);
        plot(t,res_fir);
        title('Fir Output');
        a(2) = subplot(212);
        plot(f,db(per_sig/max(per_sig)));
end

