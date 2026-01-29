library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Make game update every vsync = 0.
-- Ball origin is top left
--
-- 0,0 is top left

entity gamecontroller is
    generic (
        PIXEL_WIDTH:    positive := 10;
        XMAX:   integer := 639;
        XMIN:   integer := 0;
        YMAX:   integer := 399;
        YMIN:   integer := 0;
        SCORE_WIDTH:    positive := 3;
		PADDLE_HEIGHT: positive := 100;
		PADDLE_WIDTH: positive := 10;
		BALL_START_X: positive := 313;
		BALL_START_Y: positive := 211;
		BALL_WIDTH: positive := 10;
		BALL_X_MOVE: positive := 4;
		BALL_Y_MOVE: positive := 1
    );
    port (
        clk:    in std_logic;
        rst:    in std_logic;

        lpdl_up, lpdl_down: in std_logic;    
        rpdl_up, rpdl_down: in std_logic;
        vsync, hsync:       in std_logic;
        
        lscore_out, rscore_out: out unsigned(SCORE_WIDTH-1 downto 0);
        lpdl_y_out, rpdl_y_out: out unsigned(PIXEL_WIDTH-1 downto 0);
        ball_x_out, ball_y_out: out unsigned(PIXEL_WIDTH-1 downto 0)
    );
end entity gamecontroller;

architecture rtl of gamecontroller is

    -- State Machine
    -- type state_t is (START, WAIT, GAME, GOAL);
    -- signal state_reg, next_state  : state_t;
    
    -- Registered Outputs
    signal lscore_reg, rscore_reg:     unsigned(SCORE_WIDTH-1 downto 0);
    signal lpdl_y_reg, rpdl_y_reg:     unsigned(PIXEL_WIDTH-1 downto 0);
    signal ball_x_reg, ball_y_reg:     unsigned(PIXEL_WIDTH-1 downto 0);
	
	-- Other registers
	signal ball_x_vel_reg, ball_y_vel_reg : std_logic;

    -- Internal Signals
    signal lscore, rscore:     		unsigned(SCORE_WIDTH-1 downto 0);
    signal lpdl_y, rpdl_y:     		unsigned(PIXEL_WIDTH-1 downto 0);
    signal ball_x, ball_y:     		unsigned(PIXEL_WIDTH-1 downto 0);
	signal ball_x_vel, ball_y_vel: 	std_logic;
	
	-- counter
	signal counter :                unsigned(3 downto 0);
	
	-- game start
	signal game_start : std_logic;
	signal game_start_reg : std_logic;

