library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity preadd_mac is
	generic(
			N : integer := 17;
			N_PREADD : integer := 18;
			N_ADD : integer := 48
	);
	
	port (
		pre_input1 : in std_logic_vector(N-1 downto 0);
		pre_input2 : in std_logic_vector(N-1 downto 0);
		
		mul_input : in std_logic_vector(N downto 0);
		
		output : out std_logic_vector (N_ADD -1 downto 0);
		oe : out std_logic; -- outpue enable
		
		ce : in std_logic;
		clk : in std_logic;
		rst : in std_logic
	);
end entity preadd_mac;

architecture RTL of preadd_mac is
	signal pi1_resized : signed(N_PREADD-1 downto 0);
	signal pi2_resized : signed(N_PREADD-1 downto 0);
	signal pre: signed(N_PREADD-1 downto 0);
	signal mul: signed(N+N_PREADD-1 downto 0);
	signal mul_input_i: signed(N+N_PREADD-1 downto 0);
	signal mul_input_ii: signed(N+N_PREADD-1 downto 0);
	
	signal acc: signed(N+N_PREADD-1 downto 0);
	
	begin
	
	process (clk)
		variable cnt : integer range 0 to 4:=0;
	begin
		if rising_edge(clk) then
			if rst = '1' then
				pi1_resized<= (others => '0');
				pi2_resized <= (others => '0');
				mul_input_i <= (others => '0');
				mul_input_ii <= (others => '0');
				cnt := 0;
				oe <= '0';
			elsif ce = '1' then
				pi1_resized <= signed((N_PREADD downto N => '0')&pre_input1 );
				pi2_resized <= signed((N_PREADD downto N => '0')&pre_input2);
				mul_input_i <= signed(mul_input);
				mul_input_ii <= mul_input_i;
				if (cnt /= 4) then
					cnt := cnt + 1;
					oe <= '0';
				else
					oe <= '1';
				end if;
			end if;
		end if;
	end process;
	
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				pre<= (others => '0');
				mul <= (others => '0');
				acc <= (others => '0');
			elsif ce = '1' then
				pre <= pi1_resized + pi2_resized;
				mul <= pre * mul_input_ii;
				acc <= mul + acc;
			end if;
		end if;
	end process;
	
end architecture RTL;
