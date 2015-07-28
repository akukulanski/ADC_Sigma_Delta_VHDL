library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity ram is
	generic(
		N    : natural := 6;            --ancho de palabra
		TAPS : natural := 128           --cantidad de palabras
	);
	port(
		input         : in  std_logic_vector(N - 1 downto 0);
		write_address : in  std_logic_vector(log2(TAPS) - 1 downto 0);

		output1       : out std_logic_vector(N - 1 downto 0) := (others => '0');
		output2       : out std_logic_vector(N - 1 downto 0) := (others => '0');

		read_address1 : in  std_logic_vector(log2(TAPS) - 1 downto 0);
		read_address2 : in  std_logic_vector(log2(TAPS) - 1 downto 0);

		we            : in  std_logic;  -- write enable
		ce            : in  std_logic;
		clk           : in  std_logic;
		rst           : in  std_logic
	);

end ram;

architecture RTL of ram is
	type ram_type is array (0 to TAPS - 1) of std_logic_vector(N - 1 downto 0);
	signal RAM                  : ram_type := (others => (others => '0'));
	signal ram_addr1            : std_logic_vector(log2(TAPS) - 1 downto 0);
	signal ram_addr2            : std_logic_vector(log2(TAPS) - 1 downto 0);
	signal output1_i, output2_i : std_logic_vector(N - 1 downto 0);
	--No es necesario los atribbute para block ram, por defecto lo es.
	--Si no cambiar el attribute a distributed.
	attribute ram_style : string;
	attribute ram_style of RAM : signal is "block"; --"distributed" or "block"
begin
	--la ram tiene solo dos address por eso se multiplexa
	--cuando se escribe en el address1 se lee(output1) la posición que se esta escribiendo.
	--read_address1 queda inutil
	ram_addr1 <= write_address when we = '1' else read_address1;
	ram_addr2 <= read_address2;

	output1 <= output1_i;
	output2 <= output2_i;
	--Para implementar con lut ram o block ram hay que hacer una pequena modificacion en el reset.
	--En nuestro caso la distributed ram pasa a ocupar el 8% de las luts con memoria sin aprovechar
	--sus funcionalidades.
	--Es preferible usar la block ram, que solo usamos el 3% del total disponible, aunque desaprovechando 
	--parte de la memoria reservada. (si son 256 entradas de 16 bits da 4Kb o sea
	--usamos el 50% de lo que reservamos).
	--Dejarlo escrito como block ram y poner attribute distributed funciona,
	--solo implementara una and entre we y ce, y una entre reset y ce.
	--Dejarlo escrito como distributed, no se lo puede implementar como block ram
	--por mas que se agrege el attribute block.

	read_write : process(clk)
	begin
		if rising_edge(clk) then
--			Asi funciona reset de la distributed ram
--			if rst='1' then
--				output1_i <= (others => '0');
--				output2_i <= (others => '0');
--			elsif
--			Asi chip enabled de la block ram
			if (ce = '1') then
				if (we = '1') then
					RAM(to_integer(unsigned(ram_addr1))) <= input;
				end if;
--				Aca chip enabled distributed ram
--				if (ce = '1') then
--				Asi funciona el reset de la block ram
				if rst = '1' then
					output1_i <= (others => '0');
					output2_i <= (others => '0');
				else
					output1_i <= RAM(to_integer(unsigned(ram_addr1)));
					output2_i <= RAM(to_integer(unsigned(ram_addr2)));
				end if;

			end if;
		end if;
	end process read_write;

end architecture;