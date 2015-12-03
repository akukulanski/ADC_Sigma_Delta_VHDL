function [ a ] = get_adc( file_name , nsamples )
    
    if (nargin <1)
        file_name = 'prueba.bin'
    end
    
    %exec = ['./uart_rx -p 16 -bd 460800 -numsamples ' num2str(nsamples) ' -to 30 -filename ' file_name];
    exec = ['./uart_rx -p 16 -bd 921600 -numsamples ' num2str(nsamples) ' -to 30 -filename ' file_name];
    
    [status, ~] = system(exec);
    
    fd = fopen(file_name);
    a = fread(fd,'int16');
    fclose(fd);
    
end

