library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;

entity ram is
	generic(
		N    : natural := 16;            --ancho de palabra
		TAPS : natural := 256           --cantidad de palabras
	);
	port(
		input         : in  std_logic_vector(N - 1 downto 0);
		write_address : in  std_logic_vector(log2(TAPS) - 1 downto 0);

		output1       : out std_logic_vector(N - 1 downto 0)  := (others => '0');
		output2       : out std_logic_vector(N - 1 downto 0)  := (others => '0');

		read_address1 : in  std_logic_vector(log2(TAPS) - 1 downto 0);
		read_address2 : in  std_logic_vector(log2(TAPS) - 1 downto 0);

		we            : in  std_logic;  -- write enable

		ce            : in  std_logic;
		clk           : in  std_logic;
		rst           : in  std_logic
	);

end ram;

architecture RTL of ram is
	type ram_type is array (TAPS - 1 downto 0) of std_logic_vector(N - 1 downto 0);
	signal RAM                  : ram_type := (others => (others => '0'));
	signal ram_addr1            : std_logic_vector(log2(TAPS) - 1 downto 0);
	signal ram_addr2            : std_logic_vector(log2(TAPS) - 1 downto 0);
	signal output1_i, output2_i : std_logic_vector(N - 1 downto 0);
	--No es necesario los atribbute. implementa por defecto block ram
	--Si se quiere distributed hacer el cambio comentado antes del process.
	--attribute ram_style : string;
	--attribute ram_style of RAM : signal is "distributed"; --"distributed" or "block"
begin
	--la ram tiene solo dos address por eso se multiplexa
	--cuando se escribe en el address1 se lee(output1) la posici�n que se esta escribiendo.
	--read_address1 queda inutil
	ram_addr1 <= write_address when we = '1' else read_address1;
	ram_addr2 <= read_address2;

	output1 <= output1_i;
	output2 <= output2_i;
	--Para implementar con lut ram hay que hacer una peque�a modificaci�n(reset fuera del if ce=1...)
	--En nuestro caso pasa a ocupar el 8% de las luts con memoria sin aprovechar sus funcionalidades.
	--Es preferible usar la block ram, que solo usamos el 3% del total disponible, aunque desaprovechando 
	--parte de la memoria reservada. (si son 256 entradas de 16 bits da 4Kb o sea
	--usamos el 50% de lo que reservamos, por lo que se podr�a hacer FIR mayor orden).
	
	read_write : process(clk)         
	begin
		if rising_edge(clk) then
			if (ce = '1') then
				if (we = '1') then
					RAM(to_integer(unsigned(ram_addr1))) <= input;
				end if;
					if rst = '1' then --As� funciona el reset de la block ram, no tocar
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