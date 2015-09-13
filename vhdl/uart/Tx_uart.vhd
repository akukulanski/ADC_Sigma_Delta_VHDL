library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.floor;

use work.extra_functions.all;
entity Tx_uart is
	generic(
		BITS : natural :=8;
		CORE : natural := 50000000;
		BAUDRATE : natural := 912600 
	);
	port (
		Tx : out std_logic;
		Load : in std_logic_vector(BITS-1 downto 0);
		LE : in std_logic;
		Tx_busy : out std_logic;
		clk : in std_logic;
		rst : in std_logic
	);
end entity Tx_uart;

architecture RTL of Tx_uart is
	type state_type is (IDLE, STARTING, SENDING, STOPING);
	
	constant TIMER_TIME : natural := CORE/BAUDRATE;
	constant TIMER_BITS : natural := log2(TIMER_TIME);
	
	
	signal state,state_i : state_type:= IDLE;
	signal Tx_i : std_logic:= '0';
	signal Tx_busy_i : std_logic:='0';
	
	signal rst_count,rst_count_i : std_logic:= '0';
	signal count : std_logic_vector(log2(BITS) downto 0);
	
	signal timer_e,timer_e_i, timer_start, timer_start_i,timer_finish: std_logic := '0';
	signal timer, timer_count,timer_i :std_logic_vector(TIMER_BITS-1 downto 0);
	
	signal data : std_logic_vector(BITS-1 downto 0):= (others=>'0');
	
	signal Tx_aux : std_logic := '1';
	signal Tx_busy_aux : std_logic := '0';
begin

	process(clk,rst)
	begin
		if rst='1' then
			state <= IDLE;
			Tx_aux  <= '1';
		elsif rising_edge(clk) then
			state <= state_i;
			Tx_aux <= Tx_i;
			timer <= timer_i;
			timer_e <= timer_e_i;
			timer_start <= timer_start_i;
			rst_count <= rst_count_i;
			Tx_busy_aux <= Tx_busy_i;
			if LE='1' then 
				data <= load; 	
			end if;
		end if;
	end process;

	Tx <= Tx_aux;
	Tx_busy <= Tx_busy_aux;
	OUT_STATE: process (timer_e,Tx_aux,Tx_busy_aux,LE,data,state,state_i,Tx_i,timer_i,rst_count_i,timer_start_i, timer_finish, count,Tx_busy_i)
	begin
		state_i <= state;
		Tx_i <= Tx_aux;
		timer_i <= timer;		
		rst_count_i <= rst_count;
		timer_start_i <= timer_start;
		Tx_busy_i <= Tx_busy_aux;
		timer_e_i <= timer_e;
		case state is
		when IDLE => 
				Tx_i <= '1';
				Tx_busy_i <= '0';
				if LE='1' then
					Tx_busy_i <= '1';
					state_i <= STARTING;
					timer_i <= std_logic_vector(to_unsigned(TIMER_TIME-3,timer_count'length));
					timer_e_i <= '1';
					timer_start_i <= '1';
					Tx_i <= '0';
				end if;	
			when STARTING =>
				timer_start_i <= '0';
				if timer_finish='1' then
					state_i <= SENDING;
					timer_i <= std_logic_vector(to_unsigned(TIMER_TIME-1,timer_count'length));
					rst_count_i <= '1';
					Tx_i <= data(0);					
				end if;								
				
			when SENDING =>
				rst_count_i <= '0';
				Tx_i <= data(to_integer(unsigned(count(count'length-2 downto 0) )));	 				
				if count(count'length-1)='1' then
					rst_count_i <= '1';
					state_i <= STOPING;
					Tx_i <= '1';					
				end if;
			when STOPING => 			
				if timer_finish='1' then
					Tx_busy_i <= '0';
					state_i <= IDLE;
					timer_start_i <= '0';
					Tx_i <= '1';					
				end if;	
			
		end case;				
	end process;	
	
	COUNTER_PROC: process(clk,Rst_count)
	begin
		if Rst_count='1' then
			count <= (others=>'0');
		elsif rising_edge(clk) then
			if (timer_finish = '1') then
				count <= std_logic_vector(unsigned(count)+to_unsigned(1,count'length));
			end if;
		end if;
	end process;

	TIMER_PROC: process(clk,timer_start)
	begin
		if timer_start='1' then
			timer_count <= (others=>'0');
			timer_finish <= '0';
		elsif rising_edge(clk) then
			if (timer_e = '1') then
				timer_count <= std_logic_vector(unsigned(timer_count)+to_unsigned(1,timer_count'length));
				timer_finish <= '0';
				if timer_count=timer then
					timer_finish <= '1';
					timer_count <= (others=>'0');
				end if;
			end if;
		end if;
	end process;
	

end architecture RTL;
