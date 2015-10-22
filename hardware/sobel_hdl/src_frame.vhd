library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

    entity src_frame is
	generic(
	ADDR_WIDTH: integer:= 8;
	DATA_WIDTH : integer :=16
	);
  port (
	clk:in std_logic;
    we:in std_logic;
	addr_a,addr_b:in std_logic_vector(ADDR_WIDTH-1 downto 0) ;
	din_a:in std_logic_vector(DATA_WIDTH-1 downto 0);
	dout_a : out std_logic_vector(DATA_WIDTH-1 downto 0);
    dout_b: out std_logic_vector(7 downto 0) 
  ) ;
end entity src_frame;

architecture arch of src_frame is
  type ram_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0) ;
  
  signal ram:ram_type  := (others=>(others=>'0'));
  signal addr_a_reg,addr_b_reg, addr_b_16:std_logic_vector(ADDR_WIDTH-1 downto 0) ;
  signal dout_b_16: std_logic_vector(DATA_WIDTH-1 downto 0);
begin

	process(clk)
	begin
      if rising_edge(clk) then
			if we='1' then
				ram(to_integer(unsigned(addr_a)))<= din_a;
			end if;
			addr_a_reg<= addr_a;
		end if;
	end process;

    process( clk)
	begin
      if rising_edge(clk) then
			addr_b_reg<= addr_b;
		end if;
	end process ; -- 
	
	dout_a<=ram(to_integer(unsigned(addr_a_reg)));

    addr_b_16 <= "0" & addr_b_reg(7 downto 1);
    dout_b_16<=ram(to_integer(unsigned(addr_b_16 )));
    dout_b <= dout_b_16(15 downto 8) when addr_b_reg(0) = '1'
              else dout_b_16(7 downto 0);
end architecture ; -- arch
