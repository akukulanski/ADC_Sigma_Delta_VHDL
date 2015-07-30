----------------------------------------------------------------------------------
-- Company: DPLAB
-- Engineer: Andres Demski
-- 
-- Create Date:    19:25:12 08/24/2014 
-- Design Name: Paridad
-- Module Name:    Paridad - Behavioral 
-- Project Name: UART
-- Target Devices: MOJOv3
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Paridad is
	generic (
					N : integer := 8
					);
	port (
				input : in std_logic_vector (N-1 downto 0);
				p : out std_logic
				);
end Paridad;

architecture Behavioral of Paridad is
	signal vector : std_logic_vector (N-1 downto 0);
begin
	vector(0) <= input(0);
	par:
   for i in 0 to N-2 generate
      begin
         vector (i+1) <= input(i+1) xor vector (i);
   end generate;
	p <= vector (N-1);		

end Behavioral;

