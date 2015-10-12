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
    -- gls_reset : in std_logic;
    ext_clk   : in std_logic;
    led_a	  : out std_logic;
   -- led_c 	  : out std_logic;
    button    : in std_logic;
    gls_irq   : out std_logic
);
end entity;

Architecture RTL of top_level is
	signal c_sel: std_logic_vector(2 downto 0);
	signal adv:std_logic;
	signal led_ack, bt_ack: std_logic;
	signal led_dout, bt_dout: std_logic_vector(15 downto 0) ;
	signal wbm_address, wbm_readdata, wbm_writedata : std_logic_vector(15 downto 0) ;
	signal wbm_strobe, wbm_write, wbm_ack, wbm_cycle: std_logic;
	signal strobe,cycle, wr: std_logic;
    signal gls_reset, gls_clk: std_logic;
    signal irq_dout : std_logic_vector(15 downto 0);
    signal irq_ack, bt_irq : std_logic;
    signal irq_port: std_logic_vector(15 downto 0);
begin
 -- led_c <= '0';
  irq_port <= "000000000000000" & bt_irq;
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
        gls_irq         => gls_irq
        );
        
    
    
	led_ent: entity work.led
	port map(
		clk		=> gls_clk,
		reset	=> gls_reset,
		din		=> wbm_writedata,
		strobe	=> strobe,
		cycle	=> cycle,	
		c_sel	=> c_sel(1), 
		adv		=> adv,
		ack		=> led_ack,
		wr		=> wr,
		dout	=> led_dout,
		led		=>led_a
	);

	but_ent: entity work.button
	port map(
		clk		=> gls_clk,
		reset	=> gls_reset,
		--din		=> wbm_writedata,
		strobe	=> strobe,
		cycle	=> cycle,
		c_sel	=> c_sel(2), 
		adv		=> adv,
		ack		=> bt_ack,
		wr		=> wr,
        sw      => button,
        irq     => bt_irq,
		dout	=> bt_dout
	);

	wbm_readdata <= led_dout when led_ack = '1' else
                    bt_dout when bt_ack='1' else
                    irq_dout when irq_ack = '1' else
                    (others=>'0');
	wbm_ack <= led_ack or bt_ack or irq_ack;

end architecture RTL;
