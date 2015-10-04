library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Rx_uart_TB is
end entity Rx_uart_TB;

architecture RTL of Rx_uart_TB is
	signal  rx : std_logic;
	signal	output : std_logic_vector(7 downto 0):= "00000000";
	signal	oe : std_logic;
	signal	clk : std_logic;
	signal	rst : std_logic;
begin

	UART: entity work.Rx_uart
		generic map(
			BITS     => 8,
			CORE     => 100000000,
			BAUDRATE => 921600
		)
		port map(
			rx     => rx,
			oe     => oe,
			output => output,
			clk    => clk,
			rst    => rst
		);
		
		
	CLOCK : process is
		begin
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
	end process;

	RST_EN : process is
	begin
		rx <= '1';
		rst <= '1';
		wait for 20 ns;
		rst <= '0';
		loop
			wait for 100 ns;
			rx <= '0';
			wait for 1.085 us;
			rx <= '1';
			wait for 1.085 us;
			rx <= '0';
			wait for 1.085 us;
			rx <= '1';
			wait for 1.085 us;
			rx <= '0';
			wait for 1.085 us;
			rx <= '1';
			wait for 1.085 us;
			rx <= '0';
			wait for 1.085 us;
			rx <= '1';
			wait for 1.085 us;
			rx <= '0';
			wait for 1.085 us;
			rx <= '0';
			wait for 1.085 us;
			rx <= '1';
			wait for 20 us;
		end loop;
		
	end process;
		
		
	
end architecture RTL;
