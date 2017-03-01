local colors = {}
colors[1] = 0xE91E63 -- pink
colors[2] = 0x9C27B0 -- purple
colors[3] = 0xFFC107 -- Amber
colors[4] = 0xCDDC39 -- Lime
colors[5] = 0x00BCD4 -- Cyan

colors[6] = 0xFF5722 -- deep orange
colors[7] = 0x009688 -- teal
--colors[8] = 0x2196F3 -- blue

local menuGoingDown = false
local themeColor = {1,1,1}
local oColor = {1,1,1,0.5}
local composer = require( "composer" )
local widget = require( "widget" )
local save = require( "Utility" )
local scene = composer.newScene()
local backgroundMusic = audio.loadStream( "music_menu.wav" )

local clickSound = audio.loadSound( "click4.wav" )
local backgroundMusicChannel
local maxLevel = 10
local upgrades = {}
local play, radius, pushback, damage, duration = 1, 2, 3, 4, 5
local upgrades = {}
upgrades.radius = 0
upgrades.pushback = 0
upgrades.damage = 0
upgrades.duration = 0

local sound, music, tutorial = 1, 2, 3
local settings = {}
settings[sound] = true
settings[music] = true
settings[tutorial] = true
local money = 100
local highScore = 0

local filePathUpgrades = system.pathForFile( "upgrades.json", system.DocumentsDirectory )
local filePathHighscore = system.pathForFile( "highscore.json", system.DocumentsDirectory )
local filePathSettings = system.pathForFile( "settings.json", system.DocumentsDirectory )
-- Buttons and circles:
local audioButton
local musicButton
local tutorialButton

local circleRadius
local radiusButton

local circlePushback
local pushbackButton

local circleDamage
local damageButton

local circleDuration
local durationButton

local moneyText

local highScoreText2

local sceneGroup
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
local function loadUpgrades()
    upgrades = save.load("upgrades")
    if upgrades == nil then
      upgrades = {}
      upgrades.radius = 0
      upgrades.pushback = 0
      upgrades.damage = 0
      upgrades.duration = 0
    end

end
local function saveUpgrades()
    save.save("upgrades", upgrades)
end
local function loadHighscore()
  highScore = save.load("highScore")
  if highScore == nil then
    highScore = 0
  end
end
local function saveHighscore()
    save.save("highScore", highScore)
end
local function loadMoney()
  money = save.load("money")
  if money == nil then
    money = 0
  end
end
local function saveMoney()
    save.save("money", money)
end
local function UpdateSettings()
  if settings == nil then
    return
  end
  if settings.sound == true then
    audio.setVolume( 0.75, { channel=1 } )
  else
    audio.setVolume( 0, { channel=1 } )
  end
  if settings.music == true then
    audio.setVolume( 0.75, { channel=2 } )
  else
    audio.setVolume( 0, { channel=2 } )
  end
  if settings.tutorial == true then
  else
  end
end
local function saveSettings()
  save.save("settings", settings)
end
local function loadSettings()
  settings = save.load("settings")
  if settings == nil then
    settings = {}
    settings.sound = true
    settings.music = true
    settings.tutorial = true
  end
end


local function calculatePrice(level)
  return math.pow(level, 2) * 5
end
local function fitImage( displayObject, fitWidth, fitHeight )
  if displayObject == nil then
    print("Fit image displayObject nil")
    return
  end
  local scaleFactor2 = fitWidth / displayObject.width
	local scaleFactor1 = fitHeight / displayObject.height


	displayObject:scale( scaleFactor1, scaleFactor2)
end

