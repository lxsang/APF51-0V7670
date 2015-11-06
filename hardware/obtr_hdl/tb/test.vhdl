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

entity wb_test is
end wb_test;

architecture behavior of wb_test is
  -- Component declaration for the unit under test
  -- inputs
  signal  imx_cs_n, imx_rw, imx_adv, clk, reset: std_logic;
  signal button, irq: std_logic;
  signal imx_da: std_logic_vector(15 downto 0);
  constant clk_period: time := 20 ns;
begin
  uut: entity work.top_level port map(
    imx_da => imx_da,
    imx_cs_n=> imx_cs_n,
    imx_rw => imx_rw,
    imx_adv=> imx_adv,
    --gls_reset=> reset,
    ext_clk => clk,
    button=> button,
    gls_irq => irq
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
    button <= '0';
    imx_cs_n <= '1';
    imx_da <= (others=>'0');
    imx_adv<= '1';
    imx_rw <= '1';
    reset <= '1';
    wait for 20 ns;
    reset <= '0';
    -- value goes here
    -- write data to address 0x000F
    wait for 40 ns;
    imx_da <= X"0008";
    imx_adv <= '0';
    wait for 20 ns;
    -- data in
    imx_da <= X"1234";
    imx_adv <= '1';
    imx_cs_n<= '0';
    imx_rw <= '0';

    wait for 80 ns;
    imx_cs_n<= '1';
    
    wait for 100 ns;
    
    -- read data from address 0x000F
    imx_da <=  (others=>'0');
    imx_adv<= '1';
    imx_cs_n<= '1';
    imx_rw <= '1';

    wait for 60 ns;
    imx_da <= X"0008";
    imx_adv <= '0';

    wait for 20 ns;
    imx_adv <= '1';
    imx_cs_n <= '0';
    wait for 80 ns;
    imx_cs_n <= '1';

    wait for 100 ns;


    wait for 40 ns;
    imx_da <= X"000A";
    imx_adv <= '0';
    wait for 20 ns;
    -- data in
    imx_da <= X"DEFF";
    imx_adv <= '1';
    imx_cs_n<= '0';
    imx_rw <= '0';

    wait for 80 ns;
    imx_cs_n<= '1';
    
    wait for 100 ns;
    
    -- read data from address 0x000F
    imx_da <=  (others=>'0');
    imx_adv<= '1';
    imx_cs_n<= '1';
    imx_rw <= '1';

    wait for 60 ns;
    imx_da <= X"000A";
    imx_adv <= '0';

    wait for 20 ns;
    imx_adv <= '1';
    imx_cs_n <= '0';
    wait for 80 ns;
    imx_cs_n <= '1';

    wait for 100 ns;

    -- read ID
    imx_da <=  (others=>'0');
    imx_adv<= '1';
    imx_cs_n<= '1';
    imx_rw <= '1';

    wait for 60 ns;
    imx_da <= X"FFFC";
    imx_adv <= '0';

    wait for 20 ns;
    imx_adv <= '1';
    imx_cs_n <= '0';
    wait for 80 ns;
    imx_cs_n <= '1';

    wait for 100 ns;

    -- read read_counter
    imx_da <=  (others=>'0');
    imx_adv<= '1';
    imx_cs_n<= '1';
    imx_rw <= '1';

    wait for 60 ns;
    imx_da <= X"FFF8";
    imx_adv <= '0';

    wait for 20 ns;
    imx_adv <= '1';
    imx_cs_n <= '0';
    wait for 80 ns;
    imx_cs_n <= '1';

    wait for 100 ns;

    -- read data from address 0x000F
    imx_da <=  (others=>'0');
    imx_adv<= '1';
    imx_cs_n<= '1';
    imx_rw <= '1';

    wait for 60 ns;
    imx_da <= X"FFFA";
    imx_adv <= '0';

    wait for 20 ns;
    imx_adv <= '1';
    imx_cs_n <= '0';
    wait for 80 ns;
    imx_cs_n <= '1';

    wait for 100 ns;

    -- reset counter
    wait for 40 ns;
    imx_da <= X"FFF8";
    imx_adv <= '0';
    wait for 20 ns;
    -- data in
    imx_da <= X"DEFF";
    imx_adv <= '1';
    imx_cs_n<= '0';
    imx_rw <= '0';

    wait for 80 ns;
    imx_cs_n<= '1';
    
    wait for 100 ns;
    
    wait for 60 ns;
    button <= '1';
    wait for 40 ns;
    button <= '0';
    wait for 60 ns;
    
    assert false
      report "Simulation complete"
      severity failure;
  end process;
end architecture;
