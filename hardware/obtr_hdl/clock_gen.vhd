library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity clock_gen is
  port (
	clk_in:in std_logic;
	clk_45: out std_logic;
	clk_24: out std_logic
  ) ;
end clock_gen; --entity 

architecture arch of clock_gen is
	signal sig45: std_logic := '0';
	signal sig24: std_logic:= '0';
begin
	clk_45_proc : process( clk_in, sig45 )
	begin
		if rising_edge(clk_in) then
			sig45 <=  not sig45;
		end if;
	end process ; -- clk_45
	
	clk_24_proc : process( sig45, sig24)
	begin
		if rising_edge(sig45) then
			sig24 <= not sig24;
		end if;
	end process ; -- clk_24
	clk_45 <= sig45;
	clk_24 <= sig24;
end architecture ; -- arch