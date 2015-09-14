library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.floor;

--library UNISIM;
--use UNISIM.vcomponents.PLL_BASE;

use work.extra_functions.all;
use work.constantes.all;

entity top_level is
	generic(
		BIT_OUT       : natural := BIT_OUT;
		N_ETAPAS      : natural := CIC_N_ETAPAS; --etapas del cic
		COMB_DELAY    : natural := CIC_COMB_DELAY; --delay restador
		CIC_R         : natural := CIC_R; --decimacion
		COEFF_BITS    : natural := FIR_COEFF_BITS;
		FIR_R         : natural := FIR_R; --decimacion
		N_DSP         : natural := DSP_INPUT_BITS; --entrada dsp específico para spartan6
		M_DSP         : natural := DSP_OUTPUT_BITS; --salida dsp específico para spartan6
		FIR_HALF_TAPS : natural := FIR_HALF_TAPS;

		Bits_UART     : integer := 8;  -- Cantidad de Bits
		Baudrate      : integer := 921600; -- BaudRate de la comunicacion UART
		Core          : integer := 50000000 -- Frecuencia de core
	);
	port(
		input_p  : in  std_logic;
		input_n  : in  std_logic;
		output   : out std_logic_vector(BIT_OUT - 1 downto 0);
		parallel_oe : out std_logic;
		feedback : out std_logic;
		clk    : in  std_logic;
		nrst    : in  std_logic;

		Tx       : out std_logic        -- Transmisor
	);
end entity top_level;
architecture RTL of top_level is
	
	signal oe     : std_logic                              := '0';
	signal rst   : std_logic                              := '0';
	signal output_i : std_logic_vector(BIT_OUT - 1 downto 0) := (others => '0');
	signal tx_load,tx_load_i : std_logic_vector (BITS_UART-1 downto 0):= (others=>'0');
	signal tx_busy, tx_start,tx_start_i : std_logic:='0';
	type state_type is (IDLE, FIRST, SECOND, WAITING); 
	signal state, state_i : state_type; 
	
	constant cuentas : natural := 4*CORE/BAUDRATE;
	signal cnt : std_logic_vector( log2(cuentas)-1 downto 0);
	signal rst_cnt,rst_cnt_i : std_logic:= '1';
--signal clk_f,clk_o: std_logic;

