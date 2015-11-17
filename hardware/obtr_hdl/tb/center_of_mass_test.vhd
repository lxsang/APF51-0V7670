
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity center_of_mass_test is
end center_of_mass_test;

architecture behavior of center_of_mass_test is
  -- Component declaration for the unit under test
  -- inputs
  signal  clk,reset, refresh,din_ok,rez_160x120, rez_320x240: std_logic;
  signal pixon: std_logic_vector(15 downto 0) ; 
  signal addr_in: std_logic_vector(14 downto 0) ;
  signal sum_x_out, sum_y_out, n_out: std_logic_vector(31 downto 0) ;
  constant clk_period: time := 20 ns;
begin
  uut: entity work.center_of_mass port map(
	clk=>clk,
	reset=> reset,
	rez_320x240 => '0',
	rez_160x120 => '1',
	addr_in => addr_in,
	refresh=>refresh,
	din_ok=>din_ok,
	pixon=>pixon,
	sum_x_out=>sum_x_out,
	sum_y_out => sum_y_out,
	n_out=>n_out
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
    addr_in <= (others=>'0');
	refresh <= '0';
	din_ok <= '0';
	pixon <= (others=>'0');
    reset <= '1';
    wait for 30 ns;
    reset <= '0';

    -- value goes here
    addr_in <= "000000000001100";
	pixon <= X"1758";
	din_ok<= '1';
	wait for 20 ns;
	din_ok<= '0';

    wait for 320 ns;
    addr_in <= "000000000001101";
	pixon <= X"0002";
	din_ok<= '1';
	wait for 20 ns;
	din_ok<= '0';
	wait for 320 ns;
	refresh <= '1';
	wait for 20 ns;
	refresh <= '0';
	wait for 100 ns;
    assert false
      report "Simulation complete"
      severity failure;
  end process;
end architecture;
