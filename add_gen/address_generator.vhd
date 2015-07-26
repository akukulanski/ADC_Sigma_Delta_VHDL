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
		enable_mac_new_input  : out std_logic := '0';

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
	signal oper_ena_mac: std_logic := '0';
	signal next_oper_ena_mac: std_logic := '0';
	--signal k, next_k: integer := 0;--unsigned(1 downto 0):=to_unsigned(0,2);
	signal k, next_k: unsigned(2 downto 0) := to_unsigned(0,3);--unsigned(1 downto 0):=to_unsigned(0,2);


begin
	write_address <= cnt;
	read_address1 <= read_address1_i;
	read_address2 <= read_address2_i;
	enable_mac_new_input <= oper_ena_mac;

	PROXIMO_ESTADO : process(state, we, j, cnt, k)
	begin
		next_state <= state;
		next_o_we  <= '0';
		next_oe    <= '0';
		next_cnt   <= cnt;
		next_oper_ena_mac <= '0';
		next_k <= to_unsigned(0,3);
		case state is
			when idle =>
				if we = '1' then
					next_state <= reading;
					next_o_we  <= '1';
					next_cnt   <= std_logic_vector(unsigned(cnt) + to_unsigned(1, log2(TAPS)));
				end if;
			when writing =>
				next_state <= reading;
			when reading =>
				if j /= 0 then
					next_oper_ena_mac <= '1';
				end if;
				if j + 1 = 0 then --if j=0 then
					next_state <= waiting_for_mac;
					next_k <= to_unsigned(0,3);
				end if;
			when waiting_for_mac =>
				if k = to_unsigned(0,3) then
					next_oper_ena_mac <= '1';
				end if;
				if k = to_unsigned(4,3) then
					next_state <= idle;
					next_oe <= '1';
				end if;
				next_k <= k + to_unsigned(1,3);
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
						-- hace falta?
						read_address1_i <= std_logic_vector(unsigned(cnt) - j);
						read_address2_i <= std_logic_vector(unsigned(cnt) + 1 + j);
						coef_address    <= std_logic_vector(j);
				end case;
				state <= next_state;
				o_we  <= next_o_we;
				oe    <= next_oe;
				cnt   <= next_cnt;
				oper_ena_mac <= next_oper_ena_mac;
				k <= next_k;
			end if;
		end if;
	end process;


end architecture;