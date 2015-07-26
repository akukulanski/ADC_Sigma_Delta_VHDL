library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;           -- para log2()

entity fir is
	generic(
		N    : natural := 17;           --cantidad bits input (viene del cic)
		M    : natural := 48;           --cant bits salida
		TAPS : natural := 8           --cant coeficientes fir
	);
	port(
		clk      : in  std_logic;
		rst      : in  std_logic;
		ce       : in  std_logic;
		we       : in  std_logic;
		data_in  : in  std_logic_vector(N - 1 downto 0);

		data_out : out std_logic_vector(M - 1 downto 0);
		oe       : out std_logic
	);
end entity fir;

architecture RTL of fir is
	signal data_in_i                                   : std_logic_vector(N - 1 downto 0)              := (others => '0');
	signal write_address, read_address1, read_address2 : std_logic_vector(log2(TAPS) - 1 downto 0)     := (others => '0');
	signal adder_input1, adder_input2                  : std_logic_vector(N - 1 downto 0)              := (others => '0');
	signal ram_output1,ram_output2                  : std_logic_vector(N - 1 downto 0)              := (others => '0');
	signal coef_input                                  : std_logic_vector(N downto 0)                  := (others => '0');
	signal s_output                                    : std_logic_vector(M - 1 downto 0)              := (others => '0');
	signal coef_address                                : std_logic_vector(log2(TAPS / 2) - 1 downto 0) := (others => '0');
	signal ram_we                                      : std_logic                                     := '0';
	signal enable_mac_new_input: std_logic := '0';

begin
	-- pruebas con todos los coeficientes = 0x01
	coef_input(0 downto 0) <= "1";
	data_in_i <= data_in;
	data_out <= s_output;
	
	adder_input1 <= ram_output1 when enable_mac_new_input='1' else
        (others=>'0');
	adder_input2 <= ram_output2 when enable_mac_new_input='1' else
        (others=>'0');
	
	address_gen : entity work.address_generator --address generator
		generic map(
			TAPS => TAPS
		)
		port map(
			write_address => write_address,
			read_address1 => read_address1,
			read_address2 => read_address2,
			coef_address  => coef_address,
			we            => we,
			o_we          => ram_we,
			ce            => ce,
			clk           => clk,
			rst           => rst,
			oe            => oe,
			enable_mac_new_input	  => enable_mac_new_input	

		);

	ram : entity work.RAM
		generic map(
			N    => N,
			TAPS => TAPS
		)
		port map(
			input         => not (data_in_i(N - 1)) & data_in_i(N - 2 downto 0),
			-- NOTA: se convirtió de binario
			-- desplazado a CA2 para luego usar
			-- el signo en el multiplicador
			write_address => write_address,
			output1       => ram_output1,
			output2       => ram_output2,
			read_address1 => read_address1,
			read_address2 => read_address2,
			we            => ram_we,
			ce            => ce,
			clk           => clk,
			rst           => rst

		);

	-- EDITAR DESDE ACA
	preadder : entity work.preadd_mac   --preadder
		generic map(
			N     => N,
			N_OUT => M --
		)
		port map(
			adder_input1 => adder_input1,
			adder_input2 => adder_input2,
			coef_input  => coef_input,
			output     => s_output,
			ce         => ce,
			clk        => clk,
			rst        => (ram_we or rst) --reseteo acumulador con escritura de la ram (c/ nueva muestra)
		);

end architecture RTL;
