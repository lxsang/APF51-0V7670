-- This is the memory buffer controller
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity camera_unit is
  generic(
    BUF_AW  : integer := 8;
    BUF_DW  : integer := 16
    );
  port(                       
    clk       : in std_logic;
    reset	  : in std_logic;
    addr      : in std_logic_vector(15 downto 0);
    strobe	  : in std_logic;
    cycle	  : in std_logic;
    c_sel     : in std_logic; 
    ack		  : out std_logic;
    ack_tick  : out std_logic;
    dout      : out std_logic_vector(15 downto 0);
    cfinish   : out std_logic;
	resend 	  : in std_logic ;
	frame_irq : out std_logic;
	--- CAMERA PINS GOES HERE
	OV7670_VSYNC	: in std_logic;
	OV7670_HREF		: in std_logic;
	OV7670_PCLK		: in std_logic;
	OV7670_D		: in std_logic_vector(7 downto 0);
	OV7670_SIOC  	: out   STD_LOGIC;
	OV7670_SIOD  	: inout STD_LOGIC;
	OV7670_RESET 	: out   STD_LOGIC;
	OV7670_PWDN  	: out   STD_LOGIC;
	OV7670_XCLK  	: out   STD_LOGIC
);

end entity;

architecture arch of camera_unit is
  	-- signals declaration here
  	constant ID: natural := 1;
  	constant OFFSET: unsigned(15 downto 0) := X"0008";
  	signal mem_addr : std_logic_vector(15 downto 0);
  	signal wr_op, px_wr, ack_db, state : std_logic := '0';
  	signal fr_din, fr_din_next: std_logic_vector(BUF_DW-1 downto 0);
	signal cam_dout: std_logic_vector(7 downto 0) ;
	signal clk_45: std_logic;
begin
  ack <=  strobe and cycle and c_sel;
  state <= (ack_db or state) and (strobe and cycle and c_sel);
  ack_tick <= ack_db;
  sync_proc:process(clk, reset)
  begin
    if reset = '1' then
      ack_db <= '0';
      fr_din <= (others=>'0');
    elsif rising_edge(clk) then
      fr_din <= fr_din_next;
      ack_db <= strobe and cycle and c_sel and (not ack_db) and (not state);
    end if;
  end process;
  
 mem_addr <=std_logic_vector(unsigned(addr) - OFFSET) when (strobe and cycle and c_sel) = '1'
			else (others=>'0');
			
-- clock unit
clkgen_unit:entity work.clock_gen 
	port map (
		clk_in 	=> clk,
		clk_45 	=> clk_45,
		clk_24 	=> OV7670_XCLK
		) ;
-- controller unit
cam_ctrl: entity work.ov7670_controller
	port map(
		clk45   		=> clk45,
       	resend 			=> resend, 		-- to host
	   	config_finished => cfinish, 	-- to led
       	sioc  			=> OV7670_SIOC, -- to camera
       	siod  			=> OV7670_SIOD, -- to camera
       	reset 			=> OV7670_RESET,-- to camera
       	pwdn  			=> OV7670_PWDN  -- to camera
	);
capture_unit:eitity work.ov7670_capture
	port map(
		pclk  => pclk,
	   	vsync => OV7670_VSYNC, 	-- from camera
	   	href  => OV7670_HREF,	-- from camera
	   	d     => OV7670_D, 		-- from camera
	   	addr  => fr_addr,  		-- to buffer address
	   	dout  => cam_dout, 		-- to buffer out
	   	we    => px_wr,
		frame_irq => frame_irq
	);

wr_op <= (px_wr and  fr_addr(0));
fr_din_next <= cam_dout&fr_din(7 downto 0)  when wr_op = '1' else
                 fr_din(15 downto 8)&cam_dout when
                (px_wr = '1') else fr_din;
fr_addr_map <= "0" & fr_addr(BUF_AW-1 downto 1);
 -- end process;
  frame_ent: entity work.duaport_dual_clock
    generic map(
      ADDR_WIDTH => BUF_AW,
      DATA_WIDTH => BUF_DW
      )
    port map(
    clka    => OV7670_PCLK,
	clkb 	=> clk,
    we      => wr_op, 		-- stack data to 16 bit
    addr_a  => fr_addr_map, 
    addr_b  => mem_addr(BUF_AW downto 1), 	-- requested by host
    din_a   => fr_din_next, 				-- stacked data from camera
    dout_a  => open,
    dout_b  => dout -- to host
    );
	
end architecture;
