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
	signal write_address,read_address1,read_address2: std_logic_vector(log2(TAPS)-1 downto 0) := (others=>'0');
	signal adder_input1,adder_input2: std_logic_vector(N-1 downto 0) := (others=>'0');
	signal coef_input: std_logic_vector(N downto 0) := (others=>'0');
	signal s_output: std_logic_vector(M-1 downto 0) := (others=>'0');
	signal s_oe: std_logic := '0';
	signal coef_address: std_logic_vector(log2(TAPS/2)-1 downto 0):= (others=>'0');
	signal ram_we: std_logic := '0';
	signal rst_mac: std_logic := '0';
	
begin
	
	address_gen: entity work.address_generator --address generator
		generic map(
			TAPS => TAPS
		)
		port map(
			write_address  => write_address,
			read_address1 => read_address1,
			read_address2 => read_address2,
			coef_address  => coef_address,
			we     => we,
			o_we   => ram_we,
			ce     => ce,
			clk    => clk,
			rst    => rst,
			rst_mac => rst_mac
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
			write_address   => write_address,
			output1 => adder_input1,
			output2 => adder_input2,
			read_address1  => read_address1,
			read_address2  => read_address2,
			we      => ram_we,
			ce      => ce,
			clk     => clk,
			rst		=> rst
		);

-- EDITAR DESDE ACA
	preadder : entity work.preadd_mac--preadder
		generic map(
			N        => N,
			--N_PREADD => N_PREADD,
			N_OUT    => M
		)
		port map(
			pre_input1 => adder_input1,
			pre_input2 => adder_input2,
			mul_input  => coef_input,
			output     => data_out,
			ce         => ce,
			clk        => clk,
			rst        => rst_mac
		);

end architecture RTL;
