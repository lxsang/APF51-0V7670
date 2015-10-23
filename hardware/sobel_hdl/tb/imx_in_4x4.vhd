library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.numeric_std.all ;

entity imx_in is
  port (
    reset: in std_logic;
	clk:in std_logic;
    start: in std_logic;
	da  : out std_logic_vector(15 downto 0);
    --ready  : out std_logic;
    adv    : out std_logic;
    cs     : out std_logic;
    rw     : out std_logic;
    finish : in std_logic
  ) ;
end entity imx_in;

architecture arch of imx_in is
  type ram_type is array (0 to 2**8-1) of std_logic_vector(15 downto 0) ;
  
	signal ram:ram_type  := (

      others=>(others=>'0')
      );
  type state_type is(IDLE,WR1, WR2,WR3,WR4);
  constant offset : integer := 8;
  constant dlen : integer := 8;
  signal state,state_next: state_type;
  signal ram_addr, ram_addr_next: unsigned(7 downto 0) ;
  signal read_mode : std_logic := '0';
begin
    process(clk)
	begin
      if reset = '1' then
        ram_addr <= (others=>'0');
        state <= IDLE;
        read_mode <= '0';
      elsif falling_edge(clk) then
        ram_addr<= ram_addr_next;
        state <= state_next;
        if finish = '1' then
          read_mode <= '1';
        else
          read_mode <= read_mode;
        end if;
        
      end if;
      
	end process ; -- 
    
    -- combinational circuit
    process(start, state, ram_addr, finish)
    begin
      state_next <= state;
      ram_addr_next <= ram_addr;
      adv <= '1';
      cs <= '1';
      rw <= '1';
      --ready <= '0';
      case state is
        when IDLE=>
          da <= (others=>'0');
          if start = '1'  then
            --adv <= '0';
            ram_addr_next <= (others=>'0');
            --state_next <= WR1;
          elsif(ram_addr < dlen) then
            adv <= '0';
            da<= std_logic_vector(("0"&ram_addr&"0") + offset);
            state_next <= WR1;
          elsif ram_addr = dlen then
            -- start the sobel calcul
            adv <= '0';
            da <= X"0004"; -- trigger the sobel
            state_next <= WR1;
          elsif finish = '1' then
            ram_addr_next <= (others=>'0');
          end if;

        when WR1=>
          state_next <= WR2;
          da <= ram(to_integer(ram_addr));
          cs <= '0';
          if read_mode = '0' then
            rw <= '0';
          end if;
          
        when WR2=>
          state_next <= WR3;
          cs <= '0';
          if read_mode = '0' then
            rw <= '0';
          end if;

        when WR3=>
          state_next <= WR4;
          cs <= '0';
          if read_mode = '0' then
            rw <= '0';
          end if;
        when WR4=>
          state_next <= IDLE;
          cs <= '0';
          if read_mode = '0' then
            rw <= '0';
          end if;
          ram_addr_next<= ram_addr + 1;
      end case;
      
    end process;
    
end architecture ; -- arch
