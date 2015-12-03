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

	--		--0 a CIC_N_ETAPAS-1: tama�os acumuladores
	--		--CIC_N_ETAPAS a 2*CIC_N_ETAPAS-1: tama�os restadores comb
	--		--2*CIC_N_ETAPAS: Cantidad bits salida CIC
	constant CIC_OUTPUT_BITS : natural := CIC_STAGE_BITS(2 * CIC_N_ETAPAS); --Cantidad bits salida CIC

	---- Constantes del FIR simetrico (longitud par) -------------------
	constant FIR_INPUT_BITS  : natural := CIC_OUTPUT_BITS; --cantidad bits entrada fir	
	constant FIR_COEFF_BITS  : natural := 16; --cantidad bits coeficientes fir
	--FIR_HALF_TAPS es la mitad de la longitud filtro FIR
	--Esta es la cantidad de coeficientes a guardar, ya que es simetrico.
	--El orden filtro FIR es = 2*FIR_HALF_N_COEFF+1
	constant FIR_HALF_TAPS   : natural := 128; --4
	constant FIR_OUTPUT_BITS : natural := 16; --cantidad bits salida fir
	constant FIR_MSB_OUT     : natural := 33; --bit m�s significativo de la salida (contando desde el bit 0)
	constant FIR_R           : natural := 4; --decimacion en el fir
	constant DSP_INPUT_BITS  : natural := 18; --cantidad de bits de entrada al dsp
	constant DSP_OUTPUT_BITS : natural := 48; --cantidad de bits salida del dsp

	--tipo para los coeficientes del fir
	--type coeff_t is array (0 to FIR_HALF_TAPS - 1) of integer range -2 ** (FIR_COEFF_BITS - 1) to 2 ** (FIR_COEFF_BITS - 1) - 1;
	--coeficientes del fir (la primer mitad)
	
--	constant FIR_COEFFICIENTS : integer_array(0 to FIR_HALF_TAPS - 1) := (
--		-32,-1,6,15,20,19,11,-3,-16,-22,-18,-3,17,32,35,22,-3,-29,-45,-41,
--		-18,18,49,62,47,8,-38,-73,-77,-45,11,68,100,89,35,-40,-105,-127,-93,-12,
--		82,148,151,85,-26,-136,-193,-166,-61,82,200,236,166,15,-157,-271,-270,-145,57,249,
--		343,287,95,-155,-355,-407,-278,-11,282,468,455,232,-113,-433,-580,-473,-141,280,606,679,
--		448,-5,-491,-790,-751,-365,218,746,975,776,206,-505,-1042,-1146,-734,50,878,1376,1285,595,
--		-433,-1358,-1747,-1368,-317,991,1982,2163,1358,-178,-1827,-2839,-2657,-1191,1073,3209,4196,3349,684,-2966,
--		-6131,-7169,-4854,1116,9892,19623,27962,32767
--	);

-- TESTING:
	constant FIR_COEFFICIENTS : integer_array(0 to FIR_HALF_TAPS - 1) :=
		(0,0,0,-1,-1,-1,0,2,2,2,1,-2,-4,-4,-3,1,5,8,7,2,
		-6,-11,-12,-7,3,14,20,17,4,-13,-26,-29,-17,6,29,42,35,10,-25,-53,
		-58,-35,10,56,81,69,20,-46,-98,-107,-65,16,100,144,123,37,-78,-168,-185,-113,
		24,165,241,206,66,-123,-273,-304,-188,33,261,385,332,111,-189,-426,-478,-301,42,399,
		596,520,181,-279,-649,-736,-472,50,598,907,802,293,-409,-981,-1129,-738,54,900,1392,1251,
		481,-608,-1517,-1780,-1196,46,1412,2247,2074,849,-964,-2553,-3102,-2181,-12,2543,4285,4191,1922,-1896,
		-5759,-7762,-6303,-755,8159,18463,27498,32767
		);
--	constant FIR_COEFFICIENTS : integer_array(0 to FIR_HALF_TAPS - 1) := ( 4,3,2,1 );

end package constantes;
