library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.floor;

use work.extra_functions.all;
entity Rx_uart is
	generic(
		BITS : natural :=8;
		CORE : natural := 100000000;
		BAUDRATE : natural := 912600 
	);
	port (
		rx : in std_logic;
		oe : out std_logic;
		output : out std_logic_vector(BITS-1 downto 0);
		clk : in std_logic;
		rst : in std_logic
	);
end entity Rx_uart;

architecture RTL of Rx_uart is
	type state_type is (IDLE,STARTING, RECEIVING, STOPING);
	
	constant TIMER_TIME : natural := CORE/BAUDRATE;
	constant TIMER_BITS : natural := log2(TIMER_TIME);
	
	signal rx_i, rx_ii : std_logic:='0';
	signal state,state_i : state_type:= IDLE;
	signal output_i, output_aux,reg_out,reg_out_i : std_logic_vector(BITS-1 downto 0) := (others=>'0');
	signal oe_i, oe_aux : std_logic :='0';
	
	signal sec, delay, delay_i : std_logic :='0';	
	
	signal t_finish, t_start,t_start_i : std_logic :='0';
	signal t_cnt,t_cmp,t_cmp_i : std_logic_vector (TIMER_BITS-1 downto 0):= (others => '0');
	
	signal cnt, cnt_i: std_logic_vector (log2(BITS) downto 0):= (others=>'0');
	
begin
	output <= output_aux;
	oe <= oe_aux;
	
	PRINCIPAL: process (clk)
	begin
		if (rising_edge(clk)) then
			if rst='1' then
				state <= IDLE;
				output_aux <= (others=>'0');
				oe_aux <= '0';
				reg_out <= (others=>'0');
				t_cmp <= std_logic_vector(to_unsigned(TIMER_TIME/2,TIMER_BITS));
				t_start <= '0';
			else
				output_aux <= output_i;
				state <= state_i;
				oe_aux <= oe_i;
				reg_out <= reg_out_i;
				t_cmp <= t_cmp_i;
				t_start <= t_start_i;
				cnt <= cnt_i;
			end if;	
		end if;		
	end process;
		
	META_FILTER : process (clk)
	begin 
		if (rising_edge(clk)) then
			if rst='1' then
				rx_ii <= '0';
				rx_i <= '0';
			else
				rx_ii <= rx_i;
				rx_ii <= rx;
			end if;
		end if;
	end process;	
	
	RECEIVER_PROC : process (output_aux,oe_aux,reg_out,state,rx_ii,t_cmp,t_finish,cnt,sec)
	begin
		output_i <= output_aux;
		oe_i <= oe_aux;
		state_i <= state;
		reg_out_i <= reg_out;
		t_cmp_i <= t_cmp;
		t_start_i <= '0';
		cnt_i <= cnt;
		case state is 
			when IDLE =>
				t_start_i <= '0';
				oe_i <= '0';
				t_cmp_i <= std_logic_vector(to_unsigned(TIMER_TIME/2-3,TIMER_BITS));
				if (sec = '1') then
					t_start_i <= '1';
					state_i <= STARTING;
				end if;
			when STARTING =>
				t_start_i <= '0';
				if (t_finish = '1') then
					t_start_i <= '1';
					t_cmp_i <= std_logic_vector(to_unsigned(TIMER_TIME-3,TIMER_BITS));
					state_i <= RECEIVING;
					cnt_i <= (others=>'0');	
				end if;
			when RECEIVING =>
				t_start_i <= '0';
				if (t_finish = '1') then
					t_start_i <= '1';
					reg_out_i(to_integer(unsigned(cnt))) <= rx_ii;
					cnt_i <= std_logic_vector(unsigned(cnt)+to_unsigned(1,cnt'length));		
					if (cnt = std_logic_vector(to_unsigned(BITS-1,cnt'length))) then
						state_i <= STOPING;
					end if;		
				end if;
			when STOPING =>
				t_start_i <= '0';
				if (t_finish = '1') then
					output_i <= reg_out;
					oe_i <= '1';
					state_i <= IDLE;
				end if;
		end case;
	end process;
	
	TIMER: process (clk)
	begin
		if rising_edge(clk) then
			if t_start = '1' then
				t_cnt <= (others=>'0');	
			    t_finish <= '0';
			else
				t_finish<='0';
				t_cnt <= std_logic_vector(unsigned(t_cnt)+to_unsigned(1,t_cnt'length));
				if (t_cnt= t_cmp) then
					t_cnt <= (others=>'0');
					t_finish <= '1';
				end if;
					
			end if;	
		end if;
	end process;
	
	
	SEC_DET : process (clk)
	begin 
		if (rising_edge(clk)) then
			if rst='1' then
				sec <= '0';
				delay <= '0';
				delay_i <= '0';
			else
				delay_i <= delay;
				delay <= rx_ii;
				sec <= '0';
				if (delay_i = '1' and delay='0') then
					sec <= '1';	
				end if;
			end if;
		end if;
	end process;	

	
end architecture RTL;
