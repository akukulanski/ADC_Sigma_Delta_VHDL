library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.extra_functions.all;           -- para log2()
use work.constantes.all;
use std.standard.all;

entity fir is
	generic(
		N     : natural := FIR_INPUT_BITS; --cantidad bits input (viene del cic)
		B     : natural := FIR_COEFF_BITS; -- cantidad bits coeficientes esta en el package incluido arriba
		M     : natural := FIR_OUTPUT_BITS; --cant bits salida
		TAPS  : natural := 2 * FIR_HALF_TAPS; --longitud filtro fir
		N_DSP : natural := DSP_INPUT_BITS; --cant de bits de entrada del dsp
		M_DSP : natural := DSP_OUTPUT_BITS --cant de bits de salida del dsp
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
	-- conversion de la entrada (binario desplazado --> CA2)
	signal input_ca2 : std_logic_vector(N - 1 downto 0) := (others => '0');

	-- senales referidas a la ram
	signal ram_we                                      : std_logic                                     := '0';
	signal write_address, read_address1, read_address2 : std_logic_vector(log2(TAPS) - 1 downto 0)     := (others => '0');
	signal coef_address                                : std_logic_vector(log2(TAPS / 2) - 1 downto 0) := (others => '0');
	signal ram_output1, ram_output2                    : std_logic_vector(N - 1 downto 0)              := (others => '0');

	-- senales referidas al dsp
	signal adder_input1, adder_input2 : std_logic_vector(N - 1 downto 0)     := (others => '0');
	signal ROM                        : integer_array(0 to TAPS / 2 - 1)     := FIR_COEFFICIENTS;
	signal coef_input, coef_input_i   : std_logic_vector(B - 1 downto 0);
	signal dsp_output                 : std_logic_vector(M_DSP - 1 downto 0) := (others => '0');
	signal enable_mac_new_input       : std_logic                            := '0';
	signal rst_mac                    : std_logic;

	--rom_style
	attribute rom_style : string;
	attribute rom_style of ROM : signal is "block"; --"distributed" or "block"

begin

	--coef_input(0 downto 0) <= "1";
	input_ca2 <= not (data_in(N - 1)) & data_in(N - 2 downto 0);
	data_out  <= dsp_output(FIR_MSB_OUT downto FIR_MSB_OUT-BIT_OUT+1); --bits mas significativos de dsp_outout
	rst_mac   <= (ram_we or rst);       --resetea cuando hay dato nuevo o cuando se activa el rst general del fir

	-- cuando el dsp esta habilitado realiza operaciones
	-- cuando la entrada vale cero, sigue funcionando (procesa los datos demorados
	-- por el pipeline) pero sus siguientes operaciones (sumar cero) fuerzan que
	-- se mantenga el ultimo dato valido calculado
	adder_input1 <= ram_output1;        --when enable_mac_new_input = '1' else (others => '0');
	adder_input2 <= ram_output2;        -- when enable_mac_new_input = '1' else (others => '0');
	--NO poner el when, igual las entradas serian cero y la mult cero.
	coef_input   <= coef_input_i;

	Lectura_ROM : process(clk) is
	begin
		if rising_edge(clk) then
			if ce = '1' then
				if rst = '1' then
					coef_input_i <= (others => '0');
				else
					coef_input_i <= std_logic_vector(to_signed(ROM(to_integer(unsigned(coef_address))), B));
				end if;
			end if;
		end if;
	end process Lectura_ROM;

	-- address generator: se ocupa de controlar las posiciones de lectura/escritura de la
	-- ram para que lleguen los valores correctos al dsp
	address_gen : entity work.address_generator
		generic map(
			TAPS => TAPS
		)
		port map(
			write_address        => write_address,
			read_address1        => read_address1,
			read_address2        => read_address2,
			coef_address         => coef_address,
			we                   => we,
			o_we                 => ram_we,
			enable_mac_new_input => enable_mac_new_input,
			oe                   => oe,
			ce                   => ce,
			clk                  => clk,
			rst                  => rst
		);

	ram : entity work.RAM
		generic map(
			N    => N,
			TAPS => TAPS
		)
		port map(
			input         => input_ca2,
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

	preadder : entity work.preadd_mac   --preadder
		generic map(
			-- corregir nombres para que no sea confuso
			N_in_pre => N,
			N_in_mul => B,
			N        => N_DSP,
			N_OUT    => M_DSP
		)
		port map(
			adder_input1 => adder_input1,
			adder_input2 => adder_input2,
			coef_input   => coef_input_i,
			output       => dsp_output,
			ce           => enable_mac_new_input, --ce
			clk          => clk,
			rst          => rst_mac
		);

end architecture RTL;
