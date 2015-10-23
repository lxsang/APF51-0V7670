
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity sobel_test is
end sobel_test;

architecture behavior of sobel_test is
  -- Component declaration for the unit under test
  -- inputs
  signal  finish,clk,reset, start, adv, cs ,rw: std_logic;
  signal da: std_logic_vector(15 downto 0);
  --signal data_in, data_out : std_logic_vector(7 downto 0);
  constant clk_period: time := 10 ns;
begin

  uut: entity work.top_level
    generic map(
      IMG_W=>4,
      IMG_H=>4,
      BUF_AW=>8,
      BUF_DW=>16
      )
    port map(
      imx_da    =>   da,
      imx_cs_n  =>  cs,
      imx_adv   => adv,
      imx_rw    => rw,
      ext_clk   => clk,
      button    => '0',
      gls_irq   => finish
      );
  din_ent: entity work.imx_in
    port map(
    clk         => clk,
    reset       => reset,
    start       => start,
    da          => da,
    adv         => adv,
    cs          => cs,
    rw          => rw,
    finish      => finish
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
    reset <= '0';
    wait for 5 ns;
    reset <= '1';
    wait for 10 ns;
    reset <= '0';

    -- value goes here
    start <= '1';
    wait for 10 ns;
    start <= '0';

    wait for 10000 ns;
    --wait for 2500 us;
    assert false
      report "Simulation complete"
      severity failure;
  end process;
end architecture;
