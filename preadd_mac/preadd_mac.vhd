library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity preadd_mac is
	generic(
			N : integer := 17; -- SE DEBE CONVERTIR a CA2!!!
			--N_PREADD : integer := 18;
			N_OUT : integer := 48
	);
	
	port (
		pre_input1 : in std_logic_vector(N-1 downto 0);
		pre_input2 : in std_logic_vector(N-1 downto 0);
		--mul_input : in std_logic_vector(N_PREADD-1 downto 0);
		mul_input : in std_logic_vector(N downto 0); --N+1 bits
		
		output : out std_logic_vector (N_OUT -1 downto 0);
		
		oe:		out std_logic:='0';
		
		ce : in std_logic;
		clk : in std_logic;
		rst : in std_logic
	);
end entity preadd_mac;

architecture RTL of preadd_mac is
	signal pi1_resized : std_logic_vector(N downto 0);
	signal pi2_resized : std_logic_vector(N downto 0);
	signal pre: std_logic_vector(N downto 0);
	--signal mul: std_logic_vector(N_PREADD*2-1 downto 0);
	--signal mul: std_logic_vector((N+1)*2-1 downto 0);
	signal mul: std_logic_vector(2*N+1 downto 0);
	signal mul_input_i: std_logic_vector(N downto 0);
	signal mul_input_ii: std_logic_vector(N downto 0);
	
	signal acc: std_logic_vector(N_OUT-1 downto 0);
	
	begin
	pi1_resized(N downto N)<=(others=>'0');
	pi2_resized(N downto N)<=(others=>'0');
	
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				pi1_resized(N-1 downto 0) <= (others => '0');
				pi2_resized(N-1 downto 0) <= (others => '0');
				mul_input_i <= (others => '0');
				mul_input_ii <= (others => '0');
			elsif ce = '1' then
				pi1_resized(N-1 downto 0) <= pre_input1;
				pi2_resized(N-1 downto 0) <= pre_input2;
				mul_input_i <= mul_input;
				mul_input_ii <= mul_input_i;
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
				pre <= std_logic_vector(signed(pi1_resized) + signed(pi2_resized));
				mul <= std_logic_vector(signed(pre) * signed(mul_input_ii));
				acc <= std_logic_vector(signed(mul) + signed(acc));
			end if;
		end if;
	end process;
	
	output <= std_logic_vector(acc);
end architecture RTL;
