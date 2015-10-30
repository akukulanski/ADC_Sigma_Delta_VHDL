% Salida CIC
%ff=fopen('/home/ariel/git/vhdl-adc/vhdl/cic/output_CIC_int16.txt')

% Entrada generada para el FIR
%ff=fopen('/home/ariel/git/vhdl-adc/testbench_files/inputs/fir_1000_int16.txt')
%ff=fopen('/home/ariel/git/vhdl-adc/testbench_files/inputs/fir_22000_int16.txt')
ff=fopen('/home/ariel/git/vhdl-adc/testbench_files/inputs/fir_input_13000_int16.txt')

% Salida FIR
%ff=fopen('/home/ariel/git/vhdl-adc/testbench_files/outputs/fir_out_1000_int16.txt')
%ff=fopen('/home/ariel/git/vhdl-adc/testbench_files/outputs/fir_out_20000_int16.txt')
ff=fopen('/home/ariel/git/vhdl-adc/testbench_files/outputs/fir_output_13000_int16.txt')

frewind(ff)
out = fread(ff,'int16')
stem(out);
%ff=fopen('/home/ariel/git/vhdl-adc/testbench_files/inputs/fir_1000_int16.txt')
%plot(out);
grid on;

fclose(ff);%/home/ariel/git/vhdl-adc/testbench_files/outputs/fir_out_1000.txt