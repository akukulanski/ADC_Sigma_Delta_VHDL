library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comb is
	generic (
		N : integer :=10;
		DELAY : integer := 1
	);
	port (
		input : in std_logic_vector(N-1 downto 0);
		output: out std_logic_vector(N-1 downto 0);		
				
		ce : in std_logic;
		clk : in std_logic;
		rst : in std_logic
	);
end entity;

architecture RTL of comb is
	type delay_t is array(0 to DELAY-1) of std_logic_vector(N-1 downto 0);
	
	signal delay_line : delay_t;
	signal input_i,input_ii : std_logic_vector(N-1 downto 0):= (others=>'0');
	
begin
	input_i <= input;
	
	process (clk) is   --FF
	begin
		if  rising_edge(clk) then
			if (rst ='1' ) then
				for i in 0 to DELAY-1 loop
					delay_line(i) <= (others=>'0');
				end loop;
				input_ii<= (others=>'0');
			else
				if ce = '1' then
					delay_line(0)<=input_ii;
					input_ii<=input_i;
					for i in 0 to DELAY-2 loop
						delay_line(i+1) <= delay_line(i);
					end loop;
				end if;
			end if;
		end if;
	end process;
	
	
	res: output <= std_logic_vector (unsigned(input_ii) - unsigned(delay_line(DELAY-1)) );
		
end architecture RTL;
