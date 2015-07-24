library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all; -- para log2()

entity fir is
	generic(
		N: natural := 16; --cantidad bits input (viene del cic)
		M: natural := 48; --cant bits salida
		TAPS: natural := 256 --cant coeficientes fir
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		ce: in std_logic;
		we: in std_logic;
		data_in: in std_logic_vector(N-1 downto 0);
		
		data_out: out std_logic_vector(M-1 downto 0);
		oe: out std_logic
	);
end entity fir;

architecture RTL of fir is
	signal data_in_i: std_logic_vector(N-1 downto 0) := (others=>'0');
	signal i_add,o_addr1,o_addr2: std_logic_vector(log2(TAPS)-1 downto 0) := (others=>'0');
	signal o_1,o_2: std_logic_vector(N-1 downto 0) := (others=>'0');
	signal soutput: std_logic_vector(M-1 downto 0) := (others=>'0');
	signal soe: std_logic := '0';
	signal c_add: std_logic_vector(log2(TAPS/2)-1 downto 0):= (others=>'0');
	signal o_we: std_logic := '0';
begin
	
	address_gen: entity work.add_gen --address generator
		generic map(
			TAPS => TAPS
		)
		port map(
			i_add  => i_add,
			o_add1 => o_addr1,
			o_add2 => o_addr2,
			c_add  => c_add,
			we     => we,
			o_we   => o_we,
			ce     => ce,
			clk    => clk,
			rst    => rst
		);
		
	ram: entity work.RAM
		generic map(
			N    => N,
			TAPS => TAPS
		)
		port map(
			input   => not(data_in(N-1)) & data_in(N-2 downto 0),
			-- NOTA: se convirtió de binario
			-- desplazado a CA2 para luego usar
			-- el signo en el multiplicador
			i_add   => i_add,
			output1 => o_1,
			output2 => o_2,
			o_add1  => o_addr1,
			o_add2  => o_addr2,
			we      => o_we,
			ce      => ce,
			clk     => clk,
			rst		=> rst
		);

-- EDITAR DESDE ACA
--	preadder : entity work.preadd_mac--preadder
--		generic map(
--			N        => N,
--			N_PREADD => N_PREADD,
--			N_ADD    => N_ADD
--		)
--		port map(
--			pre_input1 => pre_input1,
--			pre_input2 => pre_input2,
--			mul_input  => mul_input,
--			output     => output,
--			ce         => ce,
--			clk        => clk,
--			rst        => rst
--		);
	

end architecture RTL;
