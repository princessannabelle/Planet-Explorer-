-- Simple planet auto generator written in Love2D.
-- Coded in Lua by Annabelle Lee.
-- Configuration file for the game.

-- Very first function loaded in the program. 
-- Sets all needed settings.
function love.conf(t)
	-- Title of game.
	t.title = "Planet Explorer!"
	-- Love version.
	t.version = "0.10.2"
	-- Window height and width.
	t.window.height = 600
	t.window.width 	= 896

	-- Debugging on windows.
	t.console = false
end