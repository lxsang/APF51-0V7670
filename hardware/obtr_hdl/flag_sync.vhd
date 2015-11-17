library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity flag_sync is
  port (
	clkA, clkB,reset:in std_logic;
	flagA: in std_logic;
	flagB: out std_logic
  ) ;
end flag_sync; --entity 

architecture arch of flag_sync is
	signal flagA_toggle : std_logic;
	signal flagB_sync : std_logic_vector(2 downto 0) ;
begin
	-- transform flagA to level change
	flag2lvl : process( clkA,reset )
	begin
		if reset = '1' then
			flagA_toggle <= '0';
		elsif rising_edge(clkA) then
			flagA_toggle <= flagA_toggle xor flagA;
		end if;
	end process ; -- flag2lvl
	
	-- syn the level change to clk B
	lvlonB : process( clkB,reset )
	begin
		if reset = '1' then
			flagB_sync <= (others=>'0');
		elsif rising_edge(clkB) then
			flagB_sync <= flagB_sync(1 downto 0) & flagA_toggle;
		end if;
	end process ; -- lvlonB
	
	flagB <= flagB_sync(2) xor flagB_sync(1);
end architecture ; -- arch