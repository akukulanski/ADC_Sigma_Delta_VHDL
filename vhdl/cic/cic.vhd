library IEEE;
use IEEE.STD_LOGIC_1164.all;

--use work.mytypes_pkg.all;
use work.extra_functions.all;
use work.constantes.all;

use std.standard.all;

entity cic is
	generic(
		N     : natural := CIC_N_ETAPAS; --etapas
		DELAY : natural := CIC_COMB_DELAY; -- delay restador
		R     : natural := CIC_R       --decimacion
		--B     : natural_array(0 to 2 * CIC_N_ETAPAS) := CIC_STAGE_BITS --cantidad de bits por etapa
	);
	port(
		input  : in  std_logic;         --entrada cic
		output : out std_logic_vector(CIC_OUTPUT_BITS - 1 downto 0); --salida cic
		clk    : in  std_logic;         --clk
		rst    : in  std_logic;         --reset
		ce_in  : in  std_logic;         --clock enable entrada, cuando este esta desactivado no hace nada
		ce_out : out std_logic          --salida, que es el mismo clock enable que usan los comb
	);

end cic;

architecture RTL of cic is
	constant B : natural_array(0 to 2 * N) := CIC_STAGE_BITS;
	type signal_t is array (0 to N - 1) of std_logic_vector(B(0) - 1 downto 0);

	signal senI     : signal_t;         -- senales integrador
	signal senC     : signal_t;         -- senales comb
	signal ce_out_i : std_logic;
	signal output_i : std_logic_vector(B(2 * N - 1) - 1 downto 0);
	signal ce_comb  : std_logic := '1';

begin
	senC(0)(B(N - 1) - 1 downto 0) <= senI(N - 1)(B(N - 1) - 1 downto 0); --ultimo integrator directo a primer comb
	output                         <= output_i(B(2 * N - 1) - 2 downto B(2 * N - 1) - B(2 * N)-1) when output_i(B(2 * N - 1)-1)='0' else
									  (others=> '1');
	
	
	ce_comb                        <= '1' when R = 1 else ce_out_i;
	--ce_out <= ce_out_i;
	ce_out                         <= ce_comb;

--	g_limpia_bits : for i in 0 to N - 1 generate --limpiando bits no usados
--		senI(i)(B(0) - 1 downto B(i))         <= (others => '0');
--		senC(i)(B(0) - 1 downto B(i + N - 1)) <= (others => '0');
--	end generate g_limpia_bits;

	acu0 : entity work.integrator generic map(N => 1, M => B(0)) --primer acumulador
		port map(
			input  => vectorize(input),
			output => senI(0)(B(0) - 1 downto 0),
			ce     => ce_in,
			clk    => clk,
			rst    => rst
		);

	g_acu_comb : for i in 0 to N - 2 generate
		--del uno al N-esimo acumulador
		acu : entity work.integrator generic map(N => B(i + 1), M => B(i + 1))
			port map(
				input  => senI(i)(B(i) - 1 downto B(i) - B(i + 1)),
				output => senI(i + 1)(B(i + 1) - 1 downto 0),
				ce     => ce_in,
				clk    => clk,
				rst    => rst
			);

		--del primer al (N-1)-esimo comb
		comb : entity work.comb generic map(N => B(i + N), DELAY => DELAY)
			port map(
				input  => senC(i)(B(i + N - 1) - 1 downto B(i + N - 1) - B(i + N)),
				output => senC(i + 1)(B(i + N) - 1 downto 0),
				ce     => ce_comb,
				clk    => clk,
				rst    => rst
			);
	end generate g_acu_comb;

	combN_1 : entity work.comb generic map(N => B(2 * N - 1), DELAY => DELAY) -- ultimo comb
		port map(
			input  => senC(N - 1)(B(2 * N - 2) - 1 downto B(2 * N - 2) - B(2 * N - 1)),
			output => output_i(B(2 * N - 1) - 1 downto 0),
			ce     => ce_comb,
			clk    => clk,
			rst    => rst
		);

	dec : entity work.decimator generic map(R => R) --decimador
		port map(
			ce_in  => ce_in,
			ce_out => ce_out_i,
			clk    => clk,
			rst    => rst
		);

end RTL;

