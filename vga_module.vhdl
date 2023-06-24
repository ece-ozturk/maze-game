library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_module is
	PORT( board_clock, reset: IN STD_LOGIC;
			hsync, vsync: OUT STD_LOGIC;
			display, p_tick: OUT STD_LOGIC;
			pixel_x, pixel_y: OUT STD_LOGIC_VECTOR(9 downto 0));
end vga_module;

architecture arch1 of vga_module is

	--parameter declaration for vga-640*480
	constant HD: integer:= 640; 	--horizontal display
	constant HF: integer:= 16; 	--horizontal front porch
	constant HB: integer:= 48; 	--horizontal back porch
	constant HR: integer:= 96; 	--horizontal retrace
	constant VD: integer:= 480; 	--vertical display
	constant VF: integer:= 10; 	--vertical front porch
	constant VB: integer:= 29; 	--vertical back porch
	constant VR: integer:= 2; 		--vertical retrace
	
	--other mid-signal declarations
	signal slow_clock: STD_LOGIC;
	signal curr_h_count, curr_v_count, next_h_count, next_v_count: UNSIGNED(9 downto 0); 
	signal curr_hsync, curr_vsync, next_hsync, next_vsync: STD_LOGIC;
	signal end_of_h, end_of_v: STD_LOGIC;
	signal pixel_tick: STD_LOGIC;

begin

process(board_clock, reset)
begin
	if (reset = '1') then
		curr_v_count <= (others=>'0');
		curr_h_count <= (others=>'0');
		curr_vsync <= '0';
		curr_hsync <= '0';
	elsif (rising_edge(board_clock)) then
		curr_v_count <= next_v_count;
		curr_h_count <= next_h_count;
		curr_vsync <= next_vsync ;
		curr_hsync <= next_hsync;
	end if;
end process;

--frequency divider: 100Hz to 25Hz
process (board_clock) is
		variable count: natural;
	begin
		if rising_edge(board_clock) then
			slow_clock <= '0';
			count := count +1;
			if count = 4 then 
				slow_clock <= '1';
				count := 0;
			end if;
		end if;
	end process;

pixel_tick <= '1' when slow_clock = '1' else '0';


--"end of screen" checks
end_of_h <= '1' when curr_h_count=(HD+HF+HB+HR-1) else '0';
end_of_v <= '1' when curr_v_count=(VD+VF+VB+VR-1) else '0';


process(curr_h_count, end_of_h, pixel_tick)
begin
	if (pixel_tick = '1') then
		if (end_of_h = '1') then --you are at end of the row
			next_h_count <= (others=>'0');
		else
			next_h_count <= curr_h_count + 1;
		end if;
	else --pixel_tick is NOT 1
		next_h_count <= curr_h_count;
	end if;
end process;


process(curr_v_count, end_of_h, end_of_v, pixel_tick) 
begin
	if (pixel_tick = '1') and (end_of_h = '1') then
		if (end_of_v = '1') then --you are at end of the row, end of the column: end of the screen
			next_v_count <= (others=>'0');
		else
			next_v_count <= curr_v_count + 1;
		end if;
	else --pixel_tick is NOT 1
		next_v_count <= curr_v_count;
	end if;
end process;


next_hsync <= '1' when (curr_h_count>=(HD+HF)) and (curr_h_count<=(HD+HF+HR-1)) else '0'; --656 <= curr_h_count <= 751
next_vsync <= '1' when (curr_v_count>=(VD+VF)) and (curr_v_count<=(VD+VF+VR-1)) else '0'; --490 <= curr_v_count <= 491

display <= '1' when (curr_h_count < HD) and (curr_v_count < VD) else '0'; --display is ON in the displayable region

hsync <= curr_hsync;
vsync <= curr_vsync;
pixel_x <= STD_LOGIC_VECTOR(curr_h_count);
pixel_y <= STD_LOGIC_VECTOR(curr_v_count);
p_tick <= pixel_tick;

end arch1;