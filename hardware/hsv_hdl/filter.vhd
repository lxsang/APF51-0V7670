library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter is port (
  clk       : in std_logic;
  reset     : in std_logic;
  addr      : in std_logic_vector(1 downto 0);
  strobe    : in std_logic;
  c_sel     : in std_logic;
  m_ack     : in std_logic;
  cycle     : in std_logic;
  wr        : in std_logic;
  dout      : out std_logic_vector(15 downto 0);
  din 		: in std_logic_vector(15 downto 0);
  start 	: in std_logic;
  finish 	: out std_logic;
  ack       : out std_logic
  );
end entity;

architecture arch of filter is
  constant ID : natural := 4;
  signal R,G,B : std_logic_vector(15 downto 0);
  signal pixon : std_logic_vector(7 downto 0);
  signal filter_finish : std_logic;
  signal ready : std_logic := '0';
begin
  ack <= c_sel and strobe and cycle ;--and ready;
  ready <= '0' when start = '1' else '1' when filter_finish = '1' else ready; 
  finish <= ready;
  -- register reading process
  process(clk, reset)
  begin
    if reset = '1' then
      dout <= (others => '0');
    elsif rising_edge(clk) then
      if (strobe and cycle and c_sel) = '1' and wr = '0' then
		  if(addr = "00") then
			  dout <= "00000000"&pixon;
		  elsif addr = "01" then
			  dout <= R;
		  elsif addr = "10" then
			  dout <= G;
		  else
			  dout <= std_logic_vector(to_unsigned(id,16));
		  end if;
      end if;
    end if;
    
  end process;
  
  filter_unit: entity work.hsvfilter
  	port map(
    		clk => clk,
  		reset => reset,
  		R_in => R(7 downto 0),
  		G_in => G(7 downto 0),
  		B_in => B(7 downto 0),
  		start => start,
  		pixon => pixon,
  		ready => filter_finish
  	);
  
  process(clk,reset)
  begin
    if(reset = '1') then
      R <= (others=>'0');
      G <= (others => '0');
	  B <= (others=>'0');
    elsif rising_edge(clk) then
      if (strobe and wr and cycle and c_sel) = '1' then
		  if addr = "00" then
			  R <= din;
		  elsif addr = "01" then
			  G <= din;
		  else
			  B <= din;
		  end if;
			  
      else
        R <= R;
        G <= G;
		B <= B;
      end if;
    end if;
  end process;
  
end architecture;

