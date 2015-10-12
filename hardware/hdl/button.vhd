library ieee ; 
	use ieee.std_logic_1164.all ; 
	use ieee.numeric_std.all ; 

entity button is port 
( 
	clk		: in std_logic;
	reset	: in std_logic;
	strobe	: in std_logic;
	cycle	: in std_logic;
	-- supplied by the interface manager
	c_sel	: in std_logic;
	adv		: in std_logic; -- read address
	ack		: out std_logic;
	wr		: in std_logic;
    sw      : in std_logic;
    irq     : out std_logic;
	dout	: out std_logic_vector(15 downto 0)
) ; 
end entity ; -- 
architecture arch of button is 
	constant ID : natural := 2;
	Signal reg:std_logic_vector(15 downto 0) ;
    signal db_level: std_logic;
begin 
  ack <= c_sel and strobe;

  connect_button: process(clk,reset)
  begin
    if(reset = '1') then
      reg <= (others=>'0');
     elsif rising_edge(clk) then
       reg <= "000000000000000" & db_level;
     end if;
    end process;
      
    -- connect button to debouce unit
    debounce_unit: entity work.debounce
      port map(
        clk => clk,
        reset => reset,
        sw => sw,
        db_level => db_level,
        db_tick => irq
        );
    
    --read proc
    read_proc : process( clk,reset) 
	begin 
		if(reset = '1') then
			dout <= (others=>'0');
		elsif rising_edge(clk) then
			if(strobe = '1' and wr = '0' and cycle = '1' and c_sel='1') then
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

end 
architecture ; -- arch
