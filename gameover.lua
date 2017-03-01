
local composer = require( "composer" )
local widget = require( "widget" )
local scene = composer.newScene()

-- Converting hex color to the corona color:
local function convertColor( hex )
  local color = {0 , 0, 0}

  color[1] = math.floor( hex / ( 16 * 16 * 16 * 16)) / 255
  color[2] = ( math.floor( (hex - (color[1] * 16 * 16 * 16 * 16 * 255)) / ( 16 * 16 ) ) ) / 255
  color[3] = ( hex - (color[1] * 16 * 16 * 16 * 16 * 255) - (color[2] * 16 * 16 * 255 ) ) / 255


  return color[1], color[2], color[3]
end
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------




-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
local function gotoGame( event )
	--if  ( "ended" == event.phase ) then
		--composer.removeScene( "game" )
		--composer.gotoScene( "game", { time=800, effect="crossFade" } )
	--end

end


local function handleButtonEvent( event )

    if ( "ended" == event.phase ) then
				composer.removeScene( "game" )
        print( "Button was pressed and released" )
				composer.gotoScene( "game")
    end
end

function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	-- Load the background
	local background = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
  background:setFillColor(convertColor(0xFFE082))

  local gameOverText = display.newText( sceneGroup, "GAME OVER", 	display.contentCenterX, display.contentCenterY - 2 * display.contentWidth / 4, "titillium-bold.ttf" , display.contentWidth / 6 )

	 local playButton = widget.newButton(
    {
				x=display.contentCenterX,
				y=display.contentCenterY,
        label = "RESTART",
        labelColor = { default={ 1, 1, 1 }, over={ 1, 1, 1} },
        fillColor = { default={convertColor(0x304FFE)}, over={convertColor(0x8C9EFF)} },
				font="titillium-bold.ttf",

				fontSize=display.contentWidth / 12,
        onEvent = handleButtonEvent,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "circle",
				radius=display.contentWidth / 4,

    }
	)
	sceneGroup:insert(playButton)






 end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end




-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------


return scene