local function handleButtonEvent( event )
  print( event.x .. " " ..  event.y)
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
      print("ended lul")
      audio.play( clickSound )
      if id == play then
        composer.setVariable( "highScore", highScore )
        composer.setVariable( "upgrades", upgrades )
        composer.removeScene( "game" )
        composer.gotoScene( "game")

      elseif id == radius then
        radiusButton:setFillColor(unpack(radiusButton.defaultColor))
        radiusButton.label:setTextColor(1,1,1)
        local price = calculatePrice(  upgrades.radius + 1)

        if price <= money and upgrades.radius < maxLevel then

          money = money - price
          upgrades.radius = upgrades.radius + 1
          radiusButton.path.radius = radiusButton.defR + upgrades.radius * radiusButton.defR/ maxLevel
          display.remove( radiusButton.label )
          radiusButton.label = display.newText(sceneGroup,calculatePrice(   upgrades.radius + 1) .. "⋆" , radiusButton.x , radiusButton.y  , "titillium-bold.ttf", radiusButton.path.radius/1.5)
          saveUpgrades()
          saveMoney()
        end

      elseif id == pushback then
        pushbackButton:setFillColor(unpack(pushbackButton.defaultColor))
        pushbackButton.label:setTextColor(1,1,1)
        local price = calculatePrice(  upgrades.pushback + 1)
        if price <= money and upgrades.pushback < maxLevel then
          money = money - price
          upgrades.pushback = upgrades.pushback + 1
          pushbackButton.path.radius = pushbackButton.defR + upgrades.pushback * pushbackButton.defR/ maxLevel
          display.remove( pushbackButton.label )
          pushbackButton.label = display.newText(sceneGroup,calculatePrice(   upgrades.pushback + 1) .. "⋆" , pushbackButton.x , pushbackButton.y  , "titillium-bold.ttf", pushbackButton.path.radius/1.5)

          saveUpgrades()
          saveMoney()
        end

      elseif id == damage then
        damageButton:setFillColor(unpack(damageButton.defaultColor))
        damageButton.label:setTextColor(1,1,1)
        local price = calculatePrice(    upgrades.damage + 1)
        if price <= money and upgrades.damage < maxLevel then
          money = money - price
          upgrades.damage =   upgrades.damage + 1
          damageButton.path.radius = damageButton.defR + upgrades.damage * damageButton.defR/ maxLevel
          display.remove( damageButton.label )
          damageButton.label = display.newText(sceneGroup, calculatePrice(  upgrades.damage + 1) .. "⋆" , damageButton.x , damageButton.y  , "titillium-bold.ttf", damageButton.path.radius/1.5)

          saveUpgrades()
          saveMoney()

        end


      elseif id == duration then
        durationButton:setFillColor(unpack(durationButton.defaultColor))
        durationButton.label:setTextColor(1,1,1)
        local price = calculatePrice( upgrades.duration + 1)
        if price <= money and upgrades.duration < maxLevel then
          money = money - price
          upgrades.duration =   upgrades.duration + 1
          durationButton.path.radius = durationButton.defR + upgrades.duration * durationButton.defR/ maxLevel
          display.remove( durationButton.label )
          durationButton.label = display.newText(sceneGroup, calculatePrice(  upgrades.duration + 1) .. "⋆" , durationButton.x , durationButton.y  , "titillium-bold.ttf", durationButton.path.radius/1.5)

          saveUpgrades()
          saveMoney()
        end
      end
      moneyText.text = "" .. money
      moneyText.size = display.contentHeight / (string.len("" .. money) * 8)
    end
    return true
end
local function backgroundTouch( event )

    radiusButton:setFillColor(unpack(radiusButton.defaultColor))
    radiusButton.label:setTextColor(1,1,1)

    pushbackButton:setFillColor(unpack(pushbackButton.defaultColor))
    pushbackButton.label:setTextColor(1,1,1)

    damageButton:setFillColor(unpack(damageButton.defaultColor))
    damageButton.label:setTextColor(1,1,1)

    durationButton:setFillColor(unpack(durationButton.defaultColor))
    durationButton.label:setTextColor(1,1,1)

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
    sceneGroup:insert(newButton)
    local newImg = display.newImage( sceneGroup, img, x  , y )
    fitImage(newImg, 1.5* r  , 1.5* r  )
    return newButton
end

local function createStateButton(x, y,  r, id, img1, img2 )
    local newButton = {}
    newButton.state = settings[id]
    function OnClick(event)
      print("Cool Cool")
      if "ended" == event.phase then
        audio.stop( 2 )


        display.remove( newButton.image )
        if newButton.state == false then
          newButton.image = display.newImage( sceneGroup, img1, x  , y )
          newButton.state = true
        else
          newButton.image = display.newImage( sceneGroup, img2, x  , y )
          newButton.state = false
        end
        fitImage(newButton.image, 1.5* r  , 1.5* r  )
      end

    end

    newButton = widget.newButton(
    {
      x=x,
      y=y,
      fillColor = { default={unpack(themeColor)}, over={unpack(oColor)}},
      emboss = false,
      shape = "circle",
      radius=r,
      onEvent= OnClick,
      id = id
    })
    sceneGroup:insert(newButton)
    newButton.image = display.newImage( sceneGroup, img1, x  , y )
    fitImage(newButton.image, 1.5* r  , 1.5* r  )
    return newButton
end

local function createCircle(x, y, label,  r, id)
  local nCircle = display.newCircle( sceneGroup, x, y, r )
  nCircle.label = display.newText(label , nCircle.x , nCircle.y  , "titillium-bold.ttf", r/2)
  nCircle.label:setTextColor(1,1,1)

  nCircle:setFillColor(unpack(themeColor))
  nCircle.defaultColor = {unpack(themeColor)}
  nCircle.overColor  = oColor
  nCircle.id = id
  nCircle.defR = r
  nCircle:addEventListener( "touch", handleButtonEvent )
  return nCircle
