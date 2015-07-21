
package mytypes_pkg is
		type my_array_t is array (0 to 12) of natural;-- 12=2*N; N etapas
end package mytypes_pkg;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.mytypes_pkg.all;
use work.extra_functions.all;

entity cic is

	Generic( 
		N: natural :=6;--etapas
		DELAY: natural :=1; -- delay restador
		R: natural :=512; --decimacion
		B: my_array_t := (55,55,51,43,35,28,24,23,22,21,21,20,17) --bits en cada etapa
	);
	port (
		input: in std_logic;
		output:out std_logic_vector(B(2*N)-1 downto 0);
		clk : in std_logic;
		rst : in std_logic;
		ce_in  : in std_logic;
		ce_out : out std_logic	
	);

end cic;

architecture RTL of cic is
	type signal_t is array(0 to N-1) of std_logic_vector(B(0) downto 0); 
		
	signal senI : signal_t; -- señales integrador
	signal senC : signal_t; -- señales comb
	signal ce_out_i: std_logic;
	
begin
	
	senC(0)<=senI(N-1); --último integrator directo a primer comb (hay que bufferear seguro)
	ce_out<=ce_out_i;
	
	acu1: entity work.integrator generic map( N=>1, M=>B(0)	)--primer acumulador
	port map (
		input => vectorize(input),
		output => senI(0)(B(0) downto 0),		
		ce => ce_in,
		clk => clk,
		rst => rst
	);
	
	g1: for i in 0 to N-2 generate
		
		acu: entity work.integrator generic map( N=>B(i+1), M=>B(i+1)	)--del segundo al N-esimo acumulador
		port map (
			input => senI(i)(B(i+1) downto 0),
			output => senI(i+1)(B(i+1) downto 0),		
			ce => ce_in,
			clk => clk,
			rst => rst
		);
		

		comb: entity work.comb generic map( N=>B(i +N), DELAY=>DELAY	)--del primer al (N-1)-esimo comb
		port map (
			input => senC(i)(B(i+N) downto 0),
			output => senC(i+1)(B(i+N) downto 0),		
			ce => ce_out_i,
			clk => clk,
			rst => rst
		);
	end generate g1;
	
		
	comb1: entity work.comb generic map( N=>B(2*N-1), DELAY=>DELAY	)-- ultimo comb
	port map (
		input => senC(N-1)(B(2*N-1) downto 0),
		output => output(B(2*N) downto 0),		
		ce => ce_out_i,
		clk => clk,
		rst => rst
	);
	
	
	
	dec: entity work.decimator generic map (R=>R)--decimador
	port map (
		--input => senI(N-1),
		--output => senC(0),
		ce_in => ce_in,
		ce_out =>ce_out_i,
		clk => clk,
		rst => rst
		);
	

end RTL;

