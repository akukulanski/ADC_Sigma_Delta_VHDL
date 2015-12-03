function [ ] = linearity_test(  )
    fgen = gen_open('10.128.4.143');
    
    discard = 50;
    
    pause(2);
    for offset = 0:0.1:3.3
        fprintf('Offset:%f\n',offset);
        conf = gen_config(fgen,'type','dc','offset',offset,'state','on');
        pause(0.1);
        
        file_name = './measures/DC_FullTest3_45k/measures.bin';
        header_name = ['./measures/DC_FullTest3_45k/offset_' num2str(offset) '.mat'];
        measures = adc_get(file_name,1000+discard);
        measures = measures(discard:numel(measures));
        save(header_name,'measures','conf');
        plot(measures);
    end
    
    fclose(fgen);
    
end

