library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.constantes.all;

entity cic_matlab_TB is
end entity cic_matlab_TB;

architecture RTL of cic_matlab_TB is
	-- string to std_logic_vector
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

	-- Un periodo de reloj arbitrario
	constant PERI_CLK : time := 10 ns;

	-- Se�ales basicas
	signal clk     : std_logic;
	signal rst     : std_logic;
	signal detener : boolean := false;

	-- Colocar ac� las senales de nuestro DUT
	signal input  : std_logic                                         := '0';
	signal output : std_logic_vector(CIC_OUTPUT_BITS - 1 downto 0) := (others => '0');
	signal ce_in  : std_logic                                         := '0';
	signal ce_out : std_logic                                         := '0';

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

	DUT : entity work.cic
		generic map(
			N     => CIC_N_ETAPAS,   --etapas
			DELAY => CIC_COMB_DELAY, --delay restador
			R     => CIC_R          --decimacion
			)
		port map(
			input  => input,
			output => output,
			clk    => clk,
			rst    => rst,
			ce_in  => ce_in,
			ce_out => ce_out
		);

	do_test : process
		variable l : line;
		-- Reemplazar Nombre por el archivo a usar
		file f_in : text open read_mode is "/home/ariel/git/vhdl-adc/vhdl/cic/input_stream_CIC.txt";
		file f_out : text open write_mode is "/home/ariel/git/vhdl-adc/vhdl/cic/output_CIC.txt";
		-- En este ejemplo solo hay un std_logic_vector por linea
		variable leido : std_logic_vector(0 downto 0);
	begin
		report "Comenzando la prueba del CIC mediante archivos" severity note;
		wait until rst = '0';
		ce_in <= '1';
		wait for 1 ps;

		while not (endfile(f_in)) loop
			wait until rising_edge(clk);
			readline(f_in, l);
			read(l, leido);
			input <= leido(0);
			--wait for 1 ps;
			
			if ce_out ='1' then
				write(l, output);
				writeline(f_out, l);
			end if;	
				
--			count := count + 1;		
--			if count = CIC_R then
--				count := 0;
--				write(l, output);
--				writeline(f_out, l);
--			end if;
		end loop;
		wait;
	end process do_test;
end architecture RTL;
