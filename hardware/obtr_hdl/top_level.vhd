library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;


Entity top_level is

port
(
    -- i.MX Signals
    imx_da    : inout std_logic_vector(15 downto 0);
    imx_cs_n  : in std_logic;
    imx_rw    : in std_logic ;
    imx_adv   : in std_logic ;
    -- Global Signals
    ext_clk   : in std_logic;
    button    : in std_logic;
    gls_irq   : out std_logic
	
	--- CAMERA PINS GOES HERE
	OV7670_VSYNC	: in std_logic;
	OV7670_HREF		: in std_logic;
	OV7670_PCLK		: in std_logic;
	OV7670_D		: in std_logic_vector(7 downto 0);
	OV7670_SIOC  	: out   STD_LOGIC;
	OV7670_SIOD  	: inout STD_LOGIC;
	OV7670_RESET 	: out   STD_LOGIC;
	OV7670_PWDN  	: out   STD_LOGIC;
	OV7670_XCLK  	: out   STD_LOGIC;
	
	-- debug signal
	led 			: out std_logic
);
end entity;

architecture RTL of top_level is
	signal c_sel: std_logic_vector(2 downto 0);
	signal adv:std_logic;
	signal wbm_address, wbm_readdata, wbm_writedata : std_logic_vector(15 downto 0) ;
	signal wbm_strobe, wbm_write, wbm_ack, wbm_cycle: std_logic;
	signal strobe,cycle, wr: std_logic;
    signal gls_reset, gls_clk: std_logic;
    signal irq_dout, buffer_dout, cnt_dout : std_logic_vector(15 downto 0);
    signal irq_ack, bt_irq, cnt_ack : std_logic;
    signal irq_port: std_logic_vector(15 downto 0);
    signal buffer_ack: std_logic;
    signal ack_tick : std_logic;
	signal resend, frame_irq: std_logic;
begin
  irq_port <= "000000000000000" & frame_irq;
    reset_gen: entity work.rstgen_syscon
      port map (
        ext_clk => ext_clk,
        gls_clk=> gls_clk,
        gls_reset=> gls_reset
        );
	imx51_wb_16: entity work.imx51_wb16_wrapper
	port map (
	    -- i.MX Signals
	    imx_da    => imx_da,
	    imx_cs_n  => imx_cs_n,
	    imx_rw    => imx_rw,
	    imx_adv   => imx_adv,
	    -- Global Signals
	    gls_reset => gls_reset,
	    gls_clk   => gls_clk,

	    -- Wishbone interface signals
	    wbm_address    => wbm_address,
	    wbm_readdata   => wbm_readdata,
	    wbm_writedata  => wbm_writedata,
	    wbm_strobe     => wbm_strobe, 
	    wbm_write      => wbm_write, 
	    wbm_ack        =>wbm_ack,  
	    wbm_cycle      =>wbm_cycle
	);
	interface: entity work.interface_mngr
	port map(
		clk			=> gls_clk,
		reset		=> gls_reset,
		addr_in		=> wbm_address,
        --din         => wbm_writedata,
		strobe_in	=> wbm_strobe,
		cycle_in	=> wbm_cycle,
		wr_in		=> wbm_write,
		c_sel   	=> c_sel,
		adv			=> adv,
		strobe_out  => strobe,
		cycle_out	=> cycle,
		wr_out		=> wr
        --dout        => data
        );
    irq_manager : entity work.irq_mngr
      port map(
        gls_clk         => gls_clk,
        gls_reset       => gls_reset,
        wbs_s1_address  => wbm_address(2 downto 1),
        wbs_s1_readdata => irq_dout,
        wbs_s1_writedata=> wbm_writedata,
        wbs_s1_ack      => irq_ack,
        wbs_s1_strobe   => strobe,
        wbs_s1_cycle    => cycle,
        wbs_s1_write    => wr,
        irq_cs          => c_sel(0),
        irqport         => irq_port,
        gls_irq         => gls_irq,
		start 			=> resend
        );

  --gls_irq <= bt_irq;
    
    
	camera_ent: entity work.camera_unit
    generic map(
      BUF_AW  =>14;
      BUF_DW  =>16
      )
    port map(                       
		clk		=> gls_clk,
		reset	=> gls_reset,
    	addr    => wbm_address,
		strobe	=> strobe,
		cycle	=> cycle,	
		c_sel	=> c_sel(1), 
		ack		=> buffer_ack,
    	ack_tick=> ack_tick,
		dout	=> buffer_dout
      	cfinish => led,
  		resend 	=>  resend,
		frame_irq=>frame_irq,
  		--- CAMERA PINS GOES HERE
  		OV7670_VSYNC	=> OV7670_VSYNC,
  		OV7670_HREF		=> OV7670_HREF,
  		OV7670_PCLK		=> OV7670_PCLK,
  		OV7670_D		=> OV7670_D,
  		OV7670_SIOC  	=> OV7670_SIOC,
  		OV7670_SIOD  	=> OV7670_SIOD,
  		OV7670_RESET 	=> OV7670_RESET,
  		OV7670_PWDN  	=> OV7670_PWDN,
  		OV7670_XCLK  	=> OV7670_XCLK
		);


    rw_cnt_ent: entity work.rw_counter
      port map(
          clk       => gls_clk,
          reset     => gls_reset,
          addr      => wbm_address(2 downto 1),
          strobe    => strobe,
          cycle	    => cycle,
          c_sel     => c_sel(2),
          m_ack     => ack_tick,
          ack	    => cnt_ack,
          wr	    => wr,
          dout      => cnt_dout
          );


	wbm_readdata <= buffer_dout when buffer_ack='1' else
                    irq_dout when irq_ack = '1' else
                    cnt_dout when cnt_ack = '1' else
                    (others=>'0');
	wbm_ack <= buffer_ack or irq_ack or cnt_ack;

end architecture RTL;
