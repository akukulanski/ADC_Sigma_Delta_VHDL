library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.floor;

use work.extra_functions.all;
use work.constantes.all;

entity fir_uart is
	generic(
		N         : natural := FIR_INPUT_BITS; --cantidad bits input (viene del cic)
		B         : natural := FIR_COEFF_BITS; -- cantidad bits coeficientes esta en el package incluido arriba
		M         : natural := FIR_OUTPUT_BITS; --cant bits salida
		TAPS      : natural := 2 * FIR_HALF_TAPS; --longitud filtro fir
		N_DSP     : natural := DSP_INPUT_BITS; --cant de bits de entrada del dsp
		M_DSP     : natural := DSP_OUTPUT_BITS; --cant de bits de salida del dsp

		Bits_UART : integer := 8;       -- Cantidad de Bits
		Baudrate  : integer := 921600;  -- BaudRate de la comunicacion UART
		Core      : integer := 50000000 -- Frecuencia de core
	);
	port(
		clk : in  std_logic;
		rst : in  std_logic;

		rx  : in  std_logic;
		tx  : out std_logic
	);
end entity fir_uart;

architecture RTL of fir_uart is
	signal clk_90                        : std_logic                                := '0';
	signal oe                            : std_logic                                := '0';
	signal output_i                      : std_logic_vector(BIT_OUT - 1 downto 0)   := (others => '0');
	signal tx_load, tx_load_i            : std_logic_vector(BITS_UART - 1 downto 0) := (others => '0');
	signal tx_busy, tx_start, tx_start_i : std_logic                                := '0';
	type state_type is (IDLE, FIRST, SECOND, WAITING);
	signal state, state_i : state_type;

	type estado_t is (PRIMERO, SEGUNDO, WAITING, WAITING2);
	signal estado, estado_i : estado_t;

	signal output_rx : std_logic_vector(Bits_UART - 1 downto 0) := (others => '0');

	constant cuentas          : natural   := 4 * CORE / BAUDRATE;
	signal cnt                : std_logic_vector(log2(cuentas) - 1 downto 0);
	signal rst_cnt, rst_cnt_i : std_logic := '1';

	signal oe_rx     	: std_logic := '0';
	signal input_fir 	: std_logic_vector(N - 1 downto 0) := (others => '0');
	signal input_fir_i 	: std_logic_vector(N - 1 downto 0) := (others => '0');

	signal we_fir 	: std_logic := '0';
	signal we_fir_i	: std_logic:='0';
	signal ce_fir 	: std_logic := '1';
	signal aux   	: std_logic := '0';

begin
	-- No hay PLL, un unico clock
	clk_90 <= clk;
	ce_fir <= '1';

	FIR : entity work.fir
		generic map(
			N     => N,
			B     => B,
			M     => M,
			TAPS  => TAPS,
			N_DSP => N_DSP,
			M_DSP => M_DSP
		)
		port map(
			clk      => clk,
			rst      => rst,
			ce       => ce_fir,
			we       => we_fir,
			data_in  => input_fir,
			data_out => output_i,
			oe       => oe
		);

	TX_SERIE : entity work.Tx_uart
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
			clk     => clk_90,
			rst     => rst
		);

	RX_SERIE : entity work.Rx_uart
		generic map(
			BITS     => Bits_UART,
			CORE     => core,
			BAUDRATE => Baudrate
		)
		port map(
			rx     => rx,
			oe     => oe_rx,
			output => output_rx,
			clk    => clk_90,
			rst    => rst
		);

	process(clk_90) is
	begin
		if rising_edge(clk_90) then
			if rst = '1' then
				state    <= IDLE;
				tx_load  <= (others => '0');
				tx_start <= '0';
				rst_cnt  <= '1';
			else
				state    <= state_i;
				rst_cnt  <= rst_cnt_i;
				tx_load  <= tx_load_i;
				tx_start <= tx_start_i;
			end if;
		end if;
	end process;

	-- Recibe de la uart
	process(clk_90) is
	begin
		if rising_edge(clk_90) then
			if rst = '1' then
				estado <= PRIMERO;
				we_fir <= '0';
				input_fir <= (others => '0');
			else
				estado <= estado_i;
				we_fir <= we_fir_i;
				input_fir <= input_fir_i;
			end if;
		end if;
	end process;

	IN_PROC : process(estado, oe_rx, output_rx)
	begin
		we_fir_i <='0';
		case estado is
			when PRIMERO =>
				input_fir_i(Bits_UART-1 downto 0) <= (others => '0');
				if(oe_rx ='1') then
					estado_i <= WAITING;
					input_fir_i(Bits_UART - 1 downto 0) <= output_rx;
				end if;
			when WAITING =>
				if(oe_rx='0') then
					estado_i <= SEGUNDO;
				end if;
			when SEGUNDO =>
				if(oe_rx='1') then
					estado_i <= WAITING2;
					input_fir_i(N - 1 downto Bits_UART) <= output_rx;
					we_fir_i <= '1';
				end if;	
			when WAITING2 =>
				if(oe_rx='0') then
					estado_i <= PRIMERO;
				end if;
		end case;
	end process IN_PROC;


	-- Envía por la UART
	OUT_PROC : process(tx_busy, oe, state, output_i, tx_start, tx_load)
	begin
		rst_cnt_i  <= '1';
		tx_load_i  <= tx_load;
		tx_start_i <= tx_start;
		state_i    <= state;
		case state is
			when IDLE =>
				if oe = '1' then
					tx_load_i  <= output_i(BIT_OUT - 1 downto BIT_OUT / 2);
					tx_start_i <= '1';
					state_i    <= FIRST;
				else
					tx_load_i  <= (others => '0');
					tx_start_i <= '0';
					state_i    <= IDLE;
				end if;
			when FIRST =>
				if (tx_busy = '0' and tx_start = '0') then
					rst_cnt_i <= '0';
					state_i   <= WAITING;
				else
					tx_load_i  <= (others => '0');
					tx_start_i <= '0';
					state_i    <= FIRST;
				end if;

			when WAITING =>
				tx_load_i  <= output_i(BIT_OUT / 2 - 1 downto 0);
				tx_start_i <= '1';
				state_i    <= SECOND;

			when SECOND =>
				if tx_busy = '0' and tx_start = '0' then
					tx_load_i  <= (others => '0');
					tx_start_i <= '0';
					state_i    <= IDLE;
				else
					tx_load_i  <= (others => '0');
					tx_start_i <= '0';
					state_i    <= SECOND;
				end if;
		end case;
	end process;

	process(clk_90)
	begin
		if rising_edge(clk_90) then
			if rst_cnt = '1' then
				cnt <= (others => '0');
			else
				cnt <= std_logic_vector(unsigned(cnt) + to_unsigned(1, cnt'length));
			end if;
		end if;
	end process;

end architecture RTL;
