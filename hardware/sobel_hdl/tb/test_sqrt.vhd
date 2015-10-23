
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity sqrt_test is
end sqrt_test;

architecture behavior of sqrt_test is
  -- Component declaration for the unit under test
  -- inputs
  signal  clk,reset, din_valid,dout_ready: std_logic;
  signal din: std_logic_vector(15 downto 0);
  signal dout : std_logic_vector(7 downto 0);
  constant clk_period: time := 20 ns;
begin
  uut: entity work.sqrt port map(
    clk         => clk,
    reset       => reset,
    din         => din,
    din_valid   => din_valid,
    dout_ready  => dout_ready,
    dout        => dout
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
    din_valid <= '0';
    din <= (others=>'0');
    reset <= '1';
    wait for 30 ns;
    reset <= '0';

    -- value goes here
    din <= X"0051";
    din_valid <= '1';
    wait for 20 ns;
    din_valid <= '0';

    wait for 500 ns;
    assert false
      report "Simulation complete"
      severity failure;
  end process;
end architecture;
