
----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Controller for the OV760 camera - transferes registers to the 
--              camera over an I2C like bus
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov7670_controller is
    Port ( clk45   : in    STD_LOGIC;
           resend :in    STD_LOGIC;
		   config_finished : out std_logic;
           sioc  : out   STD_LOGIC;
           siod  : inout STD_LOGIC;
           reset : out   STD_LOGIC;
           pwdn  : out   STD_LOGIC
);
end ov7670_controller;

architecture Behavioral of ov7670_controller is
   signal sys_clk  : std_logic := '0';   
   signal command  : std_logic_vector(15 downto 0);
   signal finished : std_logic := '0';
   signal taken    : std_logic := '0';
   signal send     : std_logic;
   constant camera_address : std_logic_vector(7 downto 0) := x"42"; -- 42"; -- Device write ID - see top of page 11 of data sheet
begin
   config_finished <= finished;
   send <= not finished;
   Inst_i2c_sender: entity work.i2c_sender PORT MAP(
      clk   => clk45,
      taken => taken,
      siod  => siod,
      sioc  => sioc,
      send  => send,
      id    => camera_address,
      reg   => command(15 downto 8),
      value => command(7 downto 0)
   );

   reset <= '1';                   -- Normal mode
   pwdn  <= '0';                   -- Power device up
   
   Inst_ov7670_registers: entity work.ov7670_registers PORT MAP(
      clk      => clk,
      advance  => taken,
      command  => command,
      finished => finished,
      resend   => resend
   );

   
end Behavioral;