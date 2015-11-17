
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity fifo_test is
end fifo_test;

architecture behavior of fifo_test is
  -- Component declaration for the unit under test
  -- inputs
  signal  clkw, clkr,reset, rd,wr,empty, full: std_logic;
  signal wd,r_d: std_logic_vector(7 downto 0) ; 
  constant clk_period: time := 20 ns;
begin
	fifo_unit:entity work.FIFO_dual_clock
		generic map(
		B=> 8, 
		W=>3
		)
	  port map(
		clkr=>clkr,
		clkw=>clkw,
		reset => reset,
		rd=> rd,
		wr=>wr,
		w_data=>wd,
		empty => empty,
		full => full,
		r_data => r_d
	  ) ;

  clkr_process: process
  begin
    clkr <= '0';
    wait for clk_period/2; -- wait for 10ns
    clkr <= '1';
    wait for clk_period/2;
  end process;

  clkw_process: process
  begin
    clkw <= '0';
    wait for clk_period; -- wait for 10ns
    clkw <= '1';
    wait for clk_period;
  end process;
  -- stimulus process
  stim_proc: process
  begin
    rd <= '0';
	wr <= '0';
    wd <= (others=>'0');
    reset <= '1';
    wait for 20 ns;
    reset <= '0';
	wait for 40 ns;
    -- value goes here
	wr <= '1';
    wd <= X"0A";
	wait for 40 ns;
	
	-- read and write at the same time
	wr<= '1';
	wd <= X"DB";
	wait for 10 ns;
	rd <= '1';
	wait for 20 ns;
	rd <= '0';
	wait for 10 ns;
	wr <= '0';
	wait for 10 ns;
	rd <= '1'; 
	wait for 20 ns;
	rd <= '0';
	
    wait for 100 ns;
    assert false
      report "Simulation complete"
      severity failure;
  end process;
end architecture;
