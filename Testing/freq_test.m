function [  ] = freq_test(  )
    fgen = gen_open('10.128.4.143');
    periodos_min = 40;
    trans = 100;
    
    pause(2);
    
    fs = 44250.48767/2;
    
    for freq = logspace(1,log10(11e3),100);
        conf=  gen_config(fgen,'type','sin','offset',1.65,'vpp',3,'freq',freq,'state','on');
        
        n = periodos_min * (fs/freq); 
        
        while (n < 1000)
           n = n + fs/freq 
        end
        
        pause(0.5);
        
        file_name = './measures/SIN_FullTest2/measures.bin';
        header_name = ['./measures/SIN_FullTest2/freq_' num2str(freq) '.mat'];
        
        measures = adc_get(file_name,n + trans);
        measures = measures(trans:n + trans);
        save(header_name,'measures','conf');
        plot(db(abs(fft(measures))));
    end
    
    fclose(fgen);
end

