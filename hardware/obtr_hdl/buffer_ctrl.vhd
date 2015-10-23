-- This is the memory buffer controller
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buffer_ctrl is port
(                       
  clk       : in std_logic;
  reset	    : in std_logic;
  din		: in std_logic_vector(15 downto 0);
  addr      : in std_logic_vector(15 downto 0);
  strobe	: in std_logic;
  cycle	    : in std_logic;
  c_sel     : in std_logic; 
  ack		: out std_logic;
  ack_tick  : out std_logic;
  wr		: in std_logic;
  dout      : out std_logic_vector(15 downto 0)
);

end entity;

architecture arch of buffer_ctrl is
  -- signals declaration here
  constant ID: natural := 1;
  constant OFFSET: unsigned(15 downto 0) := X"0008";
  signal mem_addr : std_logic_vector(15 downto 0);
  signal wr_op, ack_db, state : std_logic := '0';
 -- signal str_addr : std_logic_vector(15 downto 0);
begin
  wr_op <= strobe and cycle and c_sel and wr;
  ack <=  strobe and cycle and c_sel;
  state <= (ack_db or state) and (strobe and cycle and c_sel);
  ack_tick <= ack_db;
  sync_proc:process(clk, reset)
  begin
    if reset = '1' then
      ack_db <= '0';
    elsif rising_edge(clk) then
      ack_db <= strobe and cycle and c_sel and (not ack_db) and (not state);
    end if;
  end process;
  
  --sync_proc: process(clk,reset)
  --begin
  --  if(reset = '1') then
  --    mem_addr<= (others=>'0');
   -- elsif rising_edge(clk) then
     --      if((strobe and cycle and c_sel) = '1') then
       --      mem_addr <= std_logic_vector(unsigned(addr) - OFFSET );
         --  else
           --  mem_addr <= mem_addr;
         --  end if;
  --  end if;
 mem_addr <=std_logic_vector(unsigned(addr) - OFFSET) when (strobe and cycle and c_sel) = '1' else (others=>'0');
 -- end process;
  --str_addr <= "0000000"& addr & "0";
  mem_ent: entity work.dual_port_dual_clock
    generic map (
      ADDR_WIDTH => 8,
      DATA_WIDTH => 16
    )
    port map(
      clka    => clk,
      clkb    => clk,
      we      => wr_op,
      addr_a  => mem_addr(8 downto 1),
      addr_b  => (others=>'0'),
      din_a   => din,
      dout_a  => dout,
      dout_b  => open
  );
end architecture;
