library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity address_generator is
	generic(
		TAPS : natural := 200           --cantidad de palabras
	);
	port(
		--posición de escritura
		write_address : out std_logic_vector(log2(TAPS) - 1 downto 0)     := (others => '0');
		--posición de lectura 1
		read_address1 : out std_logic_vector(log2(TAPS) - 1 downto 0)     := (others => '0');
		--posición de lectura 2
		read_address2 : out std_logic_vector(log2(TAPS) - 1 downto 0)     := (others => '0');
		--posición de lectura de los coeficientes
		coef_address  : out std_logic_vector(log2(TAPS / 2) - 1 downto 0) := (others => '0');
		--- write enable (habilita escritura en la RAM)
		o_we          : out std_logic                                     := '0';
		--- data output enabled
		oe            : out std_logic                                     := '0';
		--- enable mac clock
		o_ce_mac	  : out std_logic := '0';

		we            : in  std_logic;
		ce            : in  std_logic;
		clk           : in  std_logic;
		rst           : in  std_logic
	);

end address_generator;

architecture RTL of address_generator is
	signal cnt             : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '1');
	signal read_address1_i : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');
	signal read_address2_i : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');
	signal j               : unsigned(log2(TAPS / 2) - 1 downto 0);
	signal we_i            : std_logic                                 := '0';
	signal addr_ena        : std_logic                                 := '0';
	signal addr_rst        : std_logic                                 := '0';

	--	type state_t is (idle, count);
	--	signal state   : state_t := idle;
	--	signal state_i : state_t := idle;

	type state_t is (idle, writing, reading, waiting_for_mac);
	signal state      : state_t                                   := idle;
	signal next_state : state_t                                   := idle;
	signal next_cnt   : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');

	signal next_o_we : std_logic := '1';
	signal next_oe   : std_logic := '0';
--signal next_j: unsigned(log2(TAPS / 2) - 1 downto 0);
	signal next_o_ce_mac: std_logic := '0';


begin
	write_address <= cnt;
	we_i          <= we;
	read_address1 <= read_address1_i;
	read_address2 <= read_address2_i;

	PROXIMO_ESTADO : process(state, we, j)
	begin
		next_state <= state;
		next_o_we  <= '0';
		next_oe    <= '0';
		next_cnt   <= cnt;
		next_o_ce_mac <= '0';
		case state is
			when idle =>
				if we = '1' then
					next_state <= reading;
					next_o_we  <= '1';
					next_cnt   <= std_logic_vector(unsigned(cnt) + to_unsigned(1, log2(TAPS)));
				end if;
			when writing =>
				next_state <= reading;
				--next_o_ce_mac <= '1';
			when reading =>
				if j /= 0 then
					next_o_ce_mac <= '1';
				end if;
				if j + 1 = 0 then --if j=0 then
--					next_state <= idle;
--					next_oe    <= '1';
					next_state <= waiting_for_mac;
				end if;
			when waiting_for_mac =>
				next_state <= idle;
				next_oe    <= '1';
				next_o_ce_mac <= '1';
		end case;
	end process;

	CAMBIO_ESTADO : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				state           <= idle;
				o_we            <= '0';
				oe              <= '0';
				cnt             <= (others => '1');
				j               <= (others => '0');
				read_address1_i <= (others => '0');
				read_address2_i <= (others => '0');
				coef_address    <= (others => '0');
			elsif ce = '1' then
				case state is
					when idle =>
						j <= to_unsigned(0, log2(TAPS / 2));
					when writing =>
						-- Clock de escritura. No lee.
						-- Sobreescribe y luego lee en reading:
						-- j ya VALE CERO
						-- j <= to_unsigned(0,log2(TAPS / 2));
						null;
					when reading =>
						-- La muestra más vieja (que se multiplica por el mismo coeficiente, es cnt+1, NO cnt-1).
						-- Para recorrer las muestras hacia atrás, cnt - j:
						read_address1_i <= std_logic_vector(unsigned(cnt) - j);
						-- Para recorrer hacia adelante, cnt+1+j
						read_address2_i <= std_logic_vector(unsigned(cnt) + 1 + j);
						coef_address    <= std_logic_vector(j);
						j               <= j + 1;
					when waiting_for_mac =>
						read_address1_i <= std_logic_vector(unsigned(cnt) - j);
						read_address2_i <= std_logic_vector(unsigned(cnt) + 1 + j);
						coef_address    <= std_logic_vector(j);
				end case;
				state <= next_state;
				o_we  <= next_o_we;
				oe    <= next_oe;
				cnt   <= next_cnt;
				o_ce_mac <= next_o_ce_mac;
			end if;
		end if;
	end process;

--	contador : process(clk)
--	begin
--		if rising_edge(clk) then
--			--o_we <= '0';
--			if rst = '1' then
--				o_we <= '0';
--				cnt  <= (others => '1');
--				j <= (others => '0');--agregado
--				rst_mac <= '1';	--agregado
--			else
--				if (we = '1') then
--					cnt <= std_logic_vector(unsigned(cnt) + to_unsigned(1, log2(TAPS)));
--				end if;
--				o_we <= we_i;
--			end if;
--		end if;
--	end process;
--
--	ADDRESS_PROCESS: process(clk)
--	begin
--		if rising_edge(clk) then
--			if addr_rst = '1' then
--				read_address1_i <= (others => '0');
--				read_address2_i <= (others => '0');
--				coef_address    <= (others => '0');
--				j        <= (others => '0');
--				rst_mac <= '1'; --agregado
--			elsif (addr_ena = '1') then
--				read_address1_i <= std_logic_vector(unsigned(cnt) + j);
--				read_address2_i <= std_logic_vector(unsigned(cnt) - j - 1);
--				coef_address    <= std_logic_vector(j);
--				j        <= j + 1;
--				rst_mac <= '0'; --agregado
--			end if;
--		end if;
--	end process;
--
--
--
--	STATE_PROCESS : process(clk)
--	begin
--		if rising_edge(clk) then
--			if rst = '1' then
--				state <= idle;
--			elsif ce = '1' then
--				state <= state_i;
--			end if;
--		end if;
--	end process;
--
--	NEXT_STATE : process(state, we, j)
--	begin
--		state_i <= state;
--		case state is
--			when idle =>
--				if we = '1' then
--					state_i <= count;
--				end if;
--			when count =>
--				if j = 0 then
--					state_i <= idle;
--				end if;
--		end case;
--	end process;
--
--	OUTPUT_STATE : process(state_i)
--	begin
--		if state_i = count then
--			addr_ena   <= '1';
--			addr_rst <= '0';
--		else
--			addr_ena   <= '0';
--			addr_rst <= '1';
--		end if;
--	end process;


end architecture;