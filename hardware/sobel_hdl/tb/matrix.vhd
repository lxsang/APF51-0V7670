library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity matrix is
	generic(
	ADDR_WIDTH: integer:= 8;
	DATA_WIDTH : integer :=16
	);
  port (
	clka,clkb:in std_logic;
    we:in std_logic;
	addr_a,addr_b:in std_logic_vector(ADDR_WIDTH-1 downto 0) ;
	din_a:in std_logic_vector(DATA_WIDTH-1 downto 0);
	dout_a : out std_logic_vector(DATA_WIDTH-1 downto 0);
    dout_b: out std_logic_vector(7 downto 0) 
  ) ;
end entity matrix;

architecture arch of matrix is
  type ram_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0) ;
  
	signal ram:ram_type  := (
      X"0201",X"0102",
      X"0101",X"0300",
      X"0402",X"0501",
      X"0102",X"0002",
      others=>(others=>'0')
    );
  signal addr_a_reg,addr_b_reg, addr_b_16:std_logic_vector(ADDR_WIDTH-1 downto 0) ;
  signal dout_b_16: std_logic_vector(DATA_WIDTH-1 downto 0);
begin

	process(clka)
	begin
      if rising_edge(clka) then
			if we='1' then
				ram(to_integer(unsigned(addr_a)))<= din_a;
			end if;
			addr_a_reg<= addr_a;
		end if;
	end process;

    process( clkb)
	begin
      if rising_edge(clkb) then
			addr_b_reg<= addr_b;
		end if;
	end process ; -- 
	
	dout_a<=ram(to_integer(unsigned(addr_a_reg)));

    addr_b_16 <= "0" & addr_b_reg(7 downto 1);
    dout_b_16<=ram(to_integer(unsigned(addr_b_16 )));
    dout_b <= dout_b_16(15 downto 8) when addr_b_reg(0) = '1'
              else dout_b_16(7 downto 0);
end architecture ; -- arch
