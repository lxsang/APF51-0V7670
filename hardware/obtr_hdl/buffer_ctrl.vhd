-- This is the memory buffer controller
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buffer_ctrl is port
(                       
  clk       : in std_logic;
  reset	    : in std_logic;
  din		: in std_logic_vector(15 downto 0);
  addr      : in std_logic_vector(7 downto 0);
  strobe	: in std_logic;
  cycle	    : in std_logic;
  c_sel     : in std_logic; 
  ack		: out std_logic; 
  wr		: in std_logic;
  dout      : out std_logic_vector(15 downto 0)
);

end entity;

architecture arch of buffer_ctrl is
  -- signals declaration here
  constant ID: natural := 1;
  constant OFFSET: unsigned := "00000100";
  signal mem_addr : std_logic_vector(7 downto 0);
  signal wr_op : std_logic;
  signal str_addr : std_logic_vector(15 downto 0);
begin
  wr_op <= strobe and cycle and c_sel and wr;
  ack <= strobe and cycle and c_sel;
  sync_proc: process(clk,reset)
  begin
    if(reset = '1') then
      mem_addr<= (others=>'0');
    elsif rising_edge(clk) then
           if((strobe and cycle and c_sel) = '1') then
             mem_addr <= std_logic_vector(unsigned(addr) - OFFSET );
           else
             mem_addr <= mem_addr;
           end if;
    end if;    
  end process;
  str_addr <= "0000000"& addr & "0";
  mem_ent: entity work.dual_port_dual_clock
    generic map (
      ADDR_WIDTH => 8,
      DATA_WIDTH => 16
    )
    port map(
      clka    => clk,
      clkb    => clk,
      we      => wr_op,
      addr_a  => mem_addr,
      addr_b  => (others=>'0'),
      din_a   => str_addr,--din,
      dout_a  => dout,
      dout_b  => open
  );
end architecture;
