library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constantes.all;

entity TOP_TB is
end entity TOP_TB;

architecture RTL of TOP_TB is
	signal input_p  : std_logic:= '1';
	signal input_n  : std_logic:= '0';
	signal output   : std_logic_vector(BIT_OUT - 1 downto 0);
	signal feedback : std_logic := '0';
	signal clk      : std_logic;
	signal rst      : std_logic;
	signal oe       : std_logic := '0';
	signal Tx, Rx :std_logic:='0';
	
begin
	tb : entity work.top_level
		generic map(
			BIT_OUT       => BIT_OUT,
			N_ETAPAS      => CIC_N_ETAPAS,
			COMB_DELAY    => CIC_COMB_DELAY,
			CIC_R         => CIC_R,
			COEFF_BITS    => FIR_COEFF_BITS,
			FIR_R         => FIR_R,
			N_DSP         => DSP_INPUT_BITS,
			M_DSP         => DSP_OUTPUT_BITS,
			FIR_HALF_TAPS => FIR_HALF_TAPS,
			Bits_UART     => 8,
			Baudrate      => 921600,
			Core          => 90625000
		)
		port map(
			input_p  => input_p,
			input_n  => input_n,
			output   => output,
			parallel_oe => oe,
			feedback => feedback,
			clk      => clk,
			nrst     => rst,
			Tx       => Tx,
			Rx 		=> Rx
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
		rst <= '0';
		input_n <= '0';
		input_p <= '1';
		wait for 30 ns;
		rst <= '1';
		wait for 4 ms;	
		input_n <= '1';
		input_p <= '0';
		wait for 10 ms;	
		
		loop
			input_n <= '1';
			input_p <= '0';
			wait for 80 ns;
			input_n <= '0';
			input_p <= '1';
			wait for 80 ns;	
		end loop;
		
		wait;
	end process;

	RX_PROC: process is
	begin
		rx <= '1';
		wait for 100 us;   -- 01110011
		rx <= '0';	-- StartBit
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '1'; -- Stop Bit
		wait for 1.085 us;
		rx <= '1';
		
		wait for 1000 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';
		wait;	
	end process;

end architecture RTL;
