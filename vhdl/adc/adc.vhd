library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.IBUFDS;

use work.mytypes_pkg.all;
use work.extra_functions.all;
use work.my_coeffs.all;

entity adc is
	generic(BIT_OUT 	: natural 	 := 16;
			N_ETAPAS    : natural    := 6;        --etapas
			DELAY 		: natural    := 1;        -- delay restador
			R_CIC 		: natural    := 512;      --decimacion
			R_FIR 		: natural    := 4;      --decimacion
			B 			: my_array_t := (55,55,50,42,34,27,23,22,21,20,20,19,16);
			N_DSP		: natural := 18; --entrada dsp específico para spartan6
			M_DSP : natural := 48	--salida dsp específico para spartan6
	);	
	
	port(
		input_p : in  std_logic;
		input_n : in  std_logic;
		output  : out std_logic_vector(BIT_OUT - 1 downto 0);
		feedback : out std_logic :='0';
		clk     : in  std_logic;
		rst     : in  std_logic;
		oe 		: out std_logic  :='0'
		-- TODO ce_in como weak para que ande por defecto
	);
end entity adc;

architecture RTL of adc is
	signal out_lvds,oe_cic,oe_fir : std_logic:='0'; -- senial de salida del LVDS
	signal ce_in :std_logic:='1';
	signal out_cic 	: std_logic_vector (B(2*N_ETAPAS)-1 downto 0);
	
	
begin
	feedback <= not(out_lvds);
		
	IBUFDS_inst : IBUFDS
		generic map(
			DIFF_TERM    => TRUE,      		-- Differential Termination 
			IBUF_LOW_PWR => FALSE,       	-- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
			IOSTANDARD   => "DEFAULT")
		port map(
			O  => out_lvds,                  -- Buffer output
			I  => input_p,                   -- Diff_p buffer input (connect directly to top-level port)
			IB => input_n                    -- Diff_n buffer input (connect directly to top-level port)
		);
		
		CIC : entity work.cic
		generic map(
			N => N_ETAPAS,--etapas
			DELAY => DELAY, -- delay restador
			R => R_CIC, --decimacion
			B => B --bits en cada etapa
		)
		port map(
			input  => out_lvds,
			output => out_cic,
			clk    => clk,
			rst    => rst,
			ce_in  => ce_in,
			ce_out => oe_cic
		);
		
	fir : entity work.fir
		generic map(
			N => B(2*N_ETAPAS),
			M => BIT_OUT,
			TAPS  => 2 * N_coeffs,
			N_DSP => N_DSP,
			M_DSP => M_DSP
		)
		port map(
			data_in => out_cic,
			data_out => output,
			we => oe_cic,
			oe => oe_fir,
			ce =>  ce_in,
			clk    => clk,
			rst    => rst
		);
		
	--instanciar decimador salida fir (oe_fir --> oe)
	fir_decimator : entity work.decimator
		generic map(
			R => R_FIR
		)
		port map(
			ce_in  => oe_fir,
			ce_out => oe,
			clk    => clk,
			rst    => rst
		);
end architecture RTL;
