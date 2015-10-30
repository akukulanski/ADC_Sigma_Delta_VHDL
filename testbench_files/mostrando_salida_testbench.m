
%ff=fopen('/home/ariel/git/vhdl-adc/vhdl/cic/output_CIC_int16.txt')
%ff=fopen('/home/ariel/git/vhdl-adc/testbench_files/outputs/fir_out_1000_int16.txt')
ff=fopen('/home/ariel/git/vhdl-adc/testbench_files/outputs/fir_out_20000_int16.txt')
%ff=fopen('/home/ariel/git/vhdl-adc/testbench_files/inputs/fir_1000_int16.txt')
frewind(ff)
out = fread(ff,'int16')
stem(out);
%plot(out);
grid on;

fclose(ff);%/home/ariel/git/vhdl-adc/testbench_files/outputs/fir_out_1000.txt