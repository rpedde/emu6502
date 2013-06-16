---------------------------------------------------------------------------
-- Copyright (C) 2013 Ron Pedde <ron@pedde.com>
--
-- Simple 3 to 8 decoder for address decoding
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity vga_640_video is port (
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
end vga_640_video;

architecture behavioral of vga_640_video is
  constant H_W   : integer := 640; -- horizontal width
  constant H_FP  : integer := 16;  -- horizontal front porch
  constant H_BP  : integer := 48;  -- horizontal back porch
  constant H_RT  : integer := 96;  -- horizontal retrace

  constant V_W   : integer := 480;
  constant V_FP  : integer := 11;
  constant V_BP  : integer := 31;
  constant V_RT  : integer := 2;

  signal video_on : std_logic;
  signal clk_25   : std_logic;

  signal h_cnt    : integer := 0;
  signal v_cnt    : integer := 0;

begin
  -- Set up a 25 mhz from clk_12
  DCM_SP_inst : DCM_SP
  generic map (
    CLKFX_DIVIDE    => 12,
    CLKFX_MULTIPLY  => 25
  )
  port map (
    CLKFX => clk_25,
    CLKIN => clk_12,
    RST   => '0'
  );

  process(clk_25)
  begin
    if clk_25'event and clk_25='1' then
      if (h_cnt >= H_W) or (v_cnt >= V_W) then
        video_on <= '0';
      else
        video_on <= '1';
      end if;

      -- paint!
      if video_on = '1' then
        red <= "11";
        green <= "11";
        blue <= "11";
      else
        red <= "00";
        green <= "00";
        blue <= "00";
      end if;

      -- update h_sync and v_sync
      h_cnt <= h_cnt + 1;

      if (h_cnt >= (H_W + H_FP)) and (h_cnt < (H_W + H_FP + H_RT)) then
        h_sync <= '0';
      else
        h_sync <= '1';
      end if;

      if h_cnt >= (H_W + H_FP + H_RT + H_BP) then
        h_cnt <= 0;
        v_cnt <= v_cnt + 1;
      end if;

      if (v_cnt >= (V_W + V_FP)) and (v_cnt < (V_W + V_FP + V_RT)) then
        v_sync <= '0';
      else
        v_sync <= '1';
      end if;

      if v_cnt >= (V_W + V_FP + V_RT + V_BP) then
        v_cnt <= 0;
      end if;

    end if;
  end process;

  do <= "ZZZZZZZZ";

end behavioral;
