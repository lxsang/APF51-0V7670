library ieee ; 
	use ieee.std_logic_1164.all ; 
	use ieee.numeric_std.all ; 

entity interface_mngr is port 
( 
	clk			: in std_logic;
	reset		: in std_logic;
	addr_in		: in std_logic_vector(15 downto 0) ;
    --din         : in std_logic_vector(15 downto 0);
    strobe_in	: in std_logic;
	cycle_in	: in std_logic;
	wr_in		: in std_logic;
    
    -- for slave
    c_sel	    : out std_logic_vector(2 downto 0);
	adv     	: out std_logic;
	strobe_out  : out std_logic;
	cycle_out   : out std_logic;
	wr_out  	: out std_logic
    --dout        : out std_logic_vector(15 downto 0)
) ; 
end entity ; -- interface_mngr 
architecture arch of interface_mngr is 
  signal slave_active : std_logic;
  signal slave_sel: std_logic_vector(2 downto 0);
begin 
	adv <= addr_in(0);
	c_sel <= slave_sel;
	slave_active <= slave_sel(0) or slave_sel(1) or slave_sel(2) ;
   	--- addressing decode and sync sgnal ---
	addressing_proc : process(reset,clk, addr_in) 
	begin 
		if( reset = '1') then
          slave_sel <= (others=>'0');
       elsif rising_edge(clk) then
          slave_sel <= (others => '0');
          
          if addr_in(15 downto 3) = "0000000000000" and strobe_in='1' then
            slave_sel(0) <= '1';
         elsif strobe_in='1' then 
           slave_sel(1) <= '1';
         end if; 
		end if;
	end process ; -- addressing_proc

	strobe_out <= strobe_in and slave_active;
	cycle_out <= cycle_in and slave_active;
    wr_out <= wr_in and slave_active;
    --dout <= din when (slave_active and wr_in) = '1' else (others=>'0');

end architecture ; -- arch
