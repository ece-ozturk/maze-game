library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity maze_graph_module is
	port( board_clock, reset: IN STD_LOGIC;
			btn: IN STD_LOGIC_VECTOR(3 downto 0); --up, down, left, right
			display: IN STD_LOGIC;
			pixel_x, pixel_y: IN STD_LOGIC_VECTOR(9 downto 0);
			graph_rgb: OUT STD_LOGIC_VECTOR(7 downto 0));
end maze_graph_module;
	
architecture arch1 of maze_graph_module is

	--to check 60 Hz screen refresh rate
	signal refresh60: STD_LOGIC; 

	signal pix_x, pix_y: UNSIGNED(9 downto 0); --where are you? from (0, 0) to (639, 479)
	
	constant MAX_X: INTEGER :=640; --end of screen
	constant MAX_Y: INTEGER :=480;
	
	--wall 1
	constant W1_X_L: INTEGER := 1;
	constant W1_X_R: INTEGER := 12;
	constant W1_Y_T: INTEGER := 1;
	constant W1_Y_B: INTEGER := 478;
	
	--wall 2
	constant W2_X_L: INTEGER := 1;
	constant W2_X_R: INTEGER := 638;
	constant W2_Y_T: INTEGER := 1;
	constant W2_Y_B: INTEGER := 12;
	
	--wall 3
	constant W3_X_L: INTEGER := 627;
	constant W3_X_R: INTEGER := 638;
	constant W3_Y_T: INTEGER := 1;
	constant W3_Y_B: INTEGER := 478;
	
	--wall 4
	constant W4_X_L: INTEGER := 1;
	constant W4_X_R: INTEGER := 638;
	constant W4_Y_T: INTEGER := 467;
	constant W4_Y_B: INTEGER := 478;
	
	------
	
	
	--wall 5
	constant W5_X_L: INTEGER := 69;
	constant W5_X_R: INTEGER := 427;
	constant W5_Y_T: INTEGER := 78;
	constant W5_Y_B: INTEGER := 90;
	
	--wall 6
	constant W6_X_L: INTEGER := 69;
	constant W6_X_R: INTEGER := 345;
	constant W6_Y_T: INTEGER := 156;
	constant W6_Y_B: INTEGER := 168;
	
	--wall 7
	constant W7_X_L: INTEGER := 138;
	constant W7_X_R: INTEGER := 427;
	constant W7_Y_T: INTEGER := 234;
	constant W7_Y_B: INTEGER := 246;
	
	--wall 8
	constant W8_X_L: INTEGER := 207;
	constant W8_X_R: INTEGER := 497;
	constant W8_Y_T: INTEGER := 312;
	constant W8_Y_B: INTEGER := 324;
	
	--wall 9
	constant W9_X_L: INTEGER := 138;
	constant W9_X_R: INTEGER := 567;
	constant W9_Y_T: INTEGER := 390;
	constant W9_Y_B: INTEGER := 402;
	
	--wall 10
	constant W10_X_L: INTEGER := 555;
	constant W10_X_R: INTEGER := 626;
	constant W10_Y_T: INTEGER := 312;
	constant W10_Y_B: INTEGER := 324;
	
	--wall 11
	constant W11_X_L: INTEGER := 69;
	constant W11_X_R: INTEGER := 81;
	constant W11_Y_T: INTEGER := 168;
	constant W11_Y_B: INTEGER := 466;
	
	--wall 12
	constant W12_X_L: INTEGER := 138;
	constant W12_X_R: INTEGER := 150;
	constant W12_Y_T: INTEGER := 234;
	constant W12_Y_B: INTEGER := 402;
	
	--wall 13
	constant W13_X_L: INTEGER := 415;
	constant W13_X_R: INTEGER := 427;
	constant W13_Y_T: INTEGER := 78;
	constant W13_Y_B: INTEGER := 246;
	
	--wall 14
	constant W14_X_L: INTEGER := 485;
	constant W14_X_R: INTEGER := 497;
	constant W14_Y_T: INTEGER := 13;
	constant W14_Y_B: INTEGER := 324;
	
	--wall 15
	constant W15_X_L: INTEGER := 555;
	constant W15_X_R: INTEGER := 567;
	constant W15_Y_T: INTEGER := 78;
	constant W15_Y_B: INTEGER := 324;
	
	--wall 16
	constant W16_X_L: INTEGER := 555;
	constant W16_X_R: INTEGER := 567;
	constant W16_Y_T: INTEGER := 390;
	constant W16_Y_B: INTEGER := 466;
	
	--win
	constant WIN_X_L: INTEGER := 568;
	constant WIN_X_R: INTEGER := 626;
	constant WIN_Y_T: INTEGER := 403;
	constant WIN_Y_B: INTEGER := 466;
	
	
	
	------
	
	
	--MOVING BALL
	constant BALL_SIZE: INTEGER :=8;
	signal ball_x_l, ball_x_r, ball_y_t, ball_y_b: UNSIGNED(9 downto 0);
	--ball's a and y-positions are changing, to track:
	signal curr_ball_x, next_ball_x: UNSIGNED(9 downto 0);
	signal curr_ball_y, next_ball_y: UNSIGNED(9 downto 0);
	constant BALL_VEL: INTEGER :=1;
	
	--ROUND SHAPE IN ROM:
	type type_rom is array(0 to 7) of STD_LOGIC_VECTOR(0 to 7);
	constant BALL_ROM: type_rom:= (
	"00111100",
	"01111110",
	"11111111",
	"11111111",
	"11111111",
	"11111111",
	"01111110",
	"00111100"
	);
	
	signal rom_row, rom_col: UNSIGNED(2 downto 0);
	signal rom_data: STD_LOGIC_VECTOR(7 downto 0);
	signal rom_bit: STD_LOGIC;
	
	
	signal win_on, w1_on, w2_on, w3_on, w4_on, w5_on, w6_on, w7_on, w8_on, w9_on, w10_on, w11_on, w12_on, w13_on, w14_on, w15_on, w16_on, sq_ball_on, round_ball_on: STD_LOGIC;
	signal win_rgb, w1_rgb, w2_rgb, w3_rgb, w4_rgb, w5_rgb, w6_rgb, w7_rgb, w8_rgb, w9_rgb, w10_rgb, w11_rgb, w12_rgb, w13_rgb, w14_rgb, w15_rgb, w16_rgb, ball_rgb: STD_LOGIC_VECTOR(7 downto 0);
	
begin

	process(board_clock, reset)
	begin
		if reset='1' then
			curr_ball_x <= ("0000101000");
			curr_ball_y <= ("0000101000");
		elsif(rising_edge(board_clock)) then
			curr_ball_y <= next_ball_y;
			curr_ball_x <= next_ball_x;
		end if;
	end process;

	pix_x <= unsigned(pixel_x);
	pix_y <= unsigned(pixel_y);
	
	refresh60 <= '1' when (pix_y=481) and (pix_x=0) else '0';
	
	--WALLS
	win_on <= '1' when (win_x_l <= pix_x) and (pix_x <= win_x_r) and (win_y_b >= pix_y) and (pix_y >= win_y_t) else '0';
	win_rgb <= "11111110"; 
	
	w1_on <= '1' when (w1_x_l <= pix_x) and (pix_x <= w1_x_r) and (w1_y_b >= pix_y) and (pix_y >= w1_y_t) else '0';
	w1_rgb <= "10011111"; --green
	
	w2_on <= '1' when (w2_x_l <= pix_x) and (pix_x <= w2_x_r) and (w2_y_b >= pix_y) and (pix_y >= w2_y_t) else '0';
	w2_rgb <= "10011111"; --green
	
	w3_on <= '1' when (w3_x_l <= pix_x) and (pix_x <= w3_x_r) and (w3_y_b >= pix_y) and (pix_y >= w3_y_t) else '0';
	w3_rgb <= "10011111"; --green
	
	w4_on <= '1' when (w4_x_l <= pix_x) and (pix_x <= w4_x_r) and (w4_y_b >= pix_y) and (pix_y >= w4_y_t) else '0';
	w4_rgb <= "10011111"; --green
	
	w5_on <= '1' when (w5_x_l <= pix_x) and (pix_x <= w5_x_r) and (w5_y_b >= pix_y) and (pix_y >= w5_y_t) else '0';
	w5_rgb <= "10011111"; --green
	
	w6_on <= '1' when (w6_x_l <= pix_x) and (pix_x <= w6_x_r) and (w6_y_b >= pix_y) and (pix_y >= w6_y_t) else '0';
	w6_rgb <= "10011111"; --green
	
	w7_on <= '1' when (w7_x_l <= pix_x) and (pix_x <= w7_x_r) and (w7_y_b >= pix_y) and (pix_y >= w7_y_t) else '0';
	w7_rgb <= "10011111"; --green
	
	w8_on <= '1' when (w8_x_l <= pix_x) and (pix_x <= w8_x_r) and (w8_y_b >= pix_y) and (pix_y >= w8_y_t) else '0';
	w8_rgb <= "10011111"; --green
	
	w9_on <= '1' when (w9_x_l <= pix_x) and (pix_x <= w9_x_r) and (w9_y_b >= pix_y) and (pix_y >= w9_y_t) else '0';
	w9_rgb <= "10011111"; --green
	
	w10_on <= '1' when (w10_x_l <= pix_x) and (pix_x <= w10_x_r) and (w10_y_b >= pix_y) and (pix_y >= w10_y_t) else '0';
	w10_rgb <= "10011111"; --green
	
	w11_on <= '1' when (w11_x_l <= pix_x) and (pix_x <= w11_x_r) and (w11_y_b >= pix_y) and (pix_y >= w11_y_t) else '0';
	w11_rgb <= "10011111"; --green
	
	w12_on <= '1' when (w12_x_l <= pix_x) and (pix_x <= w12_x_r) and (w12_y_b >= pix_y) and (pix_y >= w12_y_t) else '0';
	w12_rgb <= "10011111"; --green
	
	w13_on <= '1' when (w13_x_l <= pix_x) and (pix_x <= w13_x_r) and (w13_y_b >= pix_y) and (pix_y >= w13_y_t) else '0';
	w13_rgb <= "10011111"; --green
	
	w14_on <= '1' when (w14_x_l <= pix_x) and (pix_x <= w14_x_r) and (w14_y_b >= pix_y) and (pix_y >= w14_y_t) else '0';
	w14_rgb <= "10011111"; --green
	
	w15_on <= '1' when (w15_x_l <= pix_x) and (pix_x <= w15_x_r) and (w15_y_b >= pix_y) and (pix_y >= w15_y_t) else '0';
	w15_rgb <= "10011111"; --green
	
	w16_on <= '1' when (w16_x_l <= pix_x) and (pix_x <= w16_x_r) and (w16_y_b >= pix_y) and (pix_y >= w16_y_t) else '0';
	w16_rgb <= "10011111"; --green
	

	ball_x_l <= curr_ball_x;
	ball_x_r <= ball_x_l + BALL_SIZE -1;
	ball_y_t <= curr_ball_y;
	ball_y_b <= ball_y_t + BALL_SIZE -1;
	sq_ball_on <= '1' when (ball_x_l <= pix_x) and (pix_x <= ball_x_r) and (ball_y_t <= pix_y) and (pix_y <= ball_y_b) else '0';
	
	
	
	

	
	process(curr_ball_y, curr_ball_x, ball_y_t, ball_y_b, ball_x_l, ball_x_r, refresh60, btn)
	begin
		next_ball_y <= curr_ball_y;
		next_ball_x <= curr_ball_x;
		if refresh60 = '1' then --change is only at refresh rated times (60 Hz)
			if (win_x_l <= curr_ball_x ) and (curr_ball_x + 8 <= win_x_r) and (win_y_b >= curr_ball_y + 8) and (curr_ball_y >= win_y_t) then
				next_ball_x <= "0000101000";
				next_ball_y <= "0000101000";
			elsif btn(3) = '1' and ball_x_r < (MAX_X -1 - BALL_VEL) then --move right, if button and you don't hit the right of screen
				if (ball_x_r > (W1_X_L) and ball_y_t < (W1_Y_B) and ball_y_b > (W1_Y_T) and ball_x_l < (W1_X_R)) or
					(ball_x_r > (W2_X_L) and ball_y_t < (W2_Y_B) and ball_y_b > (W2_Y_T) and ball_x_l < (W2_X_R)) or
					(ball_x_r > (W3_X_L) and ball_y_t < (W3_Y_B) and ball_y_b > (W3_Y_T) and ball_x_l < (W3_X_R)) or
					(ball_x_r > (W4_X_L) and ball_y_t < (W4_Y_B) and ball_y_b > (W4_Y_T) and ball_x_l < (W4_X_R)) or
					(ball_x_r > (W5_X_L) and ball_y_t < (W5_Y_B) and ball_y_b > (W5_Y_T) and ball_x_l < (W5_X_R)) or
					(ball_x_r > (W6_X_L) and ball_y_t < (W6_Y_B) and ball_y_b > (W6_Y_T) and ball_x_l < (W6_X_R))  or
					(ball_x_r > (W7_X_L) and ball_y_t < (W7_Y_B) and ball_y_b > (W7_Y_T) and ball_x_l < (W7_X_R)) or
					(ball_x_r > (W8_X_L) and ball_y_t < (W8_Y_B) and ball_y_b > (W8_Y_T) and ball_x_l < (W8_X_R)) or
					(ball_x_r > (W9_X_L) and ball_y_t < (W9_Y_B) and ball_y_b > (W9_Y_T) and ball_x_l < (W9_X_R)) or
					(ball_x_r > (W10_X_L) and ball_y_t < (W10_Y_B) and ball_y_b > (W10_Y_T) and ball_x_l < (W10_X_R)) or
					(ball_x_r > (W11_X_L) and ball_y_t < (W11_Y_B) and ball_y_b > (W11_Y_T) and ball_x_l < (W11_X_R)) or
					(ball_x_r > (W12_X_L) and ball_y_t < (W12_Y_B) and ball_y_b > (W12_Y_T) and ball_x_l < (W12_X_R)) or
					(ball_x_r > (W13_X_L) and ball_y_t < (W13_Y_B) and ball_y_b > (W13_Y_T) and ball_x_l < (W13_X_R)) or
					(ball_x_r > (W14_X_L) and ball_y_t < (W14_Y_B) and ball_y_b > (W14_Y_T) and ball_x_l < (W14_X_R)) or
					(ball_x_r > (W15_X_L) and ball_y_t < (W15_Y_B) and ball_y_b > (W15_Y_T) and ball_x_l < (W15_X_R)) or
					(ball_x_r > (W16_X_L) and ball_y_t < (W16_Y_B) and ball_y_b > (W16_Y_T) and ball_x_l < (W16_X_R)) then
					next_ball_x <= "0000101000";
					next_ball_y <= "0000101000";
				else
					next_ball_x <= curr_ball_x + BALL_VEL;
				end if;
			elsif btn(2) = '1' and ball_x_l > BALL_VEL then --move left, if button and you don't hit the left of screen
				
				if (ball_x_r > (W1_X_L) and ball_y_t < (W1_Y_B) and ball_y_b > (W1_Y_T) and ball_x_l < (W1_X_R)) or
					(ball_x_r > (W2_X_L) and ball_y_t < (W2_Y_B) and ball_y_b > (W2_Y_T) and ball_x_l < (W2_X_R)) or
					(ball_x_r > (W3_X_L) and ball_y_t < (W3_Y_B) and ball_y_b > (W3_Y_T) and ball_x_l < (W3_X_R)) or
					(ball_x_r > (W4_X_L) and ball_y_t < (W4_Y_B) and ball_y_b > (W4_Y_T) and ball_x_l < (W4_X_R)) or
					(ball_x_r > (W5_X_L) and ball_y_t < (W5_Y_B) and ball_y_b > (W5_Y_T) and ball_x_l < (W5_X_R)) or
					(ball_x_r > (W6_X_L) and ball_y_t < (W6_Y_B) and ball_y_b > (W6_Y_T) and ball_x_l < (W6_X_R))  or
					(ball_x_r > (W7_X_L) and ball_y_t < (W7_Y_B) and ball_y_b > (W7_Y_T) and ball_x_l < (W7_X_R)) or
					(ball_x_r > (W8_X_L) and ball_y_t < (W8_Y_B) and ball_y_b > (W8_Y_T) and ball_x_l < (W8_X_R)) or
					(ball_x_r > (W9_X_L) and ball_y_t < (W9_Y_B) and ball_y_b > (W9_Y_T) and ball_x_l < (W9_X_R)) or
					(ball_x_r > (W10_X_L) and ball_y_t < (W10_Y_B) and ball_y_b > (W10_Y_T) and ball_x_l < (W10_X_R)) or
					(ball_x_r > (W11_X_L) and ball_y_t < (W11_Y_B) and ball_y_b > (W11_Y_T) and ball_x_l < (W11_X_R)) or
					(ball_x_r > (W12_X_L) and ball_y_t < (W12_Y_B) and ball_y_b > (W12_Y_T) and ball_x_l < (W12_X_R)) or
					(ball_x_r > (W13_X_L) and ball_y_t < (W13_Y_B) and ball_y_b > (W13_Y_T) and ball_x_l < (W13_X_R)) or
					(ball_x_r > (W14_X_L) and ball_y_t < (W14_Y_B) and ball_y_b > (W14_Y_T) and ball_x_l < (W14_X_R)) or
					(ball_x_r > (W15_X_L) and ball_y_t < (W15_Y_B) and ball_y_b > (W15_Y_T) and ball_x_l < (W15_X_R)) or
					(ball_x_r > (W16_X_L) and ball_y_t < (W16_Y_B) and ball_y_b > (W16_Y_T) and ball_x_l < (W16_X_R)) then

					next_ball_x <= "0000101000";
					next_ball_y <= "0000101000";
				else
					next_ball_x <= curr_ball_x - BALL_VEL;
				end if;
			elsif btn(1) = '1' and ball_y_b < (MAX_Y -1 - BALL_VEL) then --move down, if button and you don't hit the bottom of screen
				
				if (ball_x_r > (W1_X_L) and ball_y_t < (W1_Y_B) and ball_y_b > (W1_Y_T) and ball_x_l < (W1_X_R)) or
					(ball_x_r > (W2_X_L) and ball_y_t < (W2_Y_B) and ball_y_b > (W2_Y_T) and ball_x_l < (W2_X_R)) or
					(ball_x_r > (W3_X_L) and ball_y_t < (W3_Y_B) and ball_y_b > (W3_Y_T) and ball_x_l < (W3_X_R)) or
					(ball_x_r > (W4_X_L) and ball_y_t < (W4_Y_B) and ball_y_b > (W4_Y_T) and ball_x_l < (W4_X_R)) or
					(ball_x_r > (W5_X_L) and ball_y_t < (W5_Y_B) and ball_y_b > (W5_Y_T) and ball_x_l < (W5_X_R)) or
					(ball_x_r > (W6_X_L) and ball_y_t < (W6_Y_B) and ball_y_b > (W6_Y_T) and ball_x_l < (W6_X_R))  or
					(ball_x_r > (W7_X_L) and ball_y_t < (W7_Y_B) and ball_y_b > (W7_Y_T) and ball_x_l < (W7_X_R)) or
					(ball_x_r > (W8_X_L) and ball_y_t < (W8_Y_B) and ball_y_b > (W8_Y_T) and ball_x_l < (W8_X_R)) or
					(ball_x_r > (W9_X_L) and ball_y_t < (W9_Y_B) and ball_y_b > (W9_Y_T) and ball_x_l < (W9_X_R)) or
					(ball_x_r > (W10_X_L) and ball_y_t < (W10_Y_B) and ball_y_b > (W10_Y_T) and ball_x_l < (W10_X_R)) or
					(ball_x_r > (W11_X_L) and ball_y_t < (W11_Y_B) and ball_y_b > (W11_Y_T) and ball_x_l < (W11_X_R)) or
					(ball_x_r > (W12_X_L) and ball_y_t < (W12_Y_B) and ball_y_b > (W12_Y_T) and ball_x_l < (W12_X_R)) or
					(ball_x_r > (W13_X_L) and ball_y_t < (W13_Y_B) and ball_y_b > (W13_Y_T) and ball_x_l < (W13_X_R)) or
					(ball_x_r > (W14_X_L) and ball_y_t < (W14_Y_B) and ball_y_b > (W14_Y_T) and ball_x_l < (W14_X_R)) or
					(ball_x_r > (W15_X_L) and ball_y_t < (W15_Y_B) and ball_y_b > (W15_Y_T) and ball_x_l < (W15_X_R)) or
					(ball_x_r > (W16_X_L) and ball_y_t < (W16_Y_B) and ball_y_b > (W16_Y_T) and ball_x_l < (W16_X_R)) then

					next_ball_x <= "0000101000";
					next_ball_y <= "0000101000";
				else
					next_ball_y <= curr_ball_y + BALL_VEL;
				end if;
			elsif btn(0) = '1' and ball_y_t > BALL_VEL then --move up, if button and you don't hit the top of the screen
				
				if (ball_x_r > (W1_X_L) and ball_y_t < (W1_Y_B) and ball_y_b > (W1_Y_T) and ball_x_l < (W1_X_R)) or
					(ball_x_r > (W2_X_L) and ball_y_t < (W2_Y_B) and ball_y_b > (W2_Y_T) and ball_x_l < (W2_X_R)) or
					(ball_x_r > (W3_X_L) and ball_y_t < (W3_Y_B) and ball_y_b > (W3_Y_T) and ball_x_l < (W3_X_R)) or
					(ball_x_r > (W4_X_L) and ball_y_t < (W4_Y_B) and ball_y_b > (W4_Y_T) and ball_x_l < (W4_X_R)) or
					(ball_x_r > (W5_X_L) and ball_y_t < (W5_Y_B) and ball_y_b > (W5_Y_T) and ball_x_l < (W5_X_R)) or
					(ball_x_r > (W6_X_L) and ball_y_t < (W6_Y_B) and ball_y_b > (W6_Y_T) and ball_x_l < (W6_X_R))  or
					(ball_x_r > (W7_X_L) and ball_y_t < (W7_Y_B) and ball_y_b > (W7_Y_T) and ball_x_l < (W7_X_R)) or
					(ball_x_r > (W8_X_L) and ball_y_t < (W8_Y_B) and ball_y_b > (W8_Y_T) and ball_x_l < (W8_X_R)) or
					(ball_x_r > (W9_X_L) and ball_y_t < (W9_Y_B) and ball_y_b > (W9_Y_T) and ball_x_l < (W9_X_R)) or
					(ball_x_r > (W10_X_L) and ball_y_t < (W10_Y_B) and ball_y_b > (W10_Y_T) and ball_x_l < (W10_X_R)) or
					(ball_x_r > (W11_X_L) and ball_y_t < (W11_Y_B) and ball_y_b > (W11_Y_T) and ball_x_l < (W11_X_R)) or
					(ball_x_r > (W12_X_L) and ball_y_t < (W12_Y_B) and ball_y_b > (W12_Y_T) and ball_x_l < (W12_X_R)) or
					(ball_x_r > (W13_X_L) and ball_y_t < (W13_Y_B) and ball_y_b > (W13_Y_T) and ball_x_l < (W13_X_R)) or
					(ball_x_r > (W14_X_L) and ball_y_t < (W14_Y_B) and ball_y_b > (W14_Y_T) and ball_x_l < (W14_X_R)) or
					(ball_x_r > (W15_X_L) and ball_y_t < (W15_Y_B) and ball_y_b > (W15_Y_T) and ball_x_l < (W15_X_R)) or
					(ball_x_r > (W16_X_L) and ball_y_t < (W16_Y_B) and ball_y_b > (W16_Y_T) and ball_x_l < (W16_X_R)) then

						next_ball_x <= "0000101000";
						next_ball_y <= "0000101000";
					else
				next_ball_y <= curr_ball_y - BALL_VEL;
				end if;
			end if;
		end if;
	end process;

	rom_row	<= pix_y(2 downto 0) - ball_y_t(2 downto 0);
	rom_col <= pix_x(2 downto 0) - ball_x_l(2 downto 0);
	rom_data <= ball_rom(to_integer(rom_row));
	rom_bit <= rom_data(to_integer(rom_col));	

	round_ball_on <= '1' when (sq_ball_on = '1') and (rom_bit = '1') else '0';
	ball_rgb <= "11100000"; --red

	
	process(display, win_on, w1_on, w2_on, w3_on, w4_on, w5_on, w6_on, w7_on, w8_on, w9_on, w10_on, w11_on, w12_on, 
		w13_on, w14_on, w15_on, w16_on, round_ball_on, win_rgb, w1_rgb, w2_rgb, w3_rgb, w4_rgb, w5_rgb, w6_rgb, 
		w7_rgb, w8_rgb, w9_rgb, w10_rgb, w11_rgb, w12_rgb, w13_rgb, w14_rgb, w15_rgb, w16_rgb, ball_rgb)
	begin
		if display = '0' then
			graph_rgb <= "00000000"; --just black screen
		else
			if round_ball_on = '1' then
				graph_rgb <= ball_rgb;
			elsif w1_on = '1' then
				graph_rgb <= w1_rgb;
			elsif w2_on = '1' then
				graph_rgb <= w2_rgb;
			elsif w3_on = '1' then
				graph_rgb <= w3_rgb;
			elsif w4_on = '1' then
				graph_rgb <= w4_rgb;
			elsif w5_on = '1' then
				graph_rgb <= w5_rgb;
			elsif w6_on = '1' then
				graph_rgb <= w6_rgb;
			elsif w7_on = '1' then
				graph_rgb <= w7_rgb;
			elsif w8_on = '1' then
				graph_rgb <= w8_rgb;
			elsif w9_on = '1' then
				graph_rgb <= w9_rgb;
			elsif w10_on = '1' then
				graph_rgb <= w10_rgb;
			elsif w11_on = '1' then
				graph_rgb <= w11_rgb;
			elsif w12_on = '1' then
				graph_rgb <= w12_rgb;
			elsif w13_on = '1' then
				graph_rgb <= w13_rgb;
			elsif w14_on = '1' then
				graph_rgb <= w14_rgb;
			elsif w15_on = '1' then
				graph_rgb <= w15_rgb;
			elsif w16_on = '1' then
				graph_rgb <= w16_rgb;
			elsif win_on = '1' then 
				graph_rgb <= win_rgb;
			else
				graph_rgb <= "10001010"; --yellow background
			end if;
		end if;
			
	end process;

end arch1;