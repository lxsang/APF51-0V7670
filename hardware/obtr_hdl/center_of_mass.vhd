library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity center_of_mass is
  port (
	clk,reset:in std_logic;
	addr_in : in std_logic_vector(14 downto 0);
	refresh: in std_logic;
	rez_160x120, rez_320x240: in std_logic;
	din_ok: in std_logic;
	pixon: in std_logic_vector(15 downto 0) ;
	sum_x_out: out std_logic_vector(31 downto 0) ;
	sum_y_out: out std_logic_vector(31 downto 0) ;
	n_out: out std_logic_vector(31 downto 0)
  ) ;
end center_of_mass; --entity 

architecture arch of center_of_mass is
	constant N_OFFSET_640: unsigned(5 downto 0) := "101000"; --40
	constant N_OFFSET_320: unsigned(5 downto 0) := "010100"; --20
	constant N_OFFSET_160: unsigned(5 downto 0) := "001010"; --10
	signal sum_x,sum_y, sum_y_next, sum_x_next, cnt_n,cnt_n_next: unsigned(31 downto 0);
	signal sum_x_reg, sum_x_reg_next, sum_y_reg, sum_y_reg_next,n_reg_next,n_reg : unsigned(31 downto 0);
	signal pix, pix_next : std_logic_vector(15 downto 0) ;
	signal real_addr, offset_addr, curr_x, curr_y, curr_line, curr_line_next: unsigned(31 downto 0) ;
	signal cnt, cnt_next : unsigned(3 downto 0) := (others=>'0');
	signal offset_cnt, offset_th: unsigned(5 downto 0) := (others=>'0');
	signal line_tick: std_logic;
	type state_type is(IDLE, SUMMING);
	signal state,state_next:state_type;
begin
	syn_proc : process( clk,reset )
	begin
		if reset = '1' then
			sum_x <= (others=>'0');
			sum_y <= (others=>'0');
			cnt_n <= (others=>'0');
			pix   <=  (others=>'0');
			cnt <= (others=>'0');
			state <= IDLE;
			sum_x_reg <= (others=>'0');
			sum_y_reg <= (others=>'0');
			n_reg <= (others=>'0');
			curr_line <= (others=>'0');
		elsif rising_edge(clk) then
			sum_x <= sum_x_next;
			sum_y <= sum_y_next;
			cnt_n <= cnt_n_next;
			pix <= pix_next;
			state<= state_next;
			cnt <= cnt_next;
			sum_x_reg <= sum_x_reg_next;
			sum_y_reg <= sum_y_reg_next;
			n_reg <= n_reg_next;
			curr_line <= curr_line_next;
		end if;
	end process ; -- syn_proc
	-- store the old value to register
	sum_x_reg_next <= sum_x when refresh = '1' else sum_x_reg;
	sum_y_reg_next <= sum_y when refresh = '1' else sum_y_reg;
	n_reg_next <= cnt_n when refresh = '1' else n_reg;
	-- keep a version of data
	pix_next <= pixon when din_ok = '1' else pix;
	offset_addr <= unsigned("0000000000000" & addr_in & "0000"); 
	real_addr <=   offset_addr + cnt;
	offset_th <= N_OFFSET_160 when rez_160x120 = '1' else
				N_OFFSET_320 when rez_320x240 = '1' else
					N_OFFSET_640;
	-- detect new line
	curr_line_next <= offset_addr when line_tick = '1' else curr_line;
	new_line_cnt : process( clk,reset, refresh, din_ok )
	begin
		if reset = '1' or refresh = '1' then
			offset_cnt <= (others=>'0');
			curr_x <= (others=>'0');
		elsif rising_edge(clk) then
			line_tick <= '0';
			if(offset_cnt = offset_th) then
				line_tick <= '1';
				offset_cnt <= (others=>'0');
				curr_x <= curr_x + 1;
			elsif din_ok  = '1' then
				offset_cnt <= offset_cnt + 1;
			end if;
		end if;
	end process ; -- new_line_cnt
	-- TODO: figure out what happends, ok?
	curr_y <= real_addr - curr_line; 
	
	counting_proc : process(state, din_ok, addr_in, pix, cnt_n, sum_x, sum_y, cnt, curr_x, curr_y, refresh)
	begin
		state_next <= state;
		cnt_n_next <= cnt_n;
		sum_x_next <= sum_x;
		sum_y_next <= sum_y;
		cnt_next <= cnt;
		case state is 
		when IDLE=>
		if(refresh = '1') then
			sum_x_next <= (others=>'0');
			sum_y_next <= (others=>'0');
			cnt_n_next <= (others=>'0');
			cnt_next <= (others=>'0');
		end if;
		if(din_ok = '1') then
			state_next <= SUMMING;
		end if;
		when SUMMING=>
		if(refresh = '1') then
			sum_x_next <= (others=>'0');
			sum_y_next <= (others=>'0');
			cnt_n_next <= (others=>'0');
			cnt_next <= (others=>'0');
		else
			cnt_next <= cnt+1;
			if(pix(to_integer(cnt)) = '1') then
				cnt_n_next <= cnt_n + 1;
				sum_x_next <= sum_x + curr_x;
				sum_y_next <= sum_y + curr_y;
			end if;
		end if;
		if(cnt = "1111") then
			state_next <= IDLE;
		end if;
		
		end case;
	end process ; -- counting_proc

	sum_x_out <= std_logic_vector(sum_x_reg);
	sum_y_out <= std_logic_vector(sum_y_reg);
	n_out <= std_logic_vector(n_reg) ;
end architecture ; -- arch