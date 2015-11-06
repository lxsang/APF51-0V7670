
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity mult_test is
end mult_test;

architecture behavior of mult_test is
  -- Component declaration for the unit under test
  -- inputs
  signal  clk,reset, start,ready: std_logic;
  signal a_in, b_in: signed(8 downto 0);
  signal r : signed(17 downto 0);
  constant clk_period: time := 20 ns;
begin
  uut: entity work.mult9x9 port map(
    clk         => clk,
    reset       => reset,
    start       => start,
    a_in        => a_in,
    b_in        => b_in,
    r           => r,
    ready       => ready
   );

  clk_process: process
  begin
    clk <= '0';
    wait for clk_period/2; -- wait for 10ns
    clk <= '1';
    wait for clk_period/2;
  end process;

  
  -- stimulus process
  stim_proc: process
  begin
    start <= '0';
    a_in <= (others=>'0');
    b_in <= (others=> '0');
    reset <= '1';
    wait for 30 ns;
    reset <= '0';

    -- value goes here
    a_in <= "1"&X"FB";
    b_in <= "1"&X"FB";
    start <= '1';
    wait for 20 ns;
    start <= '0';

    wait for 500 ns;
    assert false
      report "Simulation complete"
      severity failure;
  end process;
end architecture;
