library IEEE;
use IEEE.STD_LOGIC_1164.all;
use std.standard.all;

package constantes is
	type natural_array is array (natural range <>) of natural; --tipo para los bits en cada etapa cic
	type integer_array is array (natural range <>) of integer;
	----- Constantes del ADC -------------
	constant BIT_OUT : natural := 16;   --bits salida adc

	-- Constantes CIC--
	constant CIC_N_ETAPAS   : natural                              := 6; -- etapas cic
	constant CIC_COMB_DELAY : natural                              := 1; --delay antes de restar en el comb
	constant CIC_R          : natural                              := 512; --decimacion
	--constant CIC_STAGE_BITS  : natural_array(0 to 2 * CIC_N_ETAPAS) := (55, 55, 50, 42, 34, 27, 23, 22, 21, 20, 20, 19, 17); --bits en cada etapa
	constant CIC_STAGE_BITS : natural_array(0 to 2 * CIC_N_ETAPAS) := (55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 16); --bits en cada etapa

	--		--0 a CIC_N_ETAPAS-1: tamaños acumuladores
	--		--CIC_N_ETAPAS a 2*CIC_N_ETAPAS-1: tamaños restadores comb
	--		--2*CIC_N_ETAPAS: Cantidad bits salida CIC
	constant CIC_OUTPUT_BITS : natural := CIC_STAGE_BITS(2 * CIC_N_ETAPAS); --Cantidad bits salida CIC

	---- Constantes del FIR simetrico (longitud par) -------------------
	constant FIR_INPUT_BITS  : natural := CIC_OUTPUT_BITS; --cantidad bits entrada fir	
	constant FIR_COEFF_BITS  : natural := 16; --cantidad bits coeficientes fir
	--FIR_HALF_TAPS es la mitad de la longitud filtro FIR
	--Esta es la cantidad de coeficientes a guardar, ya que es simetrico.
	--El orden filtro FIR es = 2*FIR_HALF_N_COEFF+1
	constant FIR_HALF_TAPS   : natural := 128;
	constant FIR_OUTPUT_BITS : natural := 16; --cantidad bits salida fir
	constant FIR_MSB_OUT     : natural := 34; --bit más significativo de la salida (contando desde el bit 0)
	constant FIR_R           : natural := 4; --decimacion en el fir
	constant DSP_INPUT_BITS  : natural := 18; --cantidad de bits de entrada al dsp
	constant DSP_OUTPUT_BITS : natural := 48; --cantidad de bits salida del dsp

	--tipo para los coeficientes del fir
	--type coeff_t is array (0 to FIR_HALF_TAPS - 1) of integer range -2 ** (FIR_COEFF_BITS - 1) to 2 ** (FIR_COEFF_BITS - 1) - 1;
	--coeficientes del fir (la primer mitad)
	constant FIR_COEFFICIENTS : integer_array(0 to FIR_HALF_TAPS - 1) := (
		0, 0, 0, 0, 1, 1, 1, 0, -1, -2, -2, 0, 3, 4, 4, 0, -4, -7, -6, -1,
		6, 11, 9, 1, -10, -16, -14, -2, 14, 23, 20, 3, -19, -32, -28, -4, 26, 44, 38, 7,
		-34, -60, -51, -10, 44, 78, 68, 14, -57, -102, -89, -19, 72, 130, 115, 26, -90, -164, -146, -35,
		111, 205, 184, 47, -135, -254, -229, -61, 163, 311, 284, 79, -196, -380, -350, -102, 233, 460, 428, 130,
		-277, -555, -521, -165, 327, 667, 633, 209, -385, -802, -769, -264, 453, 964, 936, 333, -534, -1164, -1145, -424,
		634, 1416, 1414, 544, -760, -1747, -1775, -712, 925, 2203, 2287, 961, -1161, -2887, -3085, -1373, 1529, 4043, 4519, 2187,
		-2208, -6499, -7959, -4580, 3821, 15245, 26138, 32767
	);
end package constantes;
