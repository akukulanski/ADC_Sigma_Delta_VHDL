library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.floor;

use work.extra_functions.all;
use work.constantes.all;

entity FIR_UART_TB is
end entity FIR_UART_TB;

architecture RTL of FIR_UART_TB is
	signal clk    : std_logic;
	signal rst    : std_logic;
	signal rx, tx : std_logic := '0';

	-- Un periodo de reloj arbitrario
	constant PERI_CLK : time := 10 ns;

begin
	DUT : entity work.fir_uart
		generic map(
			N         => FIR_INPUT_BITS,
			B         => FIR_COEFF_BITS,
			M         => FIR_OUTPUT_BITS,
			TAPS      => 2 * FIR_HALF_TAPS,
			N_DSP     => DSP_INPUT_BITS,
			M_DSP     => DSP_OUTPUT_BITS,
			Bits_UART => 8,
			Baudrate  => 921600,
			Core      => 50000000
		)
		port map(
			clk => clk,
			rst => rst,
			rx  => rx,
			tx  => tx
		);

	CLOCK : process is
	begin
		wait for PERI_CLK;
		clk <= '1';
		wait for PERI_CLK;
		clk <= '0';
	end process;

	rst <= '1', '0' after PERI_CLK * 3 / 2;

	RX_PROC : process is
		variable i : integer := 0;
		variable j : integer := 0;
		variable aux : integer :=0;
	begin
		rx <= '1';
		wait for 100 us;                -- 01110011
		rx <= '0';                      -- StartBit
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '1';                      -- Stop Bit
		wait for 1.085 us;
	
		rx <= '0';                      -- StartBit
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '0';
		wait for 1.085 us;
		rx <= '1';
		wait for 1.085 us;
		rx <= '1';                      -- Stop Bit
		wait for 1.085 us;
	

		for j in 0 to (256 - 1) loop
			rx <= '0';                  -- StartBit
			wait for 1.085 us;
			while i < 8 loop
				-- Simulando a la entrada codificación binario desplazado
				-- es decir, lo que entregaría el CIC a su salida
				-- Se envía 0x8000 (equivalente a cero)
				if (i = 7 and aux=1) then
					report "111111111" severity note;
					rx <= '1'; 
					wait for 1.085 us;
					i := i + 1;
				else
					report "222222222" severity note;
					rx <= '0';
					wait for 1.085 us;
					i := i + 1;
				end if;
			end loop;
			if (aux=1) then
				report "3333333333" severity note;
				aux:=0;
			else
				report "4444444444" severity note;
				aux:=1;
			end if;
			i  := 0;
			rx <= '1'; -- Stop Bit
			wait for 1.085 us;
		end loop;

		report "Finalizó!!!!!!!!!!!!!!!!!!" severity failure;
	end process;
end architecture RTL;
	