library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity delay_line is
	generic(
		N    : natural := 6;            --ancho de palabra
		TAPS : natural := 200           --cantidad de palabras
	);
	port(
		input   : in  std_logic_vector(N - 1 downto 0);

		output1 : out std_logic_vector(N - 1 downto 0);
		output2 : out std_logic_vector(N - 1 downto 0);

		add1  : in  std_logic_vector(log2(TAPS) - 1 downto 0);
		add2  : in  std_logic_vector(log2(TAPS) - 1 downto 0);

		we      : in  std_logic;        -- write enable

		ce      : in  std_logic;
		clk     : in  std_logic;
		rst     : in  std_logic
	);
end entity delay_line;

architecture RTL of delay_line is
	type ram_type is array (TAPS-1 downto 0) of std_logic_vector(N - 1 downto 0);
	signal RAM      : ram_type := (others => (others => '0'));
	signal output1_i,output2_i: std_logic_vector(N-1 downto 0);
	
	attribute ram_style : string;
	attribute ram_style of RAM : signal is "distributed";
	
begin
	
	name : process (clk) is
	begin
		if rising_edge(clk) then
				if we='1' then
					RAM(TAPS-1 downto 0)<=(RAM(TAPS-2 downto 0) & input);
					--RAM(0)<=input;
				end if;
	output1_i<=RAM(to_integer(unsigned(add1)));
	output2_i<=RAM(to_integer(unsigned(add2)));
	
					
		end if;
	end process name;
	output1<=output1_i;
	output2<=output2_i;
end architecture RTL;
