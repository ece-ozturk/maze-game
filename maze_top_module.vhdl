library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity maze_top_module is
	port( board_clock, reset: IN STD_LOGIC;
			btn: IN STD_LOGIC_VECTOR(3 downto 0);
			hsync, vsync: OUT STD_LOGIC;
			rgb: OUT STD_LOGIC_VECTOR(7 downto 0));
end maze_top_module;

architecture arch1 of maze_top_module is

component vga_module is
	PORT( board_clock, reset: IN STD_LOGIC;
			hsync, vsync: OUT STD_LOGIC;
			display, p_tick: OUT STD_LOGIC;
			pixel_x, pixel_y: OUT STD_LOGIC_VECTOR(9 downto 0));
end component;

component maze_graph_module is
	PORT( board_clock, reset: IN STD_LOGIC;
			btn: IN STD_LOGIC_VECTOR(3 downto 0);
			display: IN STD_LOGIC;
			pixel_x, pixel_y: IN STD_LOGIC_VECTOR(9 downto 0);
			graph_rgb: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
end component;

signal pixel_x, pixel_y: STD_LOGIC_VECTOR(9 downto 0);
signal display, pixel_tick: STD_LOGIC;
signal rgb_reg, rgb_next: STD_LOGIC_VECTOR(7 downto 0);

begin

vga_module1: vga_module PORT MAP(board_clock => board_clock, reset => reset, hsync=>hsync, vsync=> vsync, display=> display, p_tick=> pixel_tick, pixel_x=> pixel_x, pixel_y=> pixel_y);
maze_graph_module1: maze_graph_module PORT MAP(board_clock => board_clock, reset => reset, btn=> btn, display => display, pixel_x => pixel_x, pixel_y=> pixel_y, graph_rgb=> rgb_next);

process(board_clock)
begin
	if (rising_edge(board_clock)) then
		if (pixel_tick = '1') then
			rgb_reg <= rgb_next;
		end if;
	end if;
end process;

rgb <= rgb_reg;

end arch1;

