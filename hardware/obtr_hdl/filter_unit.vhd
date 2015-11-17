library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity filter_unit is
  port (
	clk,reset:in std_logic;
	RGB: in std_logic_vector(15 downto 0);
	start: in std_logic;
	pixon: out std_logic;
	available: out std_logic;
	ready: out std_logic
  ) ;
end filter_unit; --entity 

architecture arch of filter_unit is
	signal R,G,B, R_next, G_next, B_next: std_logic_vector(7 downto 0) ;
	signal trig, trig_next: std_logic;
begin
	R_next <= RGB(15 downto 11) & "000" when start='1' else R;
	G_next <= RGB(10 downto 5) & "00" when start='1' else G;
	B_next <= RGB(4 downto 0) & "000" when start='1' else B;
	
	syn_proc : process( clk,reset )
	begin
		if reset = '1' then
			R <= (others=>'0');
			G <= (others=>'0');
			B <= (others=>'0');
			trig <= '0';
		elsif rising_edge(clk) then
			R <= R_next;
			G <= G_next;
			B <= B_next;
			trig <= trig_next;
		end if;
	end process ; -- syn_proc
	trig_next <= start;
	hsv_filter_unit: entity work.hsvfilter
	port map(
  		clk => clk,
		reset => reset,
		R_in => R,
		G_in => G,
		B_in => B,
		start => trig,
		pixon => pixon,
		available => available,
		ready => ready
	);
end architecture ; -- arch