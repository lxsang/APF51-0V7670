-- debounce circuit

library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity debounce is
  port (
	clk,reset:in std_logic;
	sw : in std_logic; -- input switch
	db_level, db_tick : out std_logic -- output level & one clock cycle
  ) ;
end debounce;

architecture arch of debounce is
	constant N:integer := 21; -- 21 bit, 50Mhz => 40 msec
	type state_type is(zero,wait1,wait0,one);
	signal state_reg, state_next : state_type;
	signal q_reg, q_next: unsigned(N-1 downto 0);
begin
	process(clk,reset)
	begin
		if reset = '1' then
			state_reg <= zero;
			q_reg <= (others=>'0');
		elsif rising_edge(clk) then
			state_reg <= state_next;
			q_reg <= q_next;
		end if ;
	end process;
	
	process(state_reg, q_reg, sw, q_next)
	begin
		state_next<= state_reg;
		q_next<=q_reg;
		db_tick<='0';
		case state_reg is
			when zero=>
			db_level<= '0';
			if sw = '1' then
				state_next <= wait1;
				q_next <= (others=>'1');
			end if;
			--Wait 1
			when wait1=>
			db_level<= '0';
			if sw = '1' then
				q_next <= q_reg - 1;
				if q_next = 0 then
					db_tick <= '1';
					state_next <= one;
				end if;
			else
				state_next <= zero;
			end if ;
			-- One
			when one=>
			db_level<= '1';
			if sw = '0' then
				q_next <= (others=>'1');
				state_next <= wait0;
			end if;
			-- wait0
			when wait0=>
			db_level<= '1';
			if sw= '0' then
				q_next<= q_reg-1;
				if q_next = 0 then
					state_next<=zero;
				end if;
			else
				state_next<= one;
			end if;
		end case;
	end process;
end architecture ; -- arch