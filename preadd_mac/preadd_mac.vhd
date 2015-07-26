library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity preadd_mac is
	generic(
			N : integer := 17; -- SE DEBE CONVERTIR a CA2!!!
			N_OUT : integer := 48
	);
	
	port (
		adder_input1 : in std_logic_vector(N-1 downto 0);
		adder_input2 : in std_logic_vector(N-1 downto 0);
		coef_input : in std_logic_vector(N downto 0);
		
		output : out std_logic_vector (N_OUT -1 downto 0);
		
		ce : in std_logic;
		clk : in std_logic;
		rst : in std_logic
	);
end entity preadd_mac;

architecture RTL of preadd_mac is
	signal adder_input1_resized : std_logic_vector(N downto 0):=std_logic_vector(to_signed(0,N+1));
	signal adder_input2_resized : std_logic_vector(N downto 0):=std_logic_vector(to_signed(0,N+1));
	signal pre: std_logic_vector(N downto 0):=std_logic_vector(to_signed(0,N+1));
	signal mul: std_logic_vector(2*N+1 downto 0):=std_logic_vector(to_signed(0,2*N+2));
	signal coef_input_i: std_logic_vector(N downto 0):=std_logic_vector(to_signed(0,N+1));
	signal coef_input_ii: std_logic_vector(N downto 0):=std_logic_vector(to_signed(0,N+1));
	
	signal acc: std_logic_vector(N_OUT-1 downto 0):=std_logic_vector(to_signed(0,N_OUT));
	
begin
	output <= std_logic_vector(acc);
	adder_input1_resized <= adder_input1(N-1) & adder_input1;
	adder_input2_resized <= adder_input2(N-1) & adder_input2;
	
load_values: process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
--				adder_input1_resized(N-1 downto 0) <= (others => '0');
--				adder_input2_resized(N-1 downto 0) <= (others => '0');
				coef_input_i <= (others => '0');
--				coef_input_ii <= (others => '0');
			elsif ce = '1' then
--				adder_input1_resized(N-1 downto 0) <= adder_input1;
--				adder_input2_resized(N-1 downto 0) <= adder_input2;
				coef_input_i <= coef_input;
--				coef_input_ii <= coef_input_i;
			end if;
		end if;
	end process;
	
make_operations: process (clk)
	begin
		if rising_edge(clk) then
			pre <= pre;
			mul <= mul;
			acc <= acc;
			if rst = '1' then
				pre<= (others => '0');
				mul <= (others => '0');
				acc <= (others => '0');
			elsif ce = '1' then
				pre <= std_logic_vector(signed(adder_input1_resized) + signed(adder_input2_resized));
--				mul <= std_logic_vector(signed(pre) * signed(coef_input_ii));
				mul <= std_logic_vector(signed(pre) * signed(coef_input_i));
				acc <= std_logic_vector(signed(mul) + signed(acc));
			end if;
		end if;
	end process;
	
end architecture RTL;
