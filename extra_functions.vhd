library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

package extra_functions is
	function vectorize(s : std_logic) return std_logic_vector;
	function log2 (x : positive) return natural;
end package extra_functions;

package body extra_functions is
	function vectorize(s : std_logic) return std_logic_vector is
		variable v : std_logic_vector(0 downto 0);
	begin
		v(0) := s;
		return v;
	end function;
	
	function log2 (x : positive) return natural is
   begin
      return natural(ceil(log2(real(x))));
   end function;

end package body extra_functions;