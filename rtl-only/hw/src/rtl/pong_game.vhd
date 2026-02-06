library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Pong_Game is
  port(
    btnU       : in std_logic;
    btnD       : in std_logic;
    btnL       : in std_logic;
    btnR       : in std_logic;
    clk_100MHz : in  std_logic;
    rst        : in  std_logic;
    rst_game   : in  std_logic;
    red        : out std_logic_vector(3 downto 0);
    green      : out std_logic_vector(3 downto 0);
    blue       : out std_logic_vector(3 downto 0);
    h_sync     : out std_logic;
    v_sync     : out std_logic);

end Pong_Game;

architecture BHV of Pong_Game is
	signal x_value   : unsigned (9 downto 0);
	signal y_value   : unsigned (9 downto 0);
	signal h_sync_s  : std_logic;
	signal v_sync_s  : std_logic;
	signal disp_ena  : std_logic;
--	signal n_blank   : std_logic;
--	signal n_sync    : std_logic;

--hardcoded values *temporary*
	signal ballx : unsigned(9 downto 0);
	signal bally : unsigned(9 downto 0);
	signal Lpdly : unsigned(9 downto 0);
	signal Rpdly : unsigned(9 downto 0);

	signal Lscore : unsigned(2 downto 0);
	signal Rscore : unsigned(2 downto 0);

begin
    U_VGA_Ctrl : entity work.vga_controller
	Port map(
		clk_100MHz => clk_100MHz,
		reset    => rst,
		hsync    => h_sync_s,
		vsync    => v_sync_s,
		video_on => disp_ena,
		x        => x_value,
		y        => y_value
		);
--Set synchrinization signals	
	v_sync <= v_sync_s;
	h_sync <= h_sync_s;
		
	U_Game_Ctrl : entity work.gamecontroller
	   port map(
	       clk        => clk_100MHz,
           rst        => rst_game,
           lpdl_up    => BtnL,
           lpdl_down  => BtnD,    
           rpdl_up    => BtnU,
           rpdl_down  => BtnR,
           vsync      => v_sync_s,
           hsync      => h_sync_s,
           lscore_out => Lscore,
           rscore_out => Rscore,
           lpdl_y_out => Lpdly,
           rpdl_y_out => Rpdly,
           ball_x_out => ballx,
           ball_y_out => bally
	       );

    U_Im_Gen : entity work.image_generator
	Port map(
			disp_ena => disp_ena,
			x        => x_value,
			y        => y_value,
			ball_x   => ballx,
			ball_y   => bally,
			Lpdl_y   => Lpdly,
			Rpdl_y   => Rpdly,
			L_score  => Lscore,
			R_score  => Rscore,
			red      => red,
			green    => green,
			blue     => blue
		);
end BHV;