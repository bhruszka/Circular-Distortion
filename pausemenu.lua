
local composer = require( "composer" )

local scene = composer.newScene()
local widget = require( "widget" )

local resume, home, restart = 0, 1, 2
local themeColor = {1,1,1,1}
local oColor = {1,1,1,1}

local backGroup
local underGroup
local underGroup2
local mainGroup
local uiGroup

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function handleButtonEvent( event )

    local id = tonumber(event.target.id)

    if event.phase == "began" then
      if id == radius then
        radiusButton:setFillColor(unpack(radiusButton.overColor))
        --radiusButton.label:setTextColor(unpack(themeColor))
      elseif id == pushback then
        pushbackButton:setFillColor(unpack(pushbackButton.overColor))
        --pushbackButton.label:setTextColor(unpack(themeColor))
      elseif id == damage then
        damageButton:setFillColor(unpack(damageButton.overColor))
        --damageButton.label:setTextColor(unpack(themeColor))
      elseif id == duration then
        durationButton:setFillColor(unpack(durationButton.overColor))
        --durationButton.label:setTextColor(unpack(themeColor))
      end

    elseif ( "ended" == event.phase ) then
      audio.play( clickSound )
      if id == resume then
        composer.gotoScene( "game")

      elseif id == restart then
				composer.setVariable( "highScore", highScore )
				composer.setVariable( "upgrades", upgrades )
				composer.removeScene( "game" )
				composer.gotoScene( "game")

      elseif id == home then
        pushbackButton:setFillColor(unpack(pushbackButton.defaultColor))
        pushbackButton.label:setTextColor(1,1,1)

        end

      end


    return true
end
local function fitImage( displayObject, fitWidth, fitHeight )
	if displayObject == nil then
		return nil
	end
  local scaleFactor2 = fitWidth / displayObject.width
	local scaleFactor1 = fitHeight / displayObject.height
	displayObject:scale( scaleFactor1, scaleFactor2)

end
local function createButton(x, y,  r, id, img )
    local newButton = widget.newButton(
    {
      x=x,
      y=y,
      fillColor = { default={unpack(themeColor)}, over={unpack(oColor)}},
      emboss = false,
      shape = "circle",
      radius=r,
      onEvent= handleButtonEvent,
      id = id
    })
    uiGroup:insert(newButton)
    local newImg = display.newImage( sceneGroup, img, x  , y )
    fitImage(newImg, 1.5* r  , 1.5* r  )
    return newButton

end

local function convertColor( hex )
  local color = {0 , 0, 0}

  color[1] = math.floor( hex / ( 16 * 16 * 16 * 16)) / 255
  color[2] = ( math.floor( (hex - (color[1] * 16 * 16 * 16 * 16 * 255)) / ( 16 * 16 ) ) ) / 255
  color[3] = ( hex - (color[1] * 16 * 16 * 16 * 16 * 255) - (color[2] * 16 * 16 * 255 ) ) / 255


  return color[1], color[2], color[3]
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	highScoreString = composer.getVariable( "highScoreString" )
	if highScoreString == nil then
		highScoreString = "000000"
	end


	themeColor = composer.getVariable( "themeColor" )
	if themeColor == nil then
		themeColor = {1,1,1,1}
	end
	if oColor == nil then
		oColor = {1,1,1,1}
	end
	oColor = {}
	oColor[1] = themeColor[1]
	oColor[2] = themeColor[2]
	oColor[3] = themeColor[3]
	oColor[4] = 0.8

	local sceneGroup = self.view

	-- Set up display groups
	backGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert( backGroup )  -- Insert into the scene's view group

  underGroup = display.newGroup()
  sceneGroup:insert( underGroup )

  underGroup2 = display.newGroup()
  sceneGroup:insert( underGroup2 )

	mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
	sceneGroup:insert( mainGroup )  -- Insert into the scene's view group

	uiGroup = display.newGroup()    -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

	local background = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
	background:setFillColor(convertColor(0x2A2F36))

	-- Code here runs when the scene is first created but has not yet appeared on screen
	local resumeButton = createButton(display.contentCenterX, display.contentCenterY, display.contentHeight/ 4, resume, "arrow.png" )
	sceneGroup:insert( resumeButton )
	local highScoreText1 = display.newText(sceneGroup, "HIGHSCORE", 0,(display.contentHeight / 32), "titillium-bold.ttf",  display.contentHeight / 24  )
  highScoreText1.anchorY = 0
  highScoreText1.x = (display.contentHeight / 32) + highScoreText1.width/2
  highScoreText2 = display.newText(sceneGroup, highScoreString, 0, highScoreText1.y, "titillium-bold.ttf",  display.contentHeight / 24  )
  highScoreText2.anchorY = 0
  highScoreText2.x = highScoreText1.x + highScoreText1.width/2 + (display.contentWidth / 32) + highScoreText2.width/2
  --highScoreText2.circlesY = (display.contentHeight / 8) *   0.7/2
  local highScoreRect = display.newRect(sceneGroup, display.contentCenterX, highScoreText1.y + highScoreText1.height / 2 , display.contentWidth/ 256, 2 *  highScoreText1.height / 3)
  highScoreRect.x = highScoreText1.x + highScoreText1.width/2 + (display.contentWidth / 64) + highScoreRect.width/2
  highScoreRect:setFillColor(1,1,1)

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
