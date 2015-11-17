library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity hsvfilter is
	generic(
	HL:Integer := 4;
	HH:Integer := 18;
	SL: Integer := 50;
	VL:Integer := 75;
	SH: Integer:= 138;
	VH: Integer := 177
	);
  port (
  	clk: in std_logic;
	reset: in std_logic;
	R_in: in std_logic_vector(7 downto 0);
	G_in: in  std_logic_vector(7 downto 0) ;
	B_in: in std_logic_vector(7 downto 0) ;
	start: in std_logic;
	pixon:out std_logic;
	available:out std_logic;
	ready: out std_logic
  ) ;
end hsvfilter; --entity 

architecture arch of hsvfilter is
	signal R,G,B,min, min_next,V: signed(8 downto 0); 
	signal PH, PH_next, subx4, subx4_next,subx64, subx64_next,PH_th_l,PH_th_h: signed(17 downto 0); --peusedo H to avoid division PH = sub*60 = H*(max-min) + adder (120 or 480);
	signal S,sub, sub_next, sub1, sub2,adder: signed(8 downto 0);
	signal mult1_ready, mult2_ready: std_logic;
	signal state, tick: std_logic := '0';
begin
	R <= signed("0"&R_in);
	G <= signed("0"&G_in);
	B <= signed("0"&B_in);
	V <= R when R > G and R > B else G when G > B else B;
	min_next <= R when R < G and R < B else G when G < B else B;
	sub_next <= (G-B) when V = R else (B-R) when V = G else (R-G);
	S <= V-min;
	adder <= "001111000" when V = G else "011110000" when V = B else (others=>'0');
	subx4_next <=  signed("1111111"&sub&"00") when sub(8) = '1' else signed("0000000"&sub&"00");
	subx64_next <= signed("111"&sub&"000000") when sub(8) = '1' else signed("000"&sub&"000000");
	--pseudo h to avoid division (use addition instead)
	PH_next <= subx64 - subx4;
	
	register_sync : process( clk,reset )
	begin
		if reset = '1' then
			min <= (others=>'0');
			sub <= (others=>'0');
			PH <= (others=>'0');
			subx4 <= (others=>'0');
			subx64 <= (others=>'0');
		elsif rising_edge(clk) then
			min<= min_next;
			sub <= sub_next;
			PH <= PH_next;
			subx4 <= subx4_next;
			subx64 <= subx64_next;
		end if;
	end process ; -- register_sync
	
	-- the tricky part, use the mult8x8
	sub1 <= to_signed(HL,9)-adder;
	sub2 <= to_signed(HH,9)-adder;
	
	mult1: entity work.mult9x9 port map(
    	clk       => clk,
    	reset     => reset,
    	start     => start,
    	a_in      =>sub1,
    	b_in      =>S,
    	r         => PH_th_l,
    	ready     => mult1_ready
	);
	
	mult2: entity work.mult9x9 port map(
    	clk       => clk,
    	reset     => reset,
    	start     => start,
    	a_in      =>sub2,
    	b_in      =>S,
    	r         => PH_th_h,
    	ready     => mult2_ready
	);

	ready <= mult2_ready and mult1_ready;
	state <= (state or tick) and ( mult2_ready and mult1_ready);

	tick_pro:process(clk,reset)
	begin
		if(reset = '1') then
			tick <= '0';
		elsif (rising_edge(clk)) then
			tick <= (mult1_ready and mult2_ready) and (not state) and (not tick);
		end if;
	end process;
	available<= tick;
	
	pixon <= '1' when ((PH >= PH_th_l) and (PH<=PH_th_h) and
						(S >= SL) and (S<= SH) and
						(V>= VL) and (V<=VH) ) else '0';
						
end architecture ; -- arch