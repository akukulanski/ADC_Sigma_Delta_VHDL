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
	constant FIR_MSB_OUT     : natural := 34; --bit m�s significativo de la salida (contando desde el bit 0)
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
	constant FIR_COEFFICIENTS : integer_array(0 to FIR_HALF_TAPS - 1) := (
		0,0,0,1,1,1,0,-1,-2,-2,-1,1,3,5,4,1,-3,-7,-9,-6,
		0,8,13,13,7,-5,-16,-22,-19,-6,13,28,33,23,0,-27,-46,-45,-24,13,
		49,68,57,18,-36,-80,-93,-64,-1,71,120,119,63,-30,-121,-167,-141,-46,82,187,
		218,152,8,-157,-268,-267,-144,60,258,359,305,105,-164,-386,-454,-321,-26,311,539,543,
		299,-107,-503,-709,-610,-222,305,745,886,636,71,-583,-1034,-1057,-599,180,955,1371,1203,465,
		-564,-1444,-1757,-1298,-189,1135,2093,2202,1306,-313,-2005,-3004,-2749,-1168,1221,3452,4465,3554,737,-3124,
		-6507,-7714,-5476,529,9436,19349,27859,32767
		);

--	constant FIR_COEFFICIENTS : integer_array(0 to FIR_HALF_TAPS - 1) := ( 4,3,2,1 );

end package constantes;
