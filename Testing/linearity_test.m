function [ ] = linearity_test(  )
    fgen = gen_open('10.128.3.199');
    
    discard = 50;
    
    for offset = 1.6:0.01:1.75
        fprintf('Offset:%f\n',offset);
        conf = gen_config(fgen,'type','dc','offset',offset,'state','on');
        pause(0.1);
        
        file_name = './measures/DCv2/measures.bin';
        header_name = ['./measures/DCv2/offset_' num2str(offset) '.mat'];
        measures = adc_get(file_name,1000+discard);
        measures = measures(discard:numel(measures));
        save(header_name,'measures','conf');
        plot(measures);
    end
    
    fclose(fgen);
    
end