begin
	rst <= not nrst;
	parallel_oe <= oe;
	--clk_o<=clk_i;
	--  <-----Cut code below this line and paste into the architecture body---->

	-- PLL_BASE: Phase-Lock Loop Clock Circuit 
	--           Spartan-6
	-- Xilinx HDL Language Template, version 11.4

	--   PLL_BASE_inst : PLL_BASE
	--   generic map (
	--      BANDWIDTH => "OPTIMIZED",  -- "HIGH", "LOW" or "OPTIMIZED" 
	--      CLKFBOUT_MULT => 2,        -- Multiplication factor for all output clocks
	--      CLKFBOUT_PHASE => 0.0,     -- Phase shift (degrees) of all output clocks
	--      CLKIN_PERIOD => 20.000,     -- Clock period (ns) of input clock on CLKIN
	--      CLKOUT0_DIVIDE => 1,       -- Division factor for CLKOUT0  (1 to 128)
	--      CLKOUT0_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT0 (0.01 to 0.99)
	--      CLKOUT0_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT0 (0.0 to 360.0)
	--      CLKOUT1_DIVIDE => 1,       -- Division factor for CLKOUT1 (1 to 128)
	--      CLKOUT1_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT1 (0.01 to 0.99)
	--      CLKOUT1_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT1 (0.0 to 360.0)
	--      CLKOUT2_DIVIDE => 1,       -- Division factor for CLKOUT2 (1 to 128)
	--      CLKOUT2_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT2 (0.01 to 0.99)
	--      CLKOUT2_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT2 (0.0 to 360.0)
	--      CLKOUT3_DIVIDE => 1,       -- Division factor for CLKOUT3 (1 to 128)
	--      CLKOUT3_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT3 (0.01 to 0.99)
	--      CLKOUT3_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT3 (0.0 to 360.0)
	--      CLKOUT4_DIVIDE => 1,       -- Division factor for CLKOUT4 (1 to 128)
	--      CLKOUT4_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT4 (0.01 to 0.99)
	--      CLKOUT4_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT4 (0.0 to 360.0)
	--      CLKOUT5_DIVIDE => 1,       -- Division factor for CLKOUT5 (1 to 128)
	--      CLKOUT5_DUTY_CYCLE => 0.5, -- Duty cycle for CLKOUT5 (0.01 to 0.99)
	--      CLKOUT5_PHASE => 0.0,      -- Phase shift (degrees) for CLKOUT5 (0.0 to 360.0)
	--      COMPENSATION => "INTERNAL",  -- "SYSTEM_SYNCHRNOUS", 
	--                                             -- "SOURCE_SYNCHRNOUS", "INTERNAL", 
	--                                             -- "EXTERNAL", "DCM2PLL", "PLL2DCM" 
	--      DIVCLK_DIVIDE => 1,      -- Division factor for all clocks (1 to 52)
	--      REF_JITTER => 0.100)     -- Input reference jitter (0.000 to 0.999 UI%)
	--      port map (
	--      CLKFBOUT => clk_f,      -- General output feedback signal
	--      CLKOUT0 => clk_o,        -- One of six general clock output signals
	--      CLKOUT1 => open,        -- One of six general clock output signals
	--      CLKOUT2 => open,        -- One of six general clock output signals
	--      CLKOUT3 => open,        -- One of six general clock output signals
	--      CLKOUT4 => open,        -- One of six general clock output signals
	--      CLKOUT5 => open,        -- One of six general clock output signals
	--      LOCKED => open,          -- Active high PLL lock signal
	--      CLKFBIN => clk_f,        -- Clock feedback input
	--      CLKIN => clk_i,            -- Clock input
	--      RST => '0'                 -- Asynchronous PLL reset
	--   );

	output <= output_i;
	ADC : entity work.adc
		generic map(
			BIT_OUT       => BIT_OUT,
			N_ETAPAS      => N_ETAPAS,  --etapas del cic
			COMB_DELAY    => COMB_DELAY, --delay restador
			CIC_R         => CIC_R,     --decimacion
			COEFF_BITS    => COEFF_BITS,
			FIR_R         => FIR_R,     --decimacion
			N_DSP         => N_DSP,     --entrada dsp específico para spartan6
			M_DSP         => M_DSP,     --salida dsp específico para spartan6
			FIR_HALF_TAPS => FIR_HALF_TAPS
		)
		port map(
			input_p  => input_p,
			input_n  => input_n,
			output   => output_i,
			feedback => feedback,
			clk      => clk,
			rst      => rst,
			oe       => oe
		);

	SERIE : entity work.Tx_uart
		generic map(
			BITS     => Bits_UART,
			CORE     => core,
			BAUDRATE => Baudrate
		)
		port map(
			Tx      => Tx,
			Load    => tx_load,
			LE      => tx_start,
			Tx_busy => Tx_busy,
			clk     => clk,
			rst     => rst
		);
	
	
	process (clk, rst) is
	begin
		if rst = '1' then
			state <= IDLE;
			tx_load <= (others=>'0');
			tx_start <= '0';		
			rst_cnt <= '1';		
		elsif rising_edge(clk) then
			state <= state_i;
			rst_cnt <= rst_cnt_i;
			tx_load <= tx_load_i;
			tx_start <= tx_start_i;
		end if;
	end process;
	
	
	OUT_PROC:process (tx_busy,oe,state,output_i,tx_start,cnt,tx_load)
	begin	
		rst_cnt_i <= '1';
		tx_load_i <= tx_load;
		tx_start_i <= tx_start;
		state_i <= state;
		case state is
			when IDLE => 
				if oe='1' then
					tx_load_i <= output_i(BIT_OUT-1 downto BIT_OUT/2);
					tx_start_i <= '1';
					state_i <= FIRST;	
				else
					tx_load_i <= (others=>'0');
					tx_start_i <= '0';
					state_i <= IDLE;							
				end if;
			when FIRST=>
				if (tx_busy = '0' and tx_start ='0') then
					rst_cnt_i <= '0';
					state_i <= WAITING;
				else
					tx_load_i <= (others=>'0');
					tx_start_i <= '0';
					state_i <= FIRST;
				end if;
				
			when WAITING =>
				rst_cnt_i <= '0';  
				if cnt=std_logic_vector(to_unsigned(cuentas,cnt'length)) then
					tx_load_i <= output_i(BIT_OUT/2-1 downto 0);
					tx_start_i <= '1';
					state_i <= SECOND;
				end if;
					
			when SECOND=>
				if tx_busy = '0' and tx_start ='0' then
					tx_load_i <= (others=>'0');
					tx_start_i <= '0';
					state_i <= IDLE;
				else
					tx_load_i <= (others=>'0');
					tx_start_i <= '0';
					state_i <= SECOND;
				end if;	
		end case;
	end process;
	
	process (clk, rst_cnt)
	begin
		if rst_cnt = '1' then
			cnt <= (others =>'0');
		elsif rising_edge(clk) then
			cnt <= std_logic_vector(unsigned(cnt)+to_unsigned(1,cnt'length));
		end if;
	end process;
	
end architecture RTL;
