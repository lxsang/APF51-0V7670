library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity hsvfilter is
	generic(
	HL:Integer := 60;
	HH:Integer := 180;
	SL: Integer := 25;
	VL:Integer := 127;
	TOP: Integer:= 255 
	);
  port (
  	clk: in std_logic;
	reset: in std_logic;
	R_in: in std_logic_vector(7 downto 0);
	G_in: in  std_logic_vector(7 downto 0) ;
	B_in: in std_logic_vector(7 downto 0) ;
	start: in std_logic;
	pixon:out std_logic;
	ready: out std_logic
  ) ;
end hsvfilter; --entity 

architecture arch of hsvfilter is
	signal R,G,B,min,V: signed(8 downto 0); 
	signal PH, subx4,subx64, subx,PH_th_l,PH_th_h: signed(17 downto 0); --peusedo H to avoid division PH = sub*60 = H*(max-min) + adder (120 or 480);
	signal S,sub, sub1, sub2,adder: signed(8 downto 0);
	signal mult1_ready, mult2_ready: std_logic;
begin
	R <= signed("0"&R_in);
	G <= signed("0"&G_in);
	B <= signed("0"&B_in);
	V <= R when R > G and R > B else G when G > B else B;
	min <= R when R < G and R < B else G when G < B else B;
	sub <= (G-B) when V = R else (B-R) when V = G else (R-G);
	S <= V-min;
	adder <= "001111000" when V = G else "011110000" when V = B else (others=>'0');
	subx4 <=  signed("0000000"&sub&"00");
	subx64 <= signed("000"&sub&"000000");
	--pseudo h to avoid division (use addition instead)
	PH <= subx64 - subx4;
	
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
	
	pixon <= '1' when (	(PH >= PH_th_l) and (PH<=PH_th_h) and
						(S >= SL) and (S<= TOP) and
						(V>= VL) and (V<=TOP) ) else '0';
						
end architecture ; -- arch