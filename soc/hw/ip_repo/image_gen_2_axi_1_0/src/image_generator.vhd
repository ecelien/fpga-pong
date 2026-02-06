--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY image_generator IS
  GENERIC(
    pixels_x    : INTEGER := 640; --width in pixels of the display
    pixels_y    : INTEGER := 400; --height in pixels of the display
    ball_width  : INTEGER := 10;
    ball_height : INTEGER := 10;
    pdl_width   : INTEGER := 10;
    pdl_height  : INTEGER := 100);
  PORT(
    disp_ena : in std_logic ;
    y        : in unsigned(9 downto 0); --y pixel coordinate
    x        : in unsigned(9 downto 0); --x pixel coordinate

    ball_y   : in unsigned(9 downto 0); -- ball y
    ball_x   : in unsigned(9 downto 0); -- ball x

    Lpdl_y   : in unsigned(9 downto 0); -- left paddle y

    Rpdl_y   : in unsigned(9 downto 0); -- right paddle y

    L_score  : in unsigned(2 downto 0); -- left player's score
    R_score  : in unsigned(2 downto 0); -- right player's score

    red      : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     : OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END image_generator;

ARCHITECTURE behavior of image_generator IS
    type char is array(0 to 4) of std_logic_vector(3 downto 0);
    constant c0: char := ("0110","1001","1001","1001","0110");
    constant c1: char := ("0011","0001","0001","0001","0001");
    constant c2: char := ("1110","0001","0110","1000","1111");
    constant c3: char := ("1110","0001","0110","0001","1110");
    constant c4: char := ("0010","0110","1010","1111","0010");
    constant c5: char := ("1111","1000","1110","0001","1110");
    constant c6: char := ("0110","1000","1110","1001","0110");
    constant c7: char := ("1111","0001","0010","1000","1000");
    signal disp_charL, disp_charR : char;
    
BEGIN
  PROCESS(disp_ena, y, x, Lpdl_y, Rpdl_y, L_score, R_score, ball_x, ball_y)
    variable tri_top : unsigned(9 downto 0);
    variable tri_bot : unsigned(9 downto 0);
    variable tri_xslope : unsigned(19 downto 0);
    variable tri_ballslope : unsigned(19 downto 0);
    variable tri_rise : unsigned(9 downto 0);
    variable tri_run : unsigned(9 downto 0);
    variable char_x : integer;
    variable char_y : integer;
  BEGIN

    IF(disp_ena = '1') THEN        --display time
      IF(y < pixels_y AND x < pixels_x) THEN
       case L_score is
           when "000" =>
               disp_charL <= c0;
           when "001" =>
               disp_charL <= c1;
           when "010" =>
               disp_charL <= c2;
           when "011" =>
               disp_charL <= c3;
           when "100" =>
               disp_charL <= c4;
           when "101" =>
               disp_charL <= c5;
           when "110" =>
               disp_charL <= c6;
           when "111" =>
               disp_charL <= c7;
           when others =>
                disp_charL <= (others => (others=> '1'));                
        end case;
        case R_score is
           when "000" =>
               disp_charR <= c0;
           when "001" =>
               disp_charR <= c1;
           when "010" =>
               disp_charR <= c2;
           when "011" =>
               disp_charR <= c3;
           when "100" =>
               disp_charR <= c4;
           when "101" =>
               disp_charR <= c5;
           when "110" =>
               disp_charR <= c6;
           when "111" =>
               disp_charR <= c7;
           when others =>
                disp_charR <= (others => (others=> '1'));                
        end case;
        tri_rise := to_unsigned(ball_height / 2,10);
        tri_run := to_unsigned(ball_width,10);
        tri_xslope := (tri_rise * x) / tri_run;
        tri_ballslope := (tri_rise * ball_x) / tri_run;
        tri_top := resize(ball_y + to_unsigned(ball_height,20) + tri_ballslope - tri_xslope,10);
        tri_bot := resize(ball_y - tri_ballslope + tri_xslope,10);
        if(((y > Lpdl_y) and (y < (Lpdl_y + pdl_height))) AND (x < pdl_width)) then
		    red <= (OTHERS => '0');
        	green  <= (OTHERS => '0');
        	blue <= (OTHERS => '1');
		elsif(((y > Rpdl_y) and (y < (Rpdl_y + pdl_height))) AND ((x > (pixels_x - pdl_width)))) then
			red <= "1111";
        	green  <= "0110";
        	blue <= "0000";
        elsif((((y > tri_bot) and (y < tri_top))) AND (((y > ball_y) and (y < (ball_y + ball_height))))AND ((x > ball_x) and (x < (ball_x + ball_width)))) then
            red <= (OTHERS => '1');
        	green  <= (OTHERS => '1');
        	blue <= (OTHERS => '1');
	    elsif((y mod 20 > 15) AND (x < 322) AND (x > 318)) then
	        red <= (OTHERS => '1');
        	green  <= (OTHERS => '1');
        	blue <= (OTHERS => '0');
	    elsif((y >= 20) AND (y < 35) AND (x >= 300) AND (x < 312)) then
	        char_x := 3-((TO_INTEGER(x) - 300) / 3);
	        char_y := (TO_INTEGER(y)-20) /3;
            if( disp_charL(char_y)(char_x) = '1') then 
                red <= (OTHERS => '0');
                green  <= (OTHERS => '0');
                blue <= (OTHERS => '1');
            else
                  red <= (OTHERS => '0');       
     	          green  <= (OTHERS => '0');
     	          blue <= (OTHERS => '0');
            end if;
        elsif((y >= 20) AND (y < 35) AND (x >= 328) AND (x < 340)) then
            char_x := 3-((TO_INTEGER(x) - 328) / 3);
            char_y := (TO_INTEGER(y)-20) /3;
            if( disp_charR(char_y)(char_x) = '1') then 
                red <= "1111";
                green  <= "0110";
                blue <= "0000";
            else
                  red <= (OTHERS => '0');       
                  green  <= (OTHERS => '0');
                  blue <= (OTHERS => '0');
            end if;
	    else
			red <= (OTHERS => '0');
        	green  <= (OTHERS => '0');
        	blue <= (OTHERS => '0');
	     end if;
      ELSE
        red <= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue <= (OTHERS => '0');
      END IF;
    ELSE                           --blanking time
      red <= (OTHERS => '0');
      green <= (OTHERS => '0');
      blue <= (OTHERS => '0');
    END IF;
  
  END PROCESS;
END behavior;

