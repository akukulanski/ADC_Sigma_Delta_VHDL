library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity add_gen is
	generic(
		TAPS : natural := 200           --cantidad de palabras
	);
	port(
		i_add  : out std_logic_vector(log2(TAPS) - 1 downto 0); --puntero a donde se escribe

		o_add1 : out std_logic_vector(log2(TAPS) - 1 downto 0); --puntero a salida 1
		o_add2 : out std_logic_vector(log2(TAPS) - 1 downto 0); --puntero a salida 2

		c_add  : out std_logic_vector(log2(TAPS/2) - 1 downto 0); --puntero a coeficientes
		we     : in  std_logic;
		o_we   : out std_logic;

		ce     : in  std_logic;
		clk    : in  std_logic;
		rst    : in  std_logic
	);

end add_gen;

architecture RTL of add_gen is
	signal cnt      : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');
	signal o_add1_i : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');
	signal o_add2_i : std_logic_vector(log2(TAPS) - 1 downto 0) := (others => '0');
	signal j        : unsigned(log2(TAPS / 2) - 1 downto 0);
	signal we_i     : std_logic                                 := '0';
	signal add_e    : std_logic                                 := '0';
	signal add_rst  : std_logic                                 := '0';

	type state_t is (idle, count);
	signal state   : state_t := idle;
	signal state_i : state_t := idle;

begin
	i_add <= cnt;
	we_i  <= we;

	contador : process(clk)
	begin
		if rising_edge(clk) then
			--o_we <= '0';
			if rst = '1' then
				o_we <= '0';
				cnt  <= (others => '0');
			else
				if (we = '1') then
					cnt <= std_logic_vector(unsigned(cnt) + to_unsigned(1, log2(TAPS)));
				end if;
				o_we <= we_i;
			end if;
		end if;
	end process;

	ADD_PROCESS: process(clk)
	begin
		if rising_edge(clk) then
			if add_rst = '1' then
				o_add1_i <= (others => '0');
				o_add2_i <= (others => '0');
				c_add    <= (others => '0');
				j        <= (others => '0');
			elsif (add_e = '1') then
				o_add1_i <= std_logic_vector(unsigned(cnt) + j);
				o_add2_i <= std_logic_vector(unsigned(cnt) - j - 1);
				c_add    <= std_logic_vector(j);
				j        <= j + 1;
			end if;
		end if;
	end process;

	STATE_PROCESS : process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				state <= idle;
			elsif ce = '1' then
				state <= state_i;
			end if;
		end if;
	end process;

	NEXT_STATE : process(state, we, j)
	begin
		state_i <= state;
		case state is
			when idle =>
				if we = '1' then
					state_i <= count;
				end if;
			when count =>
				if j = 0 then
					state_i <= idle;
				end if;
		end case;
	end process;

	OUTPUT_STATE : process( state_i)
	begin
		if state_i = count then
			add_e   <= '1';
			add_rst <= '0';
		else
			add_e   <= '0';
			add_rst <= '1';
		end if;
	end process;

	o_add1 <= o_add1_i;
	o_add2 <= o_add2_i;

end architecture;