--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   00:47:25 01/07/2013
-- Design Name:
-- Module Name:   C:/Users/rpedde/Documents/Xilinx/emu6502/root_tb.vhd
-- Project Name:  emu6502
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: root
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY root_tb IS
END root_tb;

ARCHITECTURE behavior OF root_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT root
    PORT(
      clk_12      : in  std_logic;
      blinker_o   : out std_logic;
      m_t65_a     : out std_logic_vector(15 downto 0);
      m_t65_clk   : out std_logic;
      m_t65_di    : out std_logic_vector(7 downto 0);
      m_t65_do    : out std_logic_vector(7 downto 0);
      m_t65_res   : out std_logic;
      m_rw        : out std_logic;
      m_ram_enable: out std_logic_vector(7 downto 0);
      m_ram_out   : out std_logic_vector(7 downto 0)
      );
    END COMPONENT;


   --Inputs
   signal clk_12 : std_logic := '0';
   signal blinker_o : std_logic;

   signal m_t65_a     : std_logic_vector(15 downto 0);
   signal m_t65_clk   : std_logic;
   signal m_t65_di    : std_logic_vector(7 downto 0);
   signal m_t65_do    : std_logic_vector(7 downto 0);
   signal m_t65_res   : std_logic;
   signal m_rw        : std_logic;
   signal m_ram_enable: std_logic_vector(7 downto 0);
   signal m_ram_out   : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_12_period : time := 10 ns;

begin
   -- Instantiate the Unit Under Test (UUT)
   uut: root port map (
     clk_12      => clk_12,
     blinker_o   => blinker_o,
     m_t65_a     => m_t65_a,
     m_t65_clk   => m_t65_clk,
     m_t65_di    => m_t65_di,
     m_t65_do    => m_t65_do,
     m_t65_res   => m_t65_res,
     m_rw        => m_rw,
     m_ram_enable=> m_ram_enable,
     m_ram_out   => m_ram_out
     );

   -- Clock process definitions
   clk_12_process :process
   begin
     clk_12 <= '0';
     wait for clk_12_period/2;
     clk_12 <= '1';
     wait for clk_12_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
      ---- hold reset state for 100 ns.
      --wait for 100 ns;
      --res <= '1';

      --wait for clk_12_period*10;

      ---- insert stimulus here

      wait;
   end process;
end;
