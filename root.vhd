------------------------------------------------------------------------
-- Copyright (C) 2013 Ron Pedde <ron@pedde.com>
--
-- 6502 system, based on the FPGAArcade version of the opencores T65
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity root is port (
  clk_12      : in std_logic;
  blinker_o   : out std_logic := '1';
  m_t65_a     : out std_logic_vector(15 downto 0);
  m_t65_clk   : out std_logic;
  m_t65_di    : out std_logic_vector(7 downto 0);
  m_t65_do    : out std_logic_vector(7 downto 0);
  m_t65_res   : out std_logic;
  m_rw        : out std_logic;
  m_ram_enable: out std_logic_vector(7 downto 0);
  m_ram_out   : out std_logic_vector(7 downto 0);

  green_physout : out std_logic_vector(1 downto 0);
  red_physout   : out std_logic_vector(1 downto 0);
  blue_physout  : out std_logic_vector(1 downto 0);

  v_sync_physout : out std_logic;
  h_sync_physout : out std_logic
  );
end root;

architecture rtl of root is
  signal t65_mode    : std_logic_vector(1 downto 0) := "00";
  signal t65_res     : std_logic;
  signal t65_en      : std_logic := '1';
  signal t65_rdy     : std_logic := '1';
  signal t65_abort   : std_logic := '1';
  signal t65_irq     : std_logic := '1';
  signal t65_nmi     : std_logic := '1';
  signal t65_so      : std_logic := '1';
  signal t65_rw      : std_logic;
  signal t65_rw_i    : std_logic;
  signal t65_sync    : std_logic;
  signal t65_ef      : std_logic;
  signal t65_mf      : std_logic;
  signal t65_xf      : std_logic;
  signal t65_ml      : std_logic;
  signal t65_vp      : std_logic;
  signal t65_vda     : std_logic;
  signal t65_vpa     : std_logic;
  signal t65_a       : std_logic_vector(23 downto 0) := "000000000000000000000000";
  signal t65_di      : std_logic_vector(7 downto 0) := "00000000";
  signal t65_do      : std_logic_vector(7 downto 0) := "ZZZZZZZZ";

  signal ram_enable  : std_logic_vector(7 downto 0);

  signal clk_2       : std_logic;
  signal startup_res : std_logic := '0';
  signal startup_cnt : std_logic_vector(11 downto 0) := "000000000000";
  signal ram_clk     : std_logic;
  signal ram_out     : std_logic_vector(7 downto 0);
  signal clk_cnt     : std_logic_vector(2 downto 0) := "000";

component ram_8k is port (
  clk      : in  std_logic;
  addr     : in  std_logic_vector(12 downto 0);
  we       : in  std_logic;
  enable_n : in  std_logic;
  di       : in  std_logic_vector(7 downto 0);
  do       : out std_logic_vector(7 downto 0)
  );
end component;

component vga_640_video is port (
  -- the 8k dual-port vram
  clk        : in  std_logic;
  addr       : in  std_logic_vector (12 downto 0);
  we         : in  std_logic;
  enable_n   : in  std_logic;
  di         : in  std_logic_vector(7 downto 0);
  do         : out std_logic_vector(7 downto 0);

  -- vga color info (awesome 6 bit color!)
  red        : out std_logic_vector(1 downto 0);
  green      : out std_logic_vector(1 downto 0);
  blue       : out std_logic_vector(1 downto 0);

  -- vga timing info
  v_sync     : out std_logic;
  h_sync     : out std_logic;

  -- XuLA provides a 12Mhz clock.  We want this clock
  clk_12     : in std_logic
  );
end component;

component decoder3to8 is port (
  a        : in std_logic_vector(2 downto 0);
  e        : out std_logic_vector(7 downto 0)
  );
end component;

--component poreset is port (
--  clk      : in  std_logic;
--  reset_in : in  std_logic;
--  reset_out: out std_logic := '0'
--  );
--end component;

component T65 is port (
  Mode     : in std_logic_vector(1 downto 0);
  Res_n    : in std_logic;
  Enable   : in std_logic;
  Clk      : in std_logic;
  Rdy      : in std_logic;
  Abort_n  : in std_logic;
  IRQ_n    : in std_logic;
  NMI_n    : in std_logic;
  SO_n     : in std_logic;
  R_W_n    : out std_logic;
  Sync     : out std_logic;
  EF       : out std_logic;
  MF       : out std_logic;
  XF       : out std_logic;
  ML_n     : out std_logic;
  VP_n     : out std_logic;
  VDA      : out std_logic;
  VPA      : out std_logic;
  A        : out std_logic_vector(23 downto 0);
  DI       : in std_logic_vector(7 downto 0);
  DO       : out std_logic_vector(7 downto 0)
  );
end component;

begin
cpu: T65 port map(
  Mode    => t65_mode,
  Res_n   => t65_res,
  Enable  => t65_en,
  Clk     => clk_2,
  Rdy     => t65_rdy,
  Abort_n => t65_abort,
  IRQ_n   => t65_irq,
  NMI_n   => t65_nmi,
  SO_n    => t65_so,
  R_W_n   => t65_rw,
  Sync    => t65_sync,
  EF      => t65_ef,
  MF      => t65_mf,
  XF      => t65_xf,
  ML_n    => t65_ml,
  VP_n    => t65_vp,
  VDA     => t65_vda,
  VPA     => t65_vpa,
  A       => t65_a,
  DI      => t65_di,
  DO      => t65_do
  );

decoder: decoder3to8 port map(
  a    => t65_a(15 downto 13),
  e    => ram_enable
);

ram_e000: ram_8k port map(
  clk      => ram_clk,
  addr     => t65_a(12 downto 0),
  we       => t65_rw_i,
  enable_n => ram_enable(7),
  di       => t65_do,
  do       => ram_out
);

video: vga_640_video port map (
  clk      => ram_clk,
  addr     => t65_a(12 downto 0),
  we       => t65_rw_i,
  enable_n => ram_enable(6), -- c000-dfff
  di       => t65_do,
  do       => ram_out,

  red      => red_physout,
  green    => green_physout,
  blue     => blue_physout,

  v_sync   => v_sync_physout,
  h_sync   => h_sync_physout,

  clk_12   => clk_12
);

process(clk_12) is
begin
  if rising_edge(clk_12) then
    clk_cnt <= clk_cnt + 1;
    if clk_cnt = "111" then
      if (startup_cnt(11) /= '1') then
        startup_cnt <= startup_cnt + 1;
        startup_res <= '0';
      else
        startup_res <= '1';
      end if;
    end if;
  end if;
end process;


t65_res <= startup_res;

clk_2 <= clk_cnt(2);
ram_clk <= not clk_2;

t65_rw_i <= not t65_rw;

-- LSB of address 0 is LED
blinker_p: process(clk_2) begin
  if(clk_2'event and clk_2 = '0') then
    if ((t65_rw = '0') and (t65_a(15 downto 0) = "0000000000000000")) then
      blinker_o <= t65_do(0);
    end if;
  end if;
end process;

--blinker_o <= t65_do(0) when (t65_rw = '0' and t65_a = "0000000000000000");

-- Outputs for top level device
t65_di <= ram_out when t65_rw = '1' else "ZZZZZZZZ";

m_t65_a <= t65_a(15 downto 0);
m_t65_clk <= clk_2;
m_t65_di <= t65_di;
m_t65_do <= t65_do;
m_t65_res <= t65_res;
m_rw <= t65_rw;
m_ram_enable <= ram_enable;
m_ram_out <= ram_out;

end rtl;
