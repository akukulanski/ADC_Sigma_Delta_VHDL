library ieee;
use ieee.std_logic_1164.all;

package extra_functions is
    function vectorize ( s : std_logic ) return  std_logic_vector;
end package extra_functions;

package body extra_functions is
	
	function vectorize(s: std_logic) return std_logic_vector is
		variable v: std_logic_vector(0 downto 0);
		begin
		v(0) := s;
		return v;
	end function;
	
end package body extra_functions;