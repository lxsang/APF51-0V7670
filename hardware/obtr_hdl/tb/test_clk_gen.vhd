
library ieee;
use ieee.std_logic_1164.ALL;

entity clk_gen_tb is
end clk_gen_tb;

architecture behavior of clk_gen_tb is
  -- Component declaration for the unit under test
  -- inputs
  signal  clk, clk_45, clk_24: std_logic;
  constant clk_period: time := 10 ns;
begin
  uut: entity work.clock_gen port map(
	clk_in 	=> clk,
	clk_45 	=> clk_45,
	clk_24 	=> clk_24
 );

  clk_process: process
  begin
    clk <= '0';
    wait for clk_period/2; -- wait for 5ns
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- stimulus process
  stim_proc: process
  begin
	 wait for 100 ns;
    assert false
      report "Simulation complete"
      severity failure;
  end process;
end architecture;
