library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes.all;
use std.textio.all;

entity cic_fir_files_TB is
end entity cic_fir_files_TB;

architecture RTL of cic_fir_files_TB is
	--constant T_clk : natural := 20; -- periodo clock en ns
	
	signal clk,rst,ce,oe: std_logic;
	signal input: std_logic;
	signal output: std_logic_vector(FIR_OUTPUT_BITS-1 downto 0);

-- LEVANTAR ARCHIVO
	procedure str2sv(s : in string; sv : out std_logic_vector) is
		variable i : integer;
	begin
		for i in s'range loop
			case s(i) is
				when 'U'    => sv(i - 1) := 'U';
				when 'X'    => sv(i - 1) := 'X';
				when '0'    => sv(i - 1) := '0';
				when '1'    => sv(i - 1) := '1';
				when 'Z'    => sv(i - 1) := 'Z';
				when 'W'    => sv(i - 1) := 'W';
				when 'L'    => sv(i - 1) := 'L';
				when 'H'    => sv(i - 1) := 'H';
				when '-'    => sv(i - 1) := '-';
				when others =>
					report "Elemento desconocido" severity failure;
			end case;
		end loop;
	end procedure str2sv;

	procedure read(l : inout line; v : out std_logic_vector) is
		variable s : string(v'length downto 1);
	begin
		read(l, s);
		str2sv(s, v);
	end procedure read;

	-- escritura de std_logic
	procedure write(l : inout line; v : in std_logic) is
		variable s : string(3 downto 1);
	begin
		s := std_logic'image(v);
		write(l, s(2));
	end procedure write;

	-- escritura de std_logic_vector
	procedure write(l : inout line; v : in std_logic_vector) is
		variable i : integer;
		variable s : string(3 downto 1);
	begin
		for i in v'range loop
			s := std_logic'image(v(i));
			write(l, s(2));
		end loop;
	end procedure write;

-- FIN LEVANTAR ARCHIVO

-- Un periodo de reloj arbitrario
	constant PERI_CLK : time := 10 ns;

	-- Se�ales basicas
	signal detener : boolean := false;


-- Constantes de generics en package en archivo constantes.vhd
begin
	gen_reloj : process
	begin
		clk <= '1', '0' after PERI_CLK / 2;
		wait for PERI_CLK;
		if detener then
			wait;
		end if;
	end process gen_reloj;

	--rst <= '1', '0' after PERI_CLK * 3 / 2;

-- FIR NUESTROOOOOOOOOOOOOOOO
	tb: entity work.cic_fir
		generic map(
			N_ETAPAS => CIC_N_ETAPAS,
			COMB_DELAY => CIC_COMB_DELAY, --delay restador
		    CIC_R => CIC_R, --decimacion
		    COEFF_BITS => FIR_COEFF_BITS,
		    FIR_R => 1,--FIR_R, --decimacion
		    N_DSP => DSP_INPUT_BITS, --entrada dsp específico para spartan6
		    M_DSP => DSP_OUTPUT_BITS, --salida dsp específico para spartan6
		    FIR_HALF_TAPS => FIR_HALF_TAPS
		)
		port map(
			input  => input,
			output => output,
			clk    => clk,
			rst    => rst,
			oe     => oe
		);
-- FIN FIR NUESTROOOOOOOOOOOOOOOOOo		


process_read : process
		variable l : line;
		-- Reemplazar Nombre por el archivo a usar
		file f_in : text open read_mode is "/home/ivan/codigo vhdl/ADC/testbench_files/inputs/cic+fir/cic_input_10000.txt";
		--file f_in : text open read_mode is "/home/ariel/git/vhdl-adc/testbench_files/inputs/cic+fir/cic_input_10000.txt";
		-- En este ejemplo solo hay un std_logic_vector por linea
		variable leido : std_logic_vector(0 downto 0);
		variable cr: integer :=0;
	begin
		rst <= '1';
		input<='0';
		wait for 2*PERI_CLK;
		rst<= '0';
		wait until rst = '0';
		report "Comenzando la lectura de archivos" severity note;
		ce<='1';
		wait for 1 ps;

		while not (endfile(f_in)) loop
			wait until rising_edge(clk);
			readline(f_in, l);
			read(l, leido);
			cr:=cr+1;
			input <= leido(0);
		end loop;
		wait for PERI_CLK*1000000;
		report "TERMINO LECTURA!!" severity note;
		wait;
	end process process_read;
	
process_write: process
		variable l : line;
		file f_out : text open write_mode is "/home/ivan/codigo vhdl/ADC/testbench_files/outputs/cic+fir/cic_fir_output_10000.txt";
		--file f_out : text open write_mode is "/home/ariel/git/vhdl-adc/testbench_files/outputs/cic+fir/cic_fir_output_10000.txt";
		variable cw: integer :=0;
	begin
		report "Comenzando la escritura de archivos" severity note;
		loop
			wait until rising_edge(clk);
			--wait until oe ='1';
			if oe = '1' then
				cw:=cw+1;
				--if(cw > 2*FIR_HALF_TAPS) then
					write(l, output);
					writeline(f_out, l);
					report "ESCRIBIO LINEA." severity note;
				--end if;
			end if;
			wait for PERI_CLK;
		end loop;
	end process process_write;
end architecture;