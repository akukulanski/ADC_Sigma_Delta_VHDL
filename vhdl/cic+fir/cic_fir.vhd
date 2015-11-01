library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.IBUFDS;

use work.extra_functions.all;
use work.constantes.all;

use std.standard.all;

entity cic_fir is
	generic(BIT_OUT       : natural := BIT_OUT;
		    N_ETAPAS      : natural := CIC_N_ETAPAS; --etapas del cic
		    COMB_DELAY    : natural := CIC_COMB_DELAY; --delay restador
		    CIC_R         : natural := CIC_R; --decimacion
		    COEFF_BITS    : natural := FIR_COEFF_BITS;
		    FIR_R         : natural := FIR_R; --decimacion
		    N_DSP         : natural := DSP_INPUT_BITS; --entrada dsp específico para spartan6
		    M_DSP         : natural := DSP_OUTPUT_BITS; --salida dsp específico para spartan6
		    FIR_HALF_TAPS : natural := FIR_HALF_TAPS
	);

	port(
		input  : in  std_logic;
		output : out std_logic_vector(BIT_OUT - 1 downto 0);
		clk    : in  std_logic;
		rst    : in  std_logic;
		oe     : out std_logic := '0'
	);
end entity cic_fir;

architecture RTL of cic_fir is
	signal oe_cic, oe_fir : std_logic := '0'; -- senial de salida del LVDS
	signal ce_in          : std_logic := '1';
	signal oe_i, oe_ii    : std_logic := '0';
	signal out_cic        : std_logic_vector(CIC_OUTPUT_BITS - 1 downto 0);
	signal output_fir     : std_logic_vector(BIT_OUT - 1  downto 0);
    signal output_fir_i : std_logic_vector(BIT_OUT -1 downto 0);
begin
	output <= output_fir_i;
	
	CIC : entity work.cic
		generic map(
			N     => N_ETAPAS,          --etapas
			DELAY => COMB_DELAY,        -- delay restador
			R     => CIC_R              --decimacion            
		)
		port map(
			input  => input,
			output => out_cic,
			clk    => clk,
			rst    => rst,
			ce_in  => ce_in,
			ce_out => oe_cic
		);

	fir : entity work.fir
		generic map(
			N     => CIC_OUTPUT_BITS,
			B     => COEFF_BITS,
			M     => BIT_OUT,
			TAPS  => 2 * FIR_HALF_TAPS,
			N_DSP => N_DSP,
			M_DSP => M_DSP
		)
		port map(
			data_in  => out_cic,
			data_out => output_fir,
			we       => oe_cic,
			oe       => oe_fir,
			ce       => ce_in,
			clk      => clk,
			rst      => rst
		);

	--instanciar decimador salida fir (oe_fir --> oe)
	fir_decimator : entity work.decimator
		generic map(
			R => FIR_R
		)
		port map(
			ce_in  => oe_fir,
			ce_out => oe_i,
			clk    => clk,
			rst    => rst
		);
		
	process(clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				oe <= '0';
				output_fir_i <= (others => '0');
			else
				oe <= oe_ii;
				oe_ii <= oe_i;
				if (oe_ii= '1') then
					output_fir_i <= output_fir;
				end if; 
			end if;
		end if;
	end process;
end architecture RTL;
