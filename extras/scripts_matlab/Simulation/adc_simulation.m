function [ cic_out ] = adc_simulation( )
        fclk = 90.6e6;
        time = 5000e-6;
        dt = (1/fclk)/20;
        func = @(t) 3.3/2 + 3.3/2 *sin(2*pi*20000*t);% + 0.01 * rand(1,numel(t));
        sig_delt = sigma_delta_modulator(func,fclk,dt,time);
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

