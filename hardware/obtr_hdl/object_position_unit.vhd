library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity object_position_unit is
  port (
	clk		: in std_logic;
	reset	: in std_logic;
	strobe	: in std_logic;
	cycle	: in std_logic;
	-- The address of the circuit
	-- supplied by the interface manager
	addr	: in std_logic_vector(2 downto 0) ;
	sum_x_in: in std_logic_vector(31 downto 0) ;
	sum_y_in: in std_logic_vector(31 downto 0) ;
	n_in 	: in std_logic_vector(31 downto 0) ;
	frame_ok: in std_logic;
	c_sel	: in std_logic; 
	ack		: out std_logic;
	wr		: in std_logic;
	dout	: out std_logic_vector(15 downto 0)
  ) ;
end object_position_unit; --entity 

architecture arch of object_position_unit is
	--signal sum, sum_next: std_logic_vector(31 downto 0) ;
	--signal n,n_next : std_logic_vector(31 downto 0) ;
begin
	
	ack <= c_sel and strobe;
	-- write process
	-- write_proc : process( clk,reset )
-- 	begin
-- 		if(reset = '1') then
-- 			sum <= (others => '0');
-- 			n<= (others=>'0');
-- 		elsif rising_edge(clk) then
-- 			sum <= sum_next;
-- 			n <= n_next;
-- 		end if;
-- 	end process ; -- write_proc
	
	--sum_next <= sum_in when frame_ok = '1' else sum;
	--n_next <= n_in when frame_ok = '1' else n;
	
	--dout <= reg;
	--read proc
    read_proc : process( clk,reset )
	begin 
		if(reset = '1') then
			dout <= (others=>'0');
		elsif rising_edge(clk) then
			if(strobe = '1' and wr = '0' and cycle = '1'  and c_sel = '1') then
				if addr = "000" then
					dout <= sum_x_in(15 downto 0);
				elsif addr = "001" then
					dout <= sum_x_in(31 downto 16);
				elsif addr = "010" then
					dout <= sum_y_in(15 downto 0);
				elsif addr = "011" then
					dout <= sum_y_in(31 downto 16);
				elsif addr = "100" then
					dout <= n_in(15 downto 0);
				elsif addr = "101" then
					dout <= n_in(31 downto 16);
				else
					dout<= (others=>'0');
				end if;
			else 
				dout <= (others=>'0');
			end if;
		end if;
	end process ; -- read_proc
end architecture ; -- arch