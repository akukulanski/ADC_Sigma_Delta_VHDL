function [  ] = freq_test(  )
    fgen = gen_open('10.128.3.199');
        
    for freq = 10e3:1e3:60e3
        conf=  gen_config(fgen,'type','sin','offset',1.65,'vpp',3.3,'freq',freq,'state','on');
        
        pause(2);
        
        file_name = './measures/SINv2/measures.bin';
        header_name = ['./measures/SINv2/freq_' num2str(freq) '.mat'];
        
        measures = adc_get(file_name,1050);
        measures = measures(50:1050);
        save(header_name,'measures','conf');
        plot(db(abs(fft(measures))));
    end
    
    fclose(fgen);
end

