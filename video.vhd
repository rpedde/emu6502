---------------------------------------------------------------------------
-- Copyright (C) 2013 Ron Pedde <ron@pedde.com>
--
-- Simple VGA video hardware
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

  signal r_mode   : std_logic_vector(7 downto 0) := "00000000";

  signal r_bg     : std_logic_vector(5 downto 0) := "000000";
  signal r_fg     : std_logic_vector(5 downto 0) := "111111";

  -- dual-ported vram
  type vram_t is array(8191 downto 0) of std_logic_vector(7 downto 0);
  signal vram: vram_t;

  -- single-ported chargen ram
  type cgram_t is array(4095 downto 0) of unsigned(7 downto 0);

  impure function init_mem(mif_file_name : in string) return cgram_t is
    file mif_file : text open read_mode is mif_file_name;
    variable mif_line : line;
    variable temp_bv : bit_vector(7 downto 0);
    variable temp_mem : cgram_t;
  begin
    for i in 0 to 4095 loop
      readline(mif_file, mif_line);
      read(mif_line, temp_bv);
      temp_mem(i) := unsigned(To_StdLogicVector(temp_bv));
    end loop;
    return temp_mem;
  end function;

  signal cgram : cgram_t := init_mem("chargen.mif");

  signal current_char : std_logic_vector(7 downto 0);
  signal current_data : unsigned(7 downto 0);
  signal pixel_ofs : integer := 0;
  signal line_ofs : unsigned(3 downto 0) := "0000";
  signal char_ptr : integer := 0;
  signal line_ptr : integer := 0;
begin
  -- Dual port video memory

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

      -- current_char holds current bytewise data, and
      -- pixel_ofs if the offset in that bytewise_data
      if video_on = '1' then
        if current_data(7 - pixel_ofs) = '1' then
        --if (pixel_ofs = 0 and std_match(current_data, "1-------")) or
        --   (pixel_ofs = 1 and std_match(current_data, "-1------")) or
        --   (pixel_ofs = 2 and std_match(current_data, "--1-----")) or
        --   (pixel_ofs = 3 and std_match(current_data, "---1----")) or
        --   (pixel_ofs = 4 and std_match(current_data, "----1---")) or
        --   (pixel_ofs = 5 and std_match(current_data, "-----1--")) or
        --   (pixel_ofs = 6 and std_match(current_data, "------1-")) or
        --   (pixel_ofs = 7 and std_match(current_data, "-------1")) then
          red <= r_fg(5 downto 4);
          green <= r_fg(3 downto 2);
          blue <= r_fg(1 downto 0);
        else
          red <= r_bg(5 downto 4);
          green <= r_bg(3 downto 2);
          blue <= r_bg(1 downto 0);
        end if;

        if pixel_ofs = 7 then
          -- we just moved off the end of the current byte
          pixel_ofs <= 0;
          char_ptr <= char_ptr + 1;
          current_char <= vram(char_ptr);
          current_data <= cgram(to_integer((unsigned(current_char) * 16) + line_ofs));
        else
          pixel_ofs <= pixel_ofs + 1;
        end if;
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

        -- bump the line ofs
        if to_unsigned(v_cnt, 1) = "0" then
          line_ofs <= to_unsigned(to_integer(line_ofs) + 1, 4);
        end if;

        -- if over line, bump the line_ptr
        if line_ofs = "1010" then
          line_ofs <= "0000";
          --line_ptr <= line_ptr + 80;
          line_ptr <= char_ptr;
        else
          char_ptr <= line_ptr;
        end if;

        pixel_ofs <= 0;
      end if;

      if (v_cnt >= (V_W + V_FP)) and (v_cnt < (V_W + V_FP + V_RT)) then
        v_sync <= '0';
      else
        v_sync <= '1';
      end if;

      if v_cnt >= (V_W + V_FP + V_RT + V_BP) then
        v_cnt <= 0;

        -- reset pointers
        line_ptr <= 0;
        line_ofs <= "0000";
        char_ptr <= 0;

        current_char <= vram(char_ptr);
        current_data <= cgram(to_integer((unsigned(current_char) * 16) + line_ofs));
      end if;

    end if;
  end process;

  vram_p: process(clk, clk_25)
  begin
    if(clk'event and clk = '1') then
      if(enable_n = '0') then
        if(we = '1') then
          vram(to_integer(unsigned(addr))) <= di;
        end if;
        do <= vram(to_integer(unsigned(addr)));
      else
        do <= "ZZZZZZZZ";
      end if;
    end if;
  end process;

end behavioral;
