library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rw_counter is port (
  clk       : in std_logic;
  reset     : in std_logic;
  addr      : in std_logic_vector(1 downto 0);
  strobe    : in std_logic;
  c_sel     : in std_logic;
  m_ack     : in std_logic;
  cycle     : in std_logic;
  wr        : in std_logic;
  dout      : out std_logic_vector(15 downto 0);
  ack       : out std_logic
  );
end entity;

architecture arch of rw_counter is
  constant ID : natural := 4;
  signal w_counter : unsigned(15 downto 0);
  signal r_counter : unsigned(15 downto 0);
begin
  ack <= c_sel and strobe and cycle;
  -- register reading process
  process(clk, reset)
  begin
    if reset = '1' then
      dout <= (others => '0');
    elsif rising_edge(clk) then
      if (strobe and cycle and c_sel) = '1' and wr = '0' then
        if addr = "00" then
          dout <= std_logic_vector(r_counter);
        elsif addr = "01" then
          dout <= std_logic_vector(w_counter);
        else
          dout <= std_logic_vector(to_unsigned(ID,16));
        end if;
      end if;
    end if;
    
  end process;
  
  -- reset the counter when user write to this component
  process(clk,reset)
  begin
    if(reset = '1') then
      w_counter <= (others=>'0');
      r_counter <= (others => '0');
    elsif rising_edge(clk) then
      if (strobe and wr and cycle and c_sel) = '1' then
        -- reset the counter
        w_counter <= (others=>'0');
        r_counter <= (others=>'0');
      elsif(strobe and cycle and m_ack) = '1' then
        if wr = '1' then
          w_counter <= w_counter + 1;
        else
          r_counter <= r_counter + 1;
        end if;
      else
        w_counter <= w_counter;
        r_counter <= r_counter;
      end if;
    end if;
  end process;
  
end architecture;

