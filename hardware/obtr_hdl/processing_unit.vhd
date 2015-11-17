library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity processing_unit is
  port (
	clk,reset,px_wr:in std_logic;
	addr: in std_logic_vector(1 downto 0);
	trigger: in std_logic;
	data_in: in std_logic_vector(15 downto 0);
	data_out: out std_logic_vector(3 downto 0) ;
	data_ok: out std_logic
  ) ;
end processing_unit; --entity 

architecture arch of processing_unit is
	signal pixels,pixels_next: std_logic_vector(63 downto 0) ;
	signal start, trig, trig_next: std_logic;
	signal pixons: std_logic_vector(3 downto 0);
	signal ready1, ready2, ready3, ready4:std_logic;
	signal avai1, avai2,avai3, avai4:std_logic;
begin
	syn_proc : process( clk,reset )
	begin
		if reset = '1' then
			pixels <= (others=>'0');
			trig <= '0';
		elsif rising_edge(clk) then
			pixels <= pixels_next;
			trig<= trig_next;
		end if;
	end process ; -- 
	
	trig_next <= '1' when trigger = '1' else trig;
	
	
	pixels_next <= data_in&pixels(63 downto 16) when px_wr = '1' else pixels;
	start  <= '1' when addr = "11" and px_wr = '1' and trig = '1' else '0';
	filter_1: entity work.filter_unit
	  port map(
		clk => clk,
		reset=>reset,
		RGB=> pixels_next(15 downto 0),
		start=>start,
		pixon => pixons(0),
		available=> avai1,
		ready=>ready1
	  ) ;
  	filter_2: entity work.filter_unit
  	  port map(
  		clk => clk,
  		reset=>reset,
  		RGB=> pixels_next(31 downto 16),
  		start=>start,
  		pixon => pixons(1),
  		available=> avai2,
  		ready=>ready2
  	  ) ;
  	filter_3: entity work.filter_unit
  	  port map(
  		clk => clk,
  		reset=>reset,
  		RGB=> pixels_next(47 downto 32),
  		start=>start,
  		pixon => pixons(2),
  		available=> avai3,
  		ready=>ready3
  	  ) ;
  	filter_4: entity work.filter_unit
  	  port map(
  		clk => clk,
  		reset=>reset,
  		RGB=> pixels_next(63 downto 48),
  		start=>start,
  		pixon => pixons(3),
  		available=> avai4,
  		ready=>ready4
  	  ) ;
	  data_out <= pixons;
	  data_ok <= ready4 and ready3 and ready2 and ready1; 
	
end architecture ; -- arch