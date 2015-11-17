
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity flag_sync_test is
end flag_sync_test;

architecture behavior of flag_sync_test is
  -- Component declaration for the unit under test
  -- inputs
  signal  clkA, clkB,reset, flagA, flagB: std_logic;
  constant clk_period: time := 20 ns;
begin
	uut:entity work.flag_sync
  port map(
	clkA => clkA, 
	clkB => clkB,
	reset=> reset,
	flagA => flagA,
	flagB => flagB
  ) ;

  clkrB_process: process
  begin
    clkB <= '0';
    wait for clk_period/2; -- wait for 10ns
    clkB <= '1';
    wait for clk_period/2;
  end process;
  
  clkrA_process: process
  begin
    clkA <= '0';
    wait for clk_period*2; -- wait for 10ns
    clkA <= '1';
    wait for clk_period*2;
  end process;

  -- stimulus process
  stim_proc: process
  begin
   flagA <= '0';
    reset <= '1';
    wait for 20 ns;
    reset <= '0';
	wait for 20 ns;
    -- value goes here
	flagA <= '1';
	wait for 80 ns;
	flagA <= '0';
	
    wait for 100 ns;
    assert false
      report "Simulation complete"
      severity failure;
  end process;
end architecture;
