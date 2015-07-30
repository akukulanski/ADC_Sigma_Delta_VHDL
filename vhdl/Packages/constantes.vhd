library IEEE;
use IEEE.STD_LOGIC_1164.all;

package constantes is
	----- Constantes del ADC -------------
	constant BIT_OUT			: natural :=16;
	constant CIC_N_ETAPAS		: natural :=6;
	constant CIC_COMB_DELAY		: natural :=1;
	constant CIC_R				: natural :=512; --decimacion
	
	type my_array_t is array (0 to 2*CIC_N_ETAPAS) of natural; -- 12=2*N; N etapas
	constant CIC_COEFFICIENTS : my_array_t:=(55,55,50,42,34,27,23,22,21,20,20,19,16);
	
	constant CIC_OUTPUT_BITS 	: natural:= CIC_COEFFICIENTS(2*CIC_N_ETAPAS);
	constant FIR_INPUT_BITS		: natural:= CIC_OUTPUT_BITS;	
			
	---- Constantes del FIR -------------------
	constant FIR_B				: natural:=16;
	constant FIR_N_COEFF		: natural :=128;
	constant FIR_OUTPUT_BITS 	: natural :=20;
	constant FIR_R				: natural :=4; --decimacion
	constant DSP_INPUT_BITS 	: natural :=18;
	constant DSP_OUTPUT_BITS	: natural :=48;

	type coeff_t is array (0 to FIR_N_COEFF-1) of integer range -2**(FIR_B-1) to 2**(FIR_B-1)-1;
	constant FIR_COEFFICIENTS: coeff_t:=
		(0,0,0,0,1,1,1,0,-1,-2,-2,0,3,4,4,0,-4,-7,-6,-1,
		6,11,9,1,-10,-16,-14,-2,14,23,20,3,-19,-32,-28,-4,26,44,38,7,
		-34,-60,-51,-10,44,78,68,14,-57,-102,-89,-19,72,130,115,26,-90,-164,-146,-35,
		111,205,184,47,-135,-254,-229,-61,163,311,284,79,-196,-380,-350,-102,233,460,428,130,
		-277,-555,-521,-165,327,667,633,209,-385,-802,-769,-264,453,964,936,333,-534,-1164,-1145,-424,
		634,1416,1414,544,-760,-1747,-1775,-712,925,2203,2287,961,-1161,-2887,-3085,-1373,1529,4043,4519,2187,
		-2208,-6499,-7959,-4580,3821,15245,26138,32767
		);
	
	----- Constantes del CIC para testbench -------------
	-- Cambiar los valores segun sea necesario en el TB --
	constant TB_CIC_N_ETAPAS 	: natural :=6;
	constant TB_CIC_COMB_DELAY	: natural :=1;
	constant TB_CIC_R			: natural :=512; -- Decimación del cic
	constant TB_CIC_COEFFICIENTS : my_array_t:=(55,55,50,42,34,27,23,22,21,20,20,19,16);
	-- constant TB_CIC_COEFFICIENTS : my_array_t:=(55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55, 55); --bits en cada etapa
	
	---- Constantes del FIR para testbench -------------
	-- Cambiar el valor seguns sea necesario en el TB --
	constant TB_FIR_B				: natural :=16;
	constant TB_FIR_INPUT_BITS		: natural :=16;
	constant TB_FIR_N_COEFF			: natural :=128;
	constant TB_FIR_OUTPUT_BITS 	: natural :=48;
	
	-- Constantes del DSP --
	constant TB_DPS_INPUT_BITS		: natural:=18;
	constant TB_DPS_OUTPUT_BITS		: natural:=48;
	
	constant TB_FIR_COEFFICIENTS: coeff_t:=
		(0,0,0,0,1,1,1,0,-1,-2,-2,0,3,4,4,0,-4,-7,-6,-1,
		6,11,9,1,-10,-16,-14,-2,14,23,20,3,-19,-32,-28,-4,26,44,38,7,
		-34,-60,-51,-10,44,78,68,14,-57,-102,-89,-19,72,130,115,26,-90,-164,-146,-35,
		111,205,184,47,-135,-254,-229,-61,163,311,284,79,-196,-380,-350,-102,233,460,428,130,
		-277,-555,-521,-165,327,667,633,209,-385,-802,-769,-264,453,964,936,333,-534,-1164,-1145,-424,
		634,1416,1414,544,-760,-1747,-1775,-712,925,2203,2287,961,-1161,-2887,-3085,-1373,1529,4043,4519,2187,
		-2208,-6499,-7959,-4580,3821,15245,26138,32767
		);
end package constantes;
