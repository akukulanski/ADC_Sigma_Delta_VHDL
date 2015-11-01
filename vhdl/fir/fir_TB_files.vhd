library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes.all;
use std.textio.all;

entity fir_TB_files is
end entity fir_TB_files;

architecture RTL of fir_TB_files is
	--constant T_clk : natural := 20; -- periodo clock en ns
	
	signal clk,rst,ce,we,oe: std_logic;
	signal data_in: std_logic_vector(FIR_INPUT_BITS-1 downto 0);
	signal data_out: std_logic_vector(FIR_OUTPUT_BITS-1 downto 0);
	--signal data_out_35: std_logic_vector(34 downto 0);

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

	rst <= '1', '0' after PERI_CLK * 3 / 2;

-- FIR NUESTROOOOOOOOOOOOOOOO
	tb: entity work.fir
		generic map(
			N 		=> 	FIR_INPUT_BITS,
			B		=>  FIR_COEFF_BITS,
			M 		=> 	FIR_OUTPUT_BITS,
			TAPS 	=> 	2*FIR_HALF_TAPS,
			N_DSP 	=> 	DSP_INPUT_BITS,
			M_DSP 	=> 	DSP_OUTPUT_BITS
		)
		port map(
			data_in => data_in,
			data_out => data_out,
			we => we,
			oe => oe,
			ce     => ce,
			clk    => clk,
			rst    => rst
		);
-- FIN FIR NUESTROOOOOOOOOOOOOOOOOo

-- FIR MATLAAAAAAAAAAAAAAAAAAAAA'
--	tb : entity work.filterM
--		port map(
--			clk        => clk,
--			clk_enable => ce,
--			reset      => rst,
--			filter_in  => data_in,
--			filter_out => data_out_35,
--			ce_out     => oe
--		);
	--data_out <= data_out_35(34 downto 19);

-- FIN FIR MATLAAAAAAAAAAAAAAAAA'
		

--	do_test : process
--		variable l : line;
--		-- Reemplazar Nombre por el archivo a usar
--		file f_in : text open read_mode is "/home/ariel/git/vhdl-adc/testbench_files/inputs/fir_input_10000.txt";
--		file f_out : text open write_mode is "/home/ariel/git/vhdl-adc/testbench_files/outputs/fir_output_10000.txt";
--		-- En este ejemplo solo hay un std_logic_vector por linea
--		variable leido : std_logic_vector(FIR_INPUT_BITS-1 downto 0);
--		variable cont:integer :=0;
--	begin
--		report "Comenzando la prueba del FIR mediante archivos" severity note;
--		wait until rst = '0';
--		ce<='1';
--		wait for 1 ps;
--
--		while not (endfile(f_in)) loop
--			wait until rising_edge(clk);
--			readline(f_in, l);
--			read(l, leido);
--			
--			we<='1';
--			data_in <= leido;
--			wait for PERI_CLK;
--			we<='0';
--
--			--wait for PERI_CLK * 10;
--			wait until oe ='1';
--			
--			if oe = '1' then
--				--write(l, data_out_35);
--				write(l, data_out);
--				writeline(f_out, l);
--			end if;
--			wait for PERI_CLK * 10;	
--		end loop;
--		cont:=1;
--		loop
--			if(cont=1) then
--				wait until rising_edge(clk);
--				--wait until oe ='1';
--				if oe = '1' then
--					--write(l, data_out_35);
--					write(l, data_out);
--					writeline(f_out, l);
--				end if;
--				wait for PERI_CLK * 2;
--			end if;	
--		end loop;
--		report "TERMINOOOOOOOOOOOOOOOOOOOOOO" severity failure;
--		wait;
--	end process do_test;


process_read : process
		variable l : line;
		-- Reemplazar Nombre por el archivo a usar
		file f_in : text open read_mode is "/home/ivan/codigo vhdl/ADC/testbench_files/outputs/cic+fir/cic_output_11000.txt";--"/home/ariel/git/vhdl-adc/testbench_files/inputs/fir_input_1000.txt";
		-- En este ejemplo solo hay un std_logic_vector por linea
		variable leido : std_logic_vector(FIR_INPUT_BITS-1 downto 0);
		variable cont,cr: integer :=0;
	begin
		report "Comenzando la lectura de archivos" severity note;
		wait until rst = '0';
		ce<='1';
		wait for 1 ps;

		while not (endfile(f_in)) loop
			wait until rising_edge(clk);
			readline(f_in, l);
			read(l, leido);
			cr:=cr+1;
			we<='1';
			data_in <= leido;
			wait for PERI_CLK;
			we<='0';
			wait until oe ='1';
			wait for PERI_CLK * 3;	
		end loop;
--		cont:=0;
--		while(cont<2*FIR_HALF_TAPS) loop
--			wait until rising_edge(clk);
--			cont:=cont+1;
--			we<='1';
--			data_in <= "0000000000000000";
--			cr:=cr+1;
--			--wait for PERI_CLK;
--			wait until rising_edge(clk);
--			we<='0';
--			wait until oe ='1';
--			wait for PERI_CLK * 2;	
--		end loop;
		wait for PERI_CLK*50;
		report "TERMINO LECTURA!!" severity failure;
		wait;
	end process process_read;
	
process_write: process
		variable l : line;
		file f_out : text open write_mode is "/home/ivan/codigo vhdl/ADC/testbench_files/outputs/cic+fir/fir_output_11000_direc.txt";
		variable cw: integer :=0;
	begin
		report "Comenzando la escritura de archivos" severity note;
		loop
			wait until rising_edge(clk);
			--wait until oe ='1';
			if oe = '1' then
				cw:=cw+1;
				if(cw > 2*FIR_HALF_TAPS) then
					write(l, data_out);
					writeline(f_out, l);
					report "ESCRIBIO LINEA." severity note;
				end if;
			end if;
			wait for PERI_CLK;
		end loop;
	end process process_write;
end architecture;