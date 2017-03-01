
local composer = require "composer"

-- Hide status bar
--display.setStatusBar( display.HiddenStatusBar )
-- Sets system UI visibility (Android KitKat or above)
native.setProperty( "androidSystemUiVisibility", "lowProfile" )

-- Seed the random number generator
math.randomseed( os.time() )

-- Go to the menu screen
composer.gotoScene( "menu" )
