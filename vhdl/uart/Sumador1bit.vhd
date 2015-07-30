----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:51:56 07/03/2014 
-- Design Name: 
-- Module Name:    Sumador1bit - Behavioral 
-- Project Name: 
-- Target Devices: 
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


entity Sumador1bit is
	port ( 
				ci : in std_logic;
				a : in std_logic;
				b : in std_logic;
				r : out std_logic;
				co : out std_logic
				);
end Sumador1bit;

architecture Behavioral of Sumador1bit is
begin
	r <= a xor b xor ci;
	co <= (a and b) or (a and ci) or (b and ci);
end Behavioral;

