library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes.all;

entity adc_TB is
end entity adc_TB;

architecture RTL of adc_TB is
	signal input_p  : std_logic:= '1';
	signal input_n  : std_logic:= '0';
	signal output   : std_logic_vector(BIT_OUT - 1 downto 0);
	signal feedback : std_logic := '0';
	signal clk      : std_logic;
	signal rst      : std_logic;
	signal oe       : std_logic := '0';

begin
	tb : entity work.adc
		generic map(
			BIT_OUT       => BIT_OUT,
			N_ETAPAS      => TB_CIC_N_ETAPAS,
			COMB_DELAY    => TB_CIC_COMB_DELAY,
			CIC_R         => CIC_R,
			COEFF_BITS    => TB_FIR_COEFF_BITS,
			FIR_R         => TB_FIR_R,
			N_DSP         => TB_DPS_INPUT_BITS,
			M_DSP         => TB_DPS_OUTPUT_BITS,
			FIR_HALF_TAPS => TB_FIR_HALF_TAPS,
			IS_TB         => TRUE
		)
		port map(
			input_p  => input_p,
			input_n  => input_n,
			output   => output,
			feedback => feedback,
			clk      => clk,
			rst      => rst,
			oe       => oe
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
		input_n <= '0';
		input_p <= '1';
		wait for 30 ns;
		rst <= '0';
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

end architecture RTL;
