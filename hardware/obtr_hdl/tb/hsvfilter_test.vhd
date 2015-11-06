
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity hsvfilter_test is
end hsvfilter_test;

architecture behavior of hsvfilter_test is
  -- Component declaration for the unit under test
  -- inputs
  signal  clk,reset, start,ready, pixon: std_logic;
  signal R,G,B: std_logic_vector(7 downto 0) ;
  constant clk_period: time := 20 ns;
begin
  uut: entity work.hsvfilter port map(
	clk => clk,
	reset => reset,
	R_in => R,
	G_in => G,
	B_in => B,
	start=>start,
	pixon=> pixon,
	ready=> ready
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
    R <= (others=>'0');
	G <= (others=>'0');
	B <= (others=>'0');
    reset <= '1';
    wait for 30 ns;
    reset <= '0';

    -- value goes here
    R <= X"96";
	G <= X"96";
	B <= X"96";
    start <= '1';
    wait for 20 ns;
    start <= '0';

    wait for 500 ns;
    assert false
      report "Simulation complete"
      severity failure;
  end process;
end architecture;
