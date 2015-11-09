-- FIFO implementation 
library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity FIFO is
	generic(
	B: natural := 8; -- number of bit
	W: natural := 4 -- number of adress, the default value support up to 16 adresses
	);
  port (
	clk,reset: in std_logic;
	rd,wr : in std_logic;
	w_data: in std_logic_vector(B-1 downto 0) ;
	empty,full : out std_logic;
	r_data: out std_logic_vector(B-1 downto 0) 
  ) ;
end FIFO;

architecture arch of FIFO is
	type file_type is array(2**W-1 downto 0) of
		std_logic_vector(B-1 downto 0); -- the buffer of size (2**W)xB
	signal array_reg: file_type;
	signal w_ptr_reg,w_ptr_next,w_ptr_succ : std_logic_vector(W-1 downto 0) ;
	signal r_ptr_reg,r_ptr_next,r_ptr_succ : std_logic_vector(W-1 downto 0) ;
	signal full_reg, full_next, empty_reg,empty_next: std_logic;
	signal wr_op : std_logic_vector(1 downto 0) ;
	signal wr_en : std_logic;
begin
	-- buffer acess
	process(clk,reset)
	begin
		if reset = '1' then
			array_reg<= (others=>(others=>'0'));
		elsif rising_edge(clk) then
			if wr_en = '1' then -- write data to the buffer
				array_reg(to_integer(unsigned(w_ptr_reg))) <= w_data;
			end if;
		end if;
	end process;
	-- read data
	r_data <= array_reg(to_integer(unsigned(r_ptr_reg)));
	-- write enable when wr and not full
	wr_en <= wr and (not full_reg);
	-- FIFO contro logic 
	--pointers registers
	process(clk,reset)
	begin
		if reset = '1' then
			w_ptr_reg <= (others=>'0');
			r_ptr_reg <= (others=>'0');
			full_reg <= '0';
			empty_reg <= '1';
		elsif rising_edge(clk) then
			w_ptr_reg <= w_ptr_next;
			r_ptr_reg <= r_ptr_next;
			full_reg<= full_next;
			empty_reg<=empty_next;
		end if;
	end process;
	-- sucessive pointer value
	w_ptr_succ <= std_logic_vector(unsigned(w_ptr_reg)+1);
	r_ptr_succ <= std_logic_vector(unsigned(r_ptr_reg)+1);
	-- read/write operation detect
	wr_op <= wr&rd;
	-- read and write pointers process
	process(w_ptr_reg,w_ptr_succ,r_ptr_reg,r_ptr_succ,wr_op, empty_reg, full_reg)
	begin
		w_ptr_next <= w_ptr_reg;
		r_ptr_next <= r_ptr_reg;
		full_next <= full_reg;
		empty_next<= empty_reg;
		-- check read/write case
		case wr_op is
			when "00"=> -- read and write disabled
			when "01"=> -- read operation
			if empty_reg /= '1' then
				r_ptr_next <= r_ptr_succ;
				full_next <= '0';
				-- check for empty
				if r_ptr_succ = w_ptr_reg then
					empty_next <= '1';
				end if;
			end if;
			-- write operation
			when "10" =>
			if full_reg /= '1' then
				w_ptr_next <= w_ptr_succ;
				empty_next <= '0';
				-- check for full
				if w_ptr_succ = r_ptr_reg then
					full_next <= '1';
				end if;
			end if;
			-- read and write enabled
			when others =>
			w_ptr_next <= w_ptr_succ;
			r_ptr_next <= r_ptr_succ;
		end case;
	end process;
	-- FIFO output
	full <= full_reg;
	empty<= empty_reg;
end architecture ; -- arch