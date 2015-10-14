library ieee ; 
	use ieee.std_logic_1164.all ; 
	use ieee.numeric_std.all ; 

entity led is port 
( 
	clk		: in std_logic;
	reset	: in std_logic;
	din		: in std_logic_vector(15 downto 0) ;
	strobe	: in std_logic;
	cycle	: in std_logic;
	-- The address of the circuit
	-- supplied by the interface manager
	c_sel	: in std_logic; 
	adv		: in std_logic; -- read address
	ack		: out std_logic;
	wr		: in std_logic;
	dout	: out std_logic_vector(15 downto 0);
	led		:	out std_logic
) ; 
end entity ; -- interface_mngr 
architecture arch of led is 
	constant ID : natural := 1;
	Signal reg : std_logic_vector(15 downto 0) ;
begin 

	led <= reg(0);
	ack <= c_sel and strobe;
	-- write process
	write_proc : process( clk,reset ) 
	begin  
		if(reset = '1') then
			reg <= (others => '0');
		elsif rising_edge(clk) then
			if((strobe and cycle and wr and c_sel) = '1' ) then
				reg <= din;
			else 
				reg <= reg;
			end if;
		end if;
	end process ; -- write_proc
	--dout <= reg;
	--read proc
    read_proc : process( clk,reset )
	begin 
		if(reset = '1') then
			dout <= (others=>'0');
		elsif rising_edge(clk) then
			if(strobe = '1' and wr = '0' and cycle = '1'  and c_sel = '1') then
				if(adv = '1') then
					dout <= std_logic_vector(to_unsigned(id,16));
				else 
					dout <= reg;
				end if;
			else 
				dout <= (others=>'0');
			end if;
		end if;
	end process ; -- read_proc

end architecture ; -- arch
