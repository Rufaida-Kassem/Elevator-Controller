library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elevator_ctrl is
  port (
    reset_n, clk : in std_logic;
    up, down, openDoor : out std_logic;
    bns : in std_logic_vector(4 - 1 downto 0);
    ups : in std_logic_vector(4 - 1 downto 0);
    dns : in std_logic_vector(4 - 1 downto 0);
    floor_out : out std_logic_vector(7 - 1 downto 0)
  );
end elevator_ctrl;

architecture arch of elevator_ctrl is
  signal req : std_logic_vector(6 - 1 downto 0);
  component seg_decoder
    port (
      in_decoder : in std_logic_vector(4 - 1 downto 0);
      out_decoder : out std_logic_vector(7 - 1 downto 0)
    );
  end component;

  component rr
    generic (
      N : natural
    );
    port (
      clk : in std_logic;
      bns : in std_logic_vector(N - 1 downto 0);
      ups : in std_logic_vector(N - 1 downto 0);
      dns : in std_logic_vector(N - 1 downto 0);
      req : out std_logic_vector(6 - 1 downto 0)
    );
  end component;

  component cu
    generic (
      N : natural
    );
    port (
      reset_n : in std_logic;
      fast_clk : in std_logic;
      mvup : out std_logic;
      mvdn : out std_logic;
      opnd : out std_logic;
      req : in std_logic_vector(6 - 1 downto 0);
      floor_out : out std_logic_vector(7 - 1 downto 0)
    );
  end component;

begin

  rr_inst : rr
  generic map(
    N => 4
  )
  port map(
    clk => clk,
    bns => bns,
    ups => "1111",
    dns => "1111",
    req => req
  );
  cu_inst : cu
  generic map(
    N => 4
  )
  port map(
    reset_n => reset_n,
    fast_clk => clk,
    mvup => up,
    mvdn => down,
    opnd => openDoor,
    req => req,
    floor_out => floor_out
  );

end architecture;