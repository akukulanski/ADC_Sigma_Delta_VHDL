library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constantes.all;

entity fir_TB is
end entity fir_TB;

architecture RTL of fir_TB is
	constant T_clk : natural := 20; -- periodo clock en ns
	
	signal clk,rst,ce,we,oe: std_logic;
	signal data_in: std_logic_vector(TB_FIR_INPUT_BITS-1 downto 0);
	signal data_out: std_logic_vector(TB_FIR_OUTPUT_BITS-1 downto 0);
	
	--constant init: std_logic_vector(N-2 downto 0) := (others => '0');
	--signal cont: std_logic_vector(N-1 downto 0):= '1' & init;
	signal entrada_legible: std_logic_vector(TB_FIR_INPUT_BITS-1 downto 0); --convertida de bin desplaz a ca2

begin
	tb : entity work.fir
		generic map(
			N 		=> 	TB_FIR_INPUT_BITS,
			B		=>  TB_FIR_COEFF_BITS,
			M 		=> 	TB_FIR_OUTPUT_BITS,
			TAPS 	=> 	2*TB_FIR_HALF_TAPS,
			N_DSP 	=> 	TB_DPS_INPUT_BITS,
			M_DSP 	=> 	TB_DPS_OUTPUT_BITS,
			IS_TB   =>  TRUE
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
	
	data_in<=('1'&(TB_FIR_INPUT_BITS-2 downto 1 => '0')&'1');
	entrada_legible <= not(data_in(TB_FIR_INPUT_BITS-1)) & data_in(TB_FIR_INPUT_BITS-2 downto 0);
	
	CLOCK : process is
	begin
		clk <= '0';
		wait for (T_clk/2) * 1 ns;
		clk <= '1';
		wait for (T_clk/2) * 1 ns;
	end process;

	RST_EN : process is
		
	begin
		wait for (T_clk/2) * 1 ns;
		rst <= '1';
		ce <= '1';
		we <= '0';
		wait for T_clk * ns;
		rst <= '0';
		wait for T_clk * ns;
		we <= '1';
		loop
			wait for T_clk * ns;
			we <= '0';
			wait for (T_clk*(TB_FIR_HALF_TAPS+5)) * 1 ns;		
			we <= '1';
		end loop;
		wait;
	end process;

end architecture RTL;
