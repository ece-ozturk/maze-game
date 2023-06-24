## Maze Game in VHDL

This is a maze game project written in VHDL, for Bogazici University EE244 Digital Systems Design class, colloborated with 
my colleague Beril Umar.

This project is implemented on Xilinx Nexys3 and visualized on a CRT monitor, using VGA.

Aim of the game is simple: Users are expected to control the ball towards the target area using the board's four push buttons (which controls up, down, right and left) without touching the walls.

**The project consists of**
- *a VGA synchronization module* (uses board clock -with approapriate frequency divider- and returns synchronization signals and pixel counters)
- *a graph module* (draws and updates all the graphical interface, including walls, the target and the round ball)
- *a controller top module* (connects the other modules and performs the game control)

https://github.com/ece-ozturk/maze-game/assets/127878597/4c0891f3-d713-439d-9488-28943b31eaac