begin

    UpdateFsm: process(clk, rst)
    begin
        if (rst = '1') then
            -- Reset registers
            -- state_reg <= START;
            lscore_reg <= (others => '0');
            rscore_reg <= (others => '0');
            lpdl_y_reg <= to_unsigned(150, lpdl_y'length);
            rpdl_y_reg <= to_unsigned(150, rpdl_y'length);
            ball_x_reg <= to_unsigned(BALL_START_X, ball_x_reg'length);
            ball_y_reg <= to_unsigned(BALL_START_Y, ball_x_reg'length);
			ball_x_vel_reg <= '1';
			ball_y_vel_reg <= '1';
			game_start_reg <= '0';

        elsif rising_edge(clk) then
            -- Update output registers
            -- state_reg <= next_state;
            lscore_reg <= lscore;
            rscore_reg <= rscore;
            lpdl_y_reg <= lpdl_y;
            rpdl_y_reg <= rpdl_y;
            ball_x_reg <= ball_x;
            ball_y_reg <= ball_y;
			ball_x_vel_reg <= ball_x_vel;
			ball_y_vel_reg <= ball_y_vel;
			game_start_reg <= game_start;
        end if;
    end process UpdateFsm;

    MovePaddles: process(vsync, lpdl_down, lpdl_up, lpdl_y_reg, rpdl_down, rpdl_up, rpdl_y_reg, game_start_reg) 
    begin
        -- default behavior
        lpdl_y <= lpdl_y_reg;
        rpdl_y <= rpdl_y_reg;
        game_start <= game_start_reg;

        -- Movement controls, updated every frame
        if (rising_edge(vsync)) then
            -- setting/clearing game_start
            if (ball_x_vel_reg = '0') then
                if (ball_x + BALL_X_MOVE + BALL_WIDTH) > XMAX then
                    if not((ball_y + BALL_WIDTH > rpdl_y) AND (ball_y < rpdl_y + PADDLE_HEIGHT)) then
                        game_start <= '0';
                        lpdl_y <= to_unsigned(150, lpdl_y'length);
                        rpdl_y <= to_unsigned(150, rpdl_y'length);
                    end if;
                end if;
            else
                if (ball_x - BALL_X_MOVE) > (XMAX + 100) then
                    if not ((ball_y + BALL_WIDTH > lpdl_y) AND (ball_y < lpdl_y + PADDLE_HEIGHT)) then
                        game_start <= '0';
                        lpdl_y <= to_unsigned(150, lpdl_y'length);
                        rpdl_y <= to_unsigned(150, rpdl_y'length);
                    end if;
                end if;
            end if;
            -- paddle movements
            if (lpdl_down = '1' AND lpdl_up = '0') then
                -- move down
                if(game_start_reg = '0') then
                    --lpdl_y <= to_unsigned(150, lpdl_y'length);
                    --rpdl_y <= to_unsigned(150, rpdl_y'length);
                    game_start <= '1';
                end if;
                if(lpdl_y_reg < YMAX-PADDLE_HEIGHT) then 
                    lpdl_y <= lpdl_y_reg + 10;
                end if;
                
            elsif (lpdl_down = '0' AND lpdl_up = '1') then
                -- move up
                if(game_start_reg = '0') then
                    game_start <= '1';
                end if;
                if(lpdl_y_reg > YMIN) then 
                    lpdl_y <= lpdl_y_reg - 10;
                end if;
            end if;

            -- right paddle movement
            if (rpdl_down = '1' AND rpdl_up = '0') then
                -- move down
                if(game_start_reg = '0') then
                    --lpdl_y <= to_unsigned(150, lpdl_y'length);
                    --rpdl_y <= to_unsigned(150, rpdl_y'length);
                    game_start <= '1';
                end if;
                if(rpdl_y_reg < YMAX-PADDLE_HEIGHT) then 
                    rpdl_y <= rpdl_y_reg + 10;
                end if;
                
            elsif (rpdl_down = '0' AND rpdl_up = '1') then
                -- move up
                if(game_start_reg = '0') then
                    --lpdl_y <= to_unsigned(150, lpdl_y'length);
                    --rpdl_y <= to_unsigned(150, rpdl_y'length);
                    game_start <= '1';
                end if;
                if(rpdl_y_reg > YMIN) then 
                    rpdl_y <= rpdl_y_reg - 10;
                end if;
            end if;
        end if;
    end process MovePaddles;
	
	
    MoveBall: process(vsync, ball_x_reg, ball_y_reg, ball_x_vel_reg, ball_y_vel_reg, lpdl_y, rpdl_y, rscore_reg, lscore_reg, game_start_reg)
        --variable bounce_Var or smth lol
    begin
        -- default behavior ball_x reg
        ball_x <= ball_x_reg;
        ball_y <= ball_y_reg;
        lscore <= lscore_reg;
        rscore <= rscore_reg;

        if (rising_edge(vsync) and game_start_reg = '1') then
--            updating ball
            if (ball_x_vel_reg = '0') then -- 0 is right
                ball_x <= ball_x_reg + BALL_X_MOVE;
            else
                ball_x <= ball_x_reg - BALL_X_MOVE;
            end if;
            
            if (ball_y_vel_reg = '0') then -- 0 is down
                ball_y <= ball_y_reg + BALL_Y_MOVE;
            else
                ball_y <= ball_y_reg - BALL_Y_MOVE;
            end if;
            
--            collision
--            left and right walls first
            if (ball_x_vel_reg = '0') then
                if (ball_x + BALL_X_MOVE + BALL_WIDTH) > XMAX then
                    if(ball_y + BALL_WIDTH > rpdl_y) AND (ball_y < rpdl_y + PADDLE_HEIGHT) then
                        ball_x <= to_unsigned(XMAX-10, ball_x_reg'length);
                        ball_x_vel <= '1';
                    else
                        ball_y <= to_unsigned(BALL_START_Y, ball_y_reg'length);
                        ball_x <= to_unsigned(BALL_START_X, ball_x_reg'length);
                        ball_x_vel <= '1';
                        if (lscore_reg = "111") then
                            lscore <= "000";
                            rscore <= "000";
                        else
                            lscore <= lscore_reg + 1;
                        end if;
                    end if;
                end if;
            else
                if (ball_x - BALL_X_MOVE) > (XMAX + 100) then
                    if(ball_y + BALL_WIDTH > lpdl_y) AND (ball_y < lpdl_y + PADDLE_HEIGHT) then
                        ball_x <= to_unsigned(10, ball_x_reg'length);
                        ball_x_vel <= '0';
                    else
                        ball_y <= to_unsigned(BALL_START_Y, ball_y_reg'length);
                        ball_x <= to_unsigned(BALL_START_X, ball_x_reg'length);
                        ball_x_vel <= '0';
                        if (rscore_reg = "111") then
                            lscore <= "000";
                            rscore <= "000";
                        else
                            rscore <= rscore_reg + 1;
                        end if;
                    end if;
                end if;
            end if;
--            top and bottom walls     
            if (ball_y_vel_reg = '0') then
                if (ball_y + BALL_Y_MOVE + BALL_WIDTH) > YMAX then
                    ball_y <= to_unsigned(YMAX-BALL_WIDTH, ball_y_reg'length);
                    ball_y_vel <= '1';
                end if;
            else
                if (ball_y - BALL_Y_MOVE) > (YMAX + 100) then
                    ball_y <= to_unsigned(2, ball_y_reg'length);
                    ball_y_vel <= '0';
                end if;
            end if;
        end if;
        if (game_start_reg = '0') then
            ball_x <= to_unsigned(BALL_START_X, ball_x_reg'length);
            ball_y <= to_unsigned(BALL_START_Y, ball_x_reg'length);
        end if;
    end process MoveBall;
	
	



    -- Concurrent assignment of outputs
    lpdl_y_out <= lpdl_y_reg;
    rpdl_y_out <= rpdl_y_reg;
    lscore_out <= lscore_reg;
    rscore_out <= rscore_reg;
    ball_x_out <= ball_x_reg;
    ball_y_out <= ball_y_reg;
end architecture rtl;