----------------------------------------------------------------------------------
-- Company: DPLAB
-- Engineer: Andres Demski
-- 
-- Create Date:    15:52:06 07/03/2014 
-- Design Name: Sumador
-- Module Name:    Sumador - Behavioral 
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

entity Sumador is
	generic (
					N: integer := 8 );
	port (
				ci : in std_logic;
				a : in std_logic_vector (N-1 downto 0);
				b : in std_logic_vector (N-1 downto 0) ;
				r : out std_logic_vector (N-1 downto 0);
				co: out std_logic );
				
end Sumador;

architecture Behavioral of Sumador is
	
	
	component Sumador1bit is
	port ( 
				ci : in std_logic;
				a : in std_logic;
				b : in std_logic;
				r : out std_logic;
				co : out std_logic
				);
	end component;

	signal Carrys : std_logic_vector (N downto 0) := (others=>'0');
	
begin
	Carrys(0) <= ci;
	sums:
   for i in 0 to N-1 generate
      begin
         s: Sumador1bit port map ( 
							ci => Carrys(i) ,
							a => a(i) ,
							b => b(i),
							r => r(i),
							co => Carrys(i+1)
							);
   end generate;
	co <= Carrys(N);
end Behavioral;

