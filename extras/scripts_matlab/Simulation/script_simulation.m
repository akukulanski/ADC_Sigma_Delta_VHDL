
close all; 
clear;
        
        %% A que frecuencias simular
    %frec_vec=[1000,2000,4000,8000,9000,10000,11000];
    frec_vec=[1000];
    %% Parámetros
    
    % SEÑAL
    Vefns=0.0; %ruido rms en señal

    % PARAMETROS FUNCION
    Vhist = 0.0;   % Histeresis
    fclk = 90.6e6/2; % Frecuencia de clk
    time = 10000e-6; % Tiempo de simulacion
    dt = (1/fclk)/5; % Paso de la simulacion analogica
    
    % FITEO
    fit_t = fittype('sin1');

    for frec= frec_vec;
        
        func = @(t) 3.3/2 + 3.3/2 *sin(2*pi*frec*t) + Vefns * rand(1,numel(t)); % Input
        [sig_delt,res_cic,res_fir] = adc_simulation(dt,time,fclk,func,Vhist);           
        
          %% Ploting Results %%
%         
%         t= 0:dt:time;
%         signal = func(t);
%         
%         % Input Signal
%         N = numel(signal);
%         per_sig = abs(fft(signal)).^2/N;
%         fs = 1/dt;
%         f = 0:fs/N:(N-1)*fs/N;
%         
%         figure;
%         subplot (211);
%         plot(t,signal);
%         title('Input Signal');
%         subplot (212);
%         plot(f,db(per_sig/max(per_sig)));
% 
% 
% 
% 
%         %% Sigma delta
%         
%         N= numel(sig_delt);
%         ts = 1/fclk;
%         t = ts*(0:N-1);
%         
%         per_sig = abs(fft(sig_delt)).^2/N;
%         fs = fclk;
%         f = 0:fs/N:(N-1)*fs/N;
%         
%         figure;
%         a(1) = subplot(211);
%         plot(t,sig_delt);
%         title('Sigma delta Output');
%         a(2) = subplot(212);
%         plot(f,db(per_sig/max(per_sig)));
% % Prueba de ploteo para presentacion (Usar el ploteo que esta dentro sigma_delta_modulator.m        
% %         N= numel(sig_delt);
% %         ts = 1/fclk;
% %         t = ts*(0:N-1);
% %         
% %         signal=func(t);
% %         per_sig = abs(fft(sig_delt)).^2/N;
% %         fs = fclk;
% %         f = 0:fs/N:(N-1)*fs/N;
% %         
% %         figure;
% %         title('Sigma delta Output');
% %         a(1) = subplot(311);
% %         plot(t,signal);
% %         xlabel('t[s]','FontSize',12,'FontWeight','bold');
% %         ylabel('Entrada[V]','FontSize',12,'FontWeight','bold');
% %         set(gca,'fontsize',12);
% %         a(2) = subplot(312);
% %         plot(t,sig_delt);
% %         xlabel('t[s]','FontSize',12,'FontWeight','bold');
% %         ylabel('Salida Mod.','FontSize',12,'FontWeight','bold');
% %         set(gca,'fontsize',12);
% %         subplot(313);
% %         plot(f/1e6,db(per_sig/max(per_sig)));
% %         xlabel('f[MHz]','FontSize',12,'FontWeight','bold');
% %         ylabel('Salida Mod.[dB]','FontSize',12,'FontWeight','bold');
% %         set(gca,'fontsize',12);
% %         linkaxes(a,'x');
% % 
% 
%         %% CIC Output
%         
%         N= numel(res_cic);
%         ts = 1/(fclk/512);
%         t = ts*(0:N-1);
%         
%         per_sig = abs(fft(res_cic)).^2/N;
%         fs = fclk/512;
%         f = 0:fs/N:(N-1)*fs/N;
%         
%         figure;
%         a(1) = subplot(211);
%         plot(t,res_cic);
%         title('Cic Output');
%         a(2) = subplot(212);
%         plot(f,db(per_sig/max(per_sig)));
%         
%         
%         %% FIR Output
%         %res_fir=res_fir(200:numel(res_fir));        %saco transitorios
% 
%         
%         N= numel(res_fir);
%         ts = 1/(fclk/512);
%         t = ts*(0:N-1);
%         
%         per_sig = abs(fft(res_fir)).^2/N;
%         fs = fclk/512;
%         f = 0:fs/N:(N-1)*fs/N;
%         
%         figure;
%         a(1) = subplot(211);
%         plot(t,res_fir);
%         title('Fir Output');
%         a(2) = subplot(212);
%         plot(f,db(per_sig/max(per_sig)));
%         
        %% Fiteo de los resultados y calculo SNR
        
        %fiteo
        N= numel(res_fir);
        ts = 1/(fclk/512);
        t = ts*(0:N-1);
        to_fit=res_fir;
        fit_curve = fit(t',to_fit,fit_t);
        %obtengo curva fiteada
        seno = fit_curve.a1*sin(fit_curve.b1*t+fit_curve.c1);
        %saco curva error
        e = to_fit'-seno;
        %ploteo
        figure();
        plot(t,to_fit,'-');
        hold on;
        plot(t,seno,'o');
        plot(t,e,'r');
        hold off;
        %calculo snr
        SNDR=10*log10(sum((seno).^2)/sum((e).^2));
        fprintf ('Freq: %f, SNR: %f, ENOB: %f\n',fit_curve.b1/(2*pi),SNDR,(SNDR-1.76)/6.02);
    end