library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_TB is
end entity uart_TB;

architecture RTL of uart_TB is
	signal Tx : std_logic;
	signal	Load : std_logic_vector(7 downto 0):= "10100101";
	signal	LE : std_logic;
	signal	Tx_busy : std_logic;
	signal	clk : std_logic;
	signal	rst : std_logic;
begin

	UART: entity work.Tx_uart
		generic map(
			BITS     => 8,
			CORE     => 50000000,
			BAUDRATE => 921600
		)
		port map(
			Tx      => Tx,
			Load    => Load,
			LE      => LE,
			Tx_busy => Tx_busy,
			clk     => clk,
			rst     => rst
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
		rst <= '1';
		wait for 20 ns;
		rst <= '0';
		loop
			LE <= '1';
			wait for 20 ns;
			LE <= '0';	
			wait for 13 us;	
		end loop;
		
	end process;
		
		
	
end architecture RTL;
