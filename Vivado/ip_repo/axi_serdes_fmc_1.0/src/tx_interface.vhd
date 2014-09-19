----------------------------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_misc.all;
  use ieee.std_logic_unsigned.all;
library unisim;
  use unisim.vcomponents.all;

entity tx_interface is
port (
  -- Input ports
  txclk_i        : in std_logic;
  txdata_i       : in std_logic_vector(9 downto 0);
  -- Output pins
  txdata_p_o     : out std_logic_vector(4 downto 0);
  txdata_n_o     : out std_logic_vector(4 downto 0);
  txclk_p_o      : out std_logic;
  txclk_n_o      : out std_logic
);
end tx_interface;

architecture tx_interface_syn of tx_interface is

signal txclk_ddr     : std_logic;
signal txdata_ddr    : std_logic_vector(4 downto 0);

begin

  ----------------------------------------------------------------------------------------------------
  -- Forwarded transmit clock
  ----------------------------------------------------------------------------------------------------

  -- Clock DDR
  clk_oddr_inst : ODDR
  generic map (
    DDR_CLK_EDGE => "SAME_EDGE"
  )
  port map (
    Q => txclk_ddr,
    C => txclk_i,
    CE => '1',
    D1 => '1',
    D2 => '0',
    R => '0',
    S => '0'
  );

  -- Differential output buffer
  clk_obufds_inst : OBUFDS
  port map (
    O  => txclk_p_o,
    OB => txclk_n_o,
    I  => txclk_ddr
  );
  
  ----------------------------------------------------------------------------------------------------
  -- Transmit data
  ----------------------------------------------------------------------------------------------------

  data: for i in 0 to 4 generate

    -- Data DDRs
    data_iddr_inst : ODDR
    generic map (
      DDR_CLK_EDGE => "SAME_EDGE"
    )
    port map (
      Q => txdata_ddr(i),
      C => txclk_i,
      CE => '1',
      D1 => txdata_i(2*i),
      D2 => txdata_i(2*i+1),
      R => '0',
      S => '0'
    );

    -- Differential output buffer
    data_obufds_inst : OBUFDS
    port map (
      O  => txdata_p_o(i),
      OB => txdata_n_o(i),
      I  => txdata_ddr(i)
    );

  end generate;
  
end tx_interface_syn;
