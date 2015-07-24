library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity preadd_mac_TB is
end entity preadd_mac_TB;

architecture RTL of preadd_mac_TB is
	constant N                    : integer := 16;
	constant N_PREADD             : integer := 18;
	constant N_ADD                : integer := 48;
	signal pre_input1, pre_input2 : std_logic_vector(N - 1 downto 0):=(others=>'0');
	signal mul_input              : std_logic_vector(N_PREADD - 1 downto 0):=(others=>'0');
	signal output           : std_logic_vector(N_ADD - 1 downto 0);
	signal ce, clk, rst : std_logic:= '0'; -- outpue enable

begin
	
	preadd_mac_inst : entity work.preadd_mac
		generic map(
			N        => N,
			N_PREADD => N_PREADD,
			N_ADD    => N_ADD
		)
		port map(
			pre_input1 => pre_input1,
			pre_input2 => pre_input2,
			mul_input  => mul_input,
			output     => output,
			ce         => ce,
			clk        => clk,
			rst        => rst
		);
	
	CLOCK : process is
	begin
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
	end process;
	
	RST_EN : process is
	begin
		wait for 10 ns;
		rst <= '1';
		wait for 20 ns;
		rst <= '0';
		wait for 20 ns;
		ce <= '1';
		loop
			null;
					wait for 20 ns;
			
		end loop;
		
		wait;
	end process;
	
		pre_input1<=std_logic_vector(to_unsigned(1,N));
		pre_input2<=std_logic_vector(to_unsigned(1,N));
		mul_input<=std_logic_vector(to_unsigned(1,N_PREADD));
end architecture RTL;

