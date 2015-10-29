function [ ] = oscope_test()
    fgen = gen_open('10.128.4.143');
    gen_config(fgen,'type','sin','offset',1.65,'vpp',3.3,'state','on','freq',33);
       
    
    while(1)
        pause(0.5);
        
        file_name = './measures.bin';
        
        measures = adc_get(file_name,1000);
        
        plot(measures);
    end
    
    fclose(fgen);
    
end