end

local function createCircle2(x, y, image,  r, id)
  local nCircle = display.newCircle( sceneGroup, x, y, r )
  nCircle.image1 = display.newText(label , nCircle.x , nCircle.y  , "titillium-bold.ttf", r/1.5)

  nCircle:setFillColor(unpack(themeColor))
  nCircle.defaultColor = {unpack(themeColor)}
  nCircle.overColor  = {1,1,1}
  nCircle.id = id
  nCircle.defR = r
  nCircle:addEventListener( "touch", handleButtonEvent )
  return nCircle
end


function scene:create( event )

  loadUpgrades()
  loadHighscore()
  loadMoney()
  loadSettings()

  local pos = math.random(1, #colors)
  themeColor = {convertColor(colors[pos])}

  oColor = {}
  oColor[1] = themeColor[1]
  oColor[2] = themeColor[2]
  oColor[3] = themeColor[3]
  oColor[4] = 0.8

  audio.setVolume( 0.5 )
	sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen
	-- Load the background
	local background = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight )
  background:setFillColor(convertColor(0x2A2F36))
  background:addEventListener( "touch", backgroundTouch )
  --local background2 = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth/16, display.contentHeight )
  --background2:setFillColor(convertColor(0xE0FFB3))

  local playButton= createButton(display.contentCenterX, display.contentCenterY, display.contentHeight/ 4, play, "arrow.png" ) --"playbutton/b" .. pos .. ".png", "playbutton/b" .. pos .. "t.png")
  local playButtonRadius = display.contentHeight/4


  local bigR = 1.8 * display.contentWidth / 4


  local circlesY = (display.contentHeight/2 -  playButtonRadius)/12
  local cRadius = 1/2 * playButtonRadius

  --Star:
  --local moneyImage2 = display.newImage( sceneGroup, "particleWhite_4.png", display.contentCenterX  , display.contentCenterY + playButtonRadius + circlesY + 2 * circlesRadius *0.75 )
  --fitImage(moneyImage2, 3 * circlesRadius, 3 * circlesRadius )
  local moneyImage2 = display.newImage( sceneGroup, "p" .. pos ..".png", display.contentCenterX  , 0.11* display.contentHeight )
  fitImage(moneyImage2, 0.20 * display.contentHeight  , 0.20 * display.contentHeight  )
  moneyText = display.newText( sceneGroup, "" .. money,moneyImage2.x ,moneyImage2.y  , "titillium-bold.ttf", display.contentHeight / (string.len("" .. money) * 8 )  )
  moneyText:setTextColor(1,1,1)


  circleDamage = display.newCircle(sceneGroup, display.contentWidth / 8, playButton.y - playButton.height/2  , cRadius )
  circleDamage.y = playButton.y - playButton.height/2 + circleDamage.height /2
  circleDamage:setFillColor(convertColor(0x2A2F36))
  circleDamage.strokeWidth = display.contentWidth/128
  circleDamage:setStrokeColor(unpack(themeColor))
  damageButton= createCircle(circleDamage.x, circleDamage.y, (calculatePrice(  upgrades.damage + 1) .. "⋆"), ( 0.5 +  0.5 * upgrades.damage/maxLevel )* cRadius, damage)
  sceneGroup:insert(damageButton)
  sceneGroup:insert(damageButton.label)

  local textDamage = display.newText(sceneGroup, "DAMAGE", circleDamage.x, playButton.y - playButton.height/2, "titillium-bold.ttf", 2 * cRadius/5 )
  textDamage.y = circleDamage.y + textDamage.height/2 + circleDamage.height/2--- textDamage.height/2
  textDamage:setTextColor(1,1,1)

  local textRadius = display.newText(sceneGroup, "RADIUS", display.contentWidth / 8,  display.contentHeight , "titillium-bold.ttf", 2 * cRadius/5 )
  textRadius.y = display.contentHeight - textRadius.height/2 - display.contentHeight / 32
  textRadius:setTextColor(1,1,1)

  circleRadius = display.newCircle(sceneGroup, textRadius.x, textRadius.y, cRadius )
  circleRadius.y = textRadius.y - textRadius.height/2 - circleRadius.height/2 - display.contentWidth/256
  circleRadius:setFillColor(convertColor(0x2A2F36))
  circleRadius.strokeWidth = display.contentWidth/128
  circleRadius:setStrokeColor(unpack(themeColor))
  radiusButton= createCircle(circleRadius.x, circleRadius.y, (calculatePrice(  upgrades.radius + 1) .. "⋆"), ( 0.5 + 0.5 *  upgrades.radius/maxLevel )* cRadius, radius)
  sceneGroup:insert(radiusButton)
  sceneGroup:insert(radiusButton.label)


  circleDuration = display.newCircle(sceneGroup, 7 * display.contentWidth /8, circleDamage.y, cRadius )
  circleDuration:setFillColor(convertColor(0x2A2F36))
  circleDuration.strokeWidth = display.contentWidth/128
  circleDuration:setStrokeColor(unpack(themeColor))
  durationButton= createCircle(circleDuration.x, circleDuration.y, (calculatePrice(  upgrades.duration + 1) .. "⋆"), ( 0.5 + 0.5 *  upgrades.duration/maxLevel )* cRadius, duration)
  sceneGroup:insert(durationButton)
  sceneGroup:insert(durationButton.label)
  local textDuration = display.newText(sceneGroup, "DURATION", circleDuration.x, textDamage.y  , "titillium-bold.ttf", 2 * cRadius/5 )
  textDuration:setTextColor(1,1,1)

  local textPushback = display.newText(sceneGroup, "PUSH BACK", 7 * display.contentWidth /8, textRadius.y , "titillium-bold.ttf", 2 * cRadius/5 )
  textPushback:setTextColor(1,1,1)

  circlePushback = display.newCircle(sceneGroup, 7 * display.contentWidth /8, circleRadius.y , cRadius )
  circlePushback:setFillColor(convertColor(0x2A2F36))
  circlePushback.strokeWidth = display.contentWidth/128
  circlePushback:setStrokeColor(unpack(themeColor))
  pushbackButton= createCircle(circlePushback.x, circlePushback.y, (calculatePrice(  upgrades.pushback + 1) .. "⋆"), ( 0.5 + 0.5 *  upgrades.pushback/maxLevel )* cRadius, pushback)
  sceneGroup:insert(pushbackButton)
  sceneGroup:insert(pushbackButton.label)


  -- Highscore display
  -- display.newRoundedRect( [parent,] x, y, width, height, cornerRadius )

  local highScoreText1 = display.newText(sceneGroup, "HIGHSCORE", 0,(display.contentHeight / 32), "titillium-bold.ttf",  display.contentHeight / 24  )
  highScoreText1.anchorY = 0
  highScoreText1.x = (display.contentHeight / 32) + highScoreText1.width/2
  highScoreText2 = display.newText(sceneGroup, "000000" , 0, highScoreText1.y, "titillium-bold.ttf",  display.contentHeight / 24  )
  highScoreText2.anchorY = 0
  highScoreText2.x = highScoreText1.x + highScoreText1.width/2 + (display.contentWidth / 32) + highScoreText2.width/2
  --highScoreText2.circlesY = (display.contentHeight / 8) *   0.7/2
  local highScoreRect = display.newRect(sceneGroup, display.contentCenterX, highScoreText1.y + highScoreText1.height / 2 , display.contentWidth/ 256, 2 *  highScoreText1.height / 3)
  highScoreRect.x = highScoreText1.x + highScoreText1.width/2 + (display.contentWidth / 64) + highScoreRect.width/2
  highScoreRect:setFillColor(1,1,1)


  audioButton = createStateButton(display.contentCenterX,  display.contentHeight - display.contentHeight/ 8, display.contentHeight/ 16, sound, "audioOn.png",  "audioOff.png" )
  audioButton.state = true
 end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
    --loadUpgrades()
    loadUpgrades()

    local score  = composer.getVariable( "score" )
    local income=  composer.getVariable( "income" )

    if income ~= nil and income ~= 0   then
      money = money + income
      moneyText.text = "" .. money
      moneyText.size = display.contentHeight / (string.len("" .. money) * 8)

      local moneyBonusText = display.newText(sceneGroup, "+".. income .. "⋆" , display.contentCenterX, moneyText.y + 2 * moneyText.height/3,   "titillium-bold.ttf", display.contentWidth / (16)  )
      moneyBonusText:setTextColor(1,1,1)
      transition.to(moneyBonusText, {delay = 500, time = 1000, alpha = 0, onComplete=
        function()
        if moneyBonusText ~= nil then
          display.remove(moneyBonusText)
        end
        -- if moneyText ~= nil then
        --   moneyText.text = "" .. money
        -- end
      end})
      saveMoney()
    end

    loadHighscore()
    local highScoreString = "" .. highScore
    while string.len(highScoreString) < 6 do
      highScoreString = "0" .. highScoreString
    end
    highScoreText2.text = highScoreString


	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
    menuGoingDown = false
    function playMusic(event)
      print("BITCH")
      if menuGoingDown == false then
        local options =
        {
          channel = 2,
          loops = 5,
          onComplete = playMusic
        }
        backgroundMusicChannel = audio.play( backgroundMusic, options )
      end
    end
    playMusic(event)

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
    menuGoingDown = true
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
