library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;


Entity top_level is
  generic (
    IMG_W   : integer := 160;
    IMG_H   : integer := 120;
    BUF_AW  : integer := 14;
    BUF_DW  : integer := 16
);
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
    signal sobel_start, sobel_finish: std_logic;
begin

  -- connect button to debouce unit
    debounce_unit: entity work.debounce
      port map(
        clk => gls_clk,
        reset => gls_reset,
        sw => button,
        db_level => open,
        db_tick => bt_irq
        );
    
  irq_port <= "00000000000000"& sobel_finish & bt_irq;
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
        start           => sobel_start,
        wbs_s1_address  => wbm_address(2 downto 1),
        wbs_s1_readdata => irq_dout,
        wbs_s1_writedata=> wbm_writedata,
        wbs_s1_ack      => irq_ack,
        wbs_s1_strobe   => strobe,
        wbs_s1_cycle    => cycle,
        wbs_s1_write    => wr,
        irq_cs          => c_sel(0),
        irqport         => irq_port,
        gls_irq         => gls_irq
        );

  --gls_irq <= bt_irq;
    
    
	buffer_ent: entity work.buffer_ctrl
      generic map(
        IMG_W   => IMG_W,
        IMG_H   => IMG_H,
        BUF_AW  => BUF_AW,
        BUF_DW  => BUF_DW
        )
      port map(
		clk		=> gls_clk,
		reset	=> gls_reset,
        start   => sobel_start,
		din		=> wbm_writedata,
        addr    => wbm_address,
		strobe	=> strobe,
		cycle	=> cycle,	
		c_sel	=> c_sel(1), 
		--adv		=> adv,
		ack		=> buffer_ack,
		wr		=> wr,
        ack_tick=> ack_tick,
		dout	=> buffer_dout,
        finish  => sobel_finish
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
