library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity elevator_ctrl_tb is
  port () ;
end elevator_ctrl_tb ; 

architecture arch of elevator_ctrl_tb is
    component elevator_ctrl
    port (
    reset_n : in std_logic;
    clk : in std_logic;
    up : out std_logic;
    down : out std_logic;
    openDoor : out std_logic;
    bns : in std_logic_vector(4 - 1 downto 0);
    ups : in std_logic_vector(4 - 1 downto 0);
    dns : in std_logic_vector(4 - 1 downto 0);
    floor_out : out std_logic_vector(7 - 1 downto 0)
  );
end component;
    signal reset_n : std_logic := '0';
    signal clk : std_logic := '0';
    signal up : std_logic := '0';
    signal down : std_logic := '0';
    signal openDoor : std_logic := '0';
    signal bns : std_logic_vector(4 - 1 downto 0) := (others => '0');
    signal ups : std_logic_vector(4 - 1 downto 0) := (others => '0');
    signal dns : std_logic_vector(4 - 1 downto 0) := (others => '0');
    signal floor_out : std_logic_vector(7 - 1 downto 0) := (others => '0');
    
    
begin
    elevator_ctrl_inst : elevator_ctrl
    port map (
      reset_n => reset_n,
      clk => clk,
      up => up,
      down => down,
      openDoor => openDoor,
      bns => bns,
      ups => ups,
      dns => dns,
      floor_out => floor_out
    );
  
end architecture ;