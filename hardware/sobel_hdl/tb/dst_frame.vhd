library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity dst_frame is
	generic(
	ADDR_WIDTH: integer:= 8;
	DATA_WIDTH : integer :=16
	);
  port (
	clka,clkb:in std_logic;
    we:in std_logic;
	addr_a,addr_b:in std_logic_vector(ADDR_WIDTH-1 downto 0) ;
	din_a:in std_logic_vector(7 downto 0);
	dout_a,dout_b: out std_logic_vector(DATA_WIDTH-1 downto 0) 
  ) ;
end entity dst_frame;

architecture arch of dst_frame is
	type ram_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0) ;
	signal ram:ram_type := (others=>(others=>'1'));
	signal addr_a_reg,addr_b_reg:std_logic_vector(ADDR_WIDTH-1 downto 0) ;
    signal addr_a_16: std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal data_a_16: std_logic_vector(DATA_WIDTH-1 downto 0);
begin
  addr_a_16 <= "0"&addr_a(ADDR_WIDTH-1 downto 1);
  data_a_16 <= ram(to_integer(unsigned(addr_a_16)));
  
  process(clka)
	begin
      if rising_edge(clka) then
        if we='1' then
          
          if(addr_a(0) = '1') then
            ram(to_integer(unsigned(addr_a_16)))<= din_a& data_a_16(7 downto 0);
          else
           ram(to_integer(unsigned(addr_a_16))) <= data_a_16(15 downto 8)& din_a;
          end if;
          
          addr_a_reg<= addr_a_16;
        end if;
      end if;
	end process;

    process( clkb)
	begin
      if rising_edge(clkb) then
			addr_b_reg<= addr_b;
		end if;
	end process ; -- 
	
	dout_a<=ram(to_integer(unsigned(addr_a_reg)));
	dout_b<=ram(to_integer(unsigned(addr_b_reg )));
end architecture ; -- arch
