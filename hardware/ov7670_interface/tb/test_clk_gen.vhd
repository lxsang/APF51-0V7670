-- The MIT License (MIT)
--
-- Copyright (c) Sang LE xsang.le@gmail.com
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
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