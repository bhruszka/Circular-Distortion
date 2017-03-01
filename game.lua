
local composer = require( "composer" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local tutorialText = "Tap the screen to create distortions that damage incoming circles. Don’t let them reach your base. Tap as fast as you can with as many fingers as you want."
local pause = 0
local bShowTutotorial = false
-- Initialise physics:
local physics = require( "physics" )
local widget = require( "widget" )
local save = require( "Utility" )
physics.start()
physics.setGravity( 0, 0 )

local Acceleration = (display.contentWidth / 64) / 60
local collisionsTable = {}
local timerTable = {}
-- Initialize variables
local lives = 3
local score = 0
local scoreDisp = 0
local waveNumber = 0
local goingDown = false
local leftWall
local rightWall
-- upgrades:
local maxLevel = 10

local upgrades = {}
upgrades.radius = 0
upgrades.pushback = 0
upgrades.damage = 0
upgrades.duration = 0

local upgradesMax = {}
upgradesMax.radius = 2
upgradesMax.pushback = 2
upgradesMax.damage = 2
upgradesMax.duration = 2

local function newWaveInfo(b, m, s)
  local info = {}
  info.s = s
  info.m = m
  info.b = b
  return info
end


local waveTable = {}
waveTable[1] = newWaveInfo(0, 1, 4) -- 5
waveTable[2] = newWaveInfo(0, 2, 4) -- 8
waveTable[3] = newWaveInfo(0, 3, 6) -- 12
waveTable[4] = newWaveInfo(0, 4, 8) -- 16
waveTable[5] = newWaveInfo(1, 4, 8) -- 20
-- Expert Waves:
waveTable[6] = newWaveInfo(2, 4, 8) -- 24
waveTable[7] = newWaveInfo(3, 6, 12) -- 36
waveTable[8] = newWaveInfo(4, 4, 8) -- 48
waveTable[9] = newWaveInfo(5, 4, 8) -- 60
waveTable[10] = newWaveInfo(6, 4, 8) -- 72

local soundTable = {}
soundTable[1] = audio.loadSound( "phaserUp1.mp3" )
soundTable[2] = audio.loadSound( "phaserUp2.mp3" )
soundTable[4] = audio.loadSound( "phaserUp3.mp3" )

local colors = {}
colors[1] = 0xE91E63 -- pink
colors[2] = 0x9C27B0 -- purple
colors[3] = 0xFFC107 -- Amber
colors[4] = 0xCDDC39 -- Lime
colors[5] = 0x00BCD4 -- Cyan

colors[6] = 0xFF5722 -- deep orange
colors[7] = 0x009688 -- teal
colors[8] = 0x2196F3 -- blue

local themeColor = {1,1,1}

local upperWall
local lowerWall
local baseCircle
local touchRect

local myTimer = nil
local allowNext = true

local gameLoopTimer
local updateTextTimer
local livesText
local scoreText
local ballsTable = {}


local ballSize = display.contentHeight / 4
local border = ballSize / 2


-- Groups:
local backGroup
local underGroup
local underGroup2
local mainGroup
local uiGroup

local baseSize = 25
local ringTable = {}

local highScore = 0
local income = 0

local isPaused = false

local ringMaxRadius = ballSize

function math.sign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end

local function updateText()
  local t = score - scoreDisp
  if t > 4800 then
    scoreDisp = scoreDisp + 200
  elseif t > 2400 then
    scoreDisp = scoreDisp + 100
  elseif t > 1200  then
    scoreDisp = scoreDisp + 50
  elseif t > 600 then
    scoreDisp = scoreDisp + 20
  elseif t > 0 then
    scoreDisp = scoreDisp + 10
  end
  local stringDisp = ""
  for i=1,5 do
    if scoreDisp < math.pow(10, i) then
      stringDisp = stringDisp .. 0

    end
  end
  stringDisp = stringDisp .. scoreDisp

  scoreText.text = stringDisp
  if( score > highScore ) then
    highScoreText2.text = scoreDisp
    save.save("highScore", score)
  end
  if( scoreDisp > highScore ) then
    highScoreText2.text = stringDisp

  end
end

local function showTutorial()
  local background = display.newRect( uiGroup, display.contentCenterX, display.contentCenterY, display.contentHeight, display.contentWidth)
  background:setFillColor(0,0,0,0.5)

  local options = {
     text = tutorialText,
     x = display.contentCenterX,
     y = border + ( display.contentWidth/2 - display.contentHeight / 4 - border)/2,
     font = "titillium-bold.ttf",
     width = display.contentHeight - border,
     height = 2 * border,
     fontSize = display.contentHeight / 20,
     align = "center"
  }

  local text = display.newText(options )
  --display.remove( background )
  --display.remove( text )
end
local function pauseResumeGame()
  if isPaused == true then
    physics.start()
    isPaused = false
  else
    physics.pause()
    isPaused = true
  end

end


-- Converting hex color to the corona color:
local function convertColor( hex )
  local color = {0 , 0, 0}
  color[1] = math.floor( hex / ( 16 * 16 * 16 * 16)) / 255
  color[2] = ( math.floor( (hex - (color[1] * 16 * 16 * 16 * 16 * 255)) / ( 16 * 16 ) ) ) / 255
  color[3] = ( hex - (color[1] * 16 * 16 * 16 * 16 * 255) - (color[2] * 16 * 16 * 255 ) ) / 255


  return color[1], color[2], color[3]
end
local function fitImage( displayObject, fitWidth, fitHeight )

  local scaleFactor2 = fitWidth / displayObject.width
	local scaleFactor1 = fitHeight / displayObject.height

	displayObject:scale( scaleFactor1, scaleFactor2)
end


local function createBall( info )

  if info == nil then

    return nil
  end
  if info.r == nil or info.x == nil or info.y == nil  or info.thisSize == nil then
    return nil
  end

  local r = info.r
  local s = 0 -- 1/20 * r
  local x = info.x
  local y = info.y


  local newBall = display.newCircle( mainGroup, x, y, r - s/2)
  newBall:setFillColor(convertColor( info.color ))
  newBall.strokeWidth = s
  newBall.baseColor = {convertColor( info.color )}
  newBall.deathColor = {convertColor( 0x2A2F36 )} -- todo: set to background color
  newBall.currentColor = {convertColor( info.color )}

  -- newBall:addEventListener( "touch",  function() return true end)
  -- for i=1,3 do
  --     newBall.myColor[i] = ballColor[i]
  -- end
  -- ballColor[4] = 0.5
  -- newBall:setStrokeColor(1,1,1) -- unpack( ballColor ))

  physics.addBody( newBall, "dynamic", { radius = r, bounce = 0.2 } )
  newBall.myName = "ball"
  newBall.mySize = info.thisSize
  newBall.s = info.s
  local velocity = {}
  velocity.x = math.random( -display.contentHeight / 20 , display.contentHeight / 20)
  if newBall.y <= display.contentCenterY  then
    velocity.y = display.contentWidth/20
  else
    velocity.y = -display.contentWidth/20
  end

  newBall:setLinearVelocity( velocity.x, velocity.y )
  table.insert( ballsTable, newBall )

  newBall:addEventListener( "touch",  function() return true end)
  function newBall.onDestroy ()
    audio.play( soundTable[newBall.s] )
    local newInfo = {}
    newInfo.x = newBall.x
    newInfo.y = newBall.y
    newInfo.color = info.color
    if newBall.s == 1 then
      newInfo.s = 2
    elseif newBall.s == 2 then
      newInfo.s = 4
    else
      return
    end

    newInfo.thisSize = 1
    if s == 1 then
      newInfo.thisSize = 16
    elseif s == 2 then
        newInfo.thisSize = 4
    end

    newInfo.r = ballSize / ( 2 * newInfo.s )
    for i=1,4 do
      createBall(newInfo)
    end
  end

  return newBall

end

-- Spawn a ball:
local function makeBalls( info )
  if info == nil or info.b == nil or info.m == nil or info.s == nil then

    return
  end
  local n = {info.b, info.m, info.s}
  for i=1,#n do
    local p = i
    local s = i
    if i == 3 then
      s = 4
    end


    local thisSize = ballSize / s

    for i=1,n[i] do
      local whereX = math.random(1, 2)
      local whereY = math.random(ballSize, display.contentHeight - ballSize )
      if whereX == 1 then
        whereX = -ballSize + math.random(-1, 1)
      else
        whereX = display.contentWidth+ 1 * ballSize + math.random(-1, 1)
      end
      local thisInfo = {}
      thisInfo.x = whereX
      thisInfo.y = whereY
      --for i=1, math.pow(4, p-1)  do
      thisInfo.color = colors[math.random(1, #colors)]
      thisInfo.r = thisSize / 2
      thisInfo.s = s
      thisInfo.thisSize = 1
      if s == 1 then
        thisInfo.thisSize = 16
      elseif s == 2 then
          thisInfo.thisSize = 4
      end
      createBall( thisInfo )

    end
  end
end



local function fireCircle2(x, y )

    local myRing = {}


    local ringColor = 0x61C791
    --local tempTable = convertColor(ringColor)
    myRing = display.newCircle(underGroup, x , y , 0)
    myRing:setFillColor(0,0,0,0) --This will set the fill color to transparent
    myRing.strokeWidth = display.contentHeight * 0.1 / 4--This is the width of the outline of the circle
    myRing.sW = myRing.strokeWidth
    myRing.startingStrokeWidth = myRing.strokeWidth
    myRing:setStrokeColor(unpack(themeColor))  --This is the color of the outline
    myRing.myAlpha = 1
    table.insert( collisionsTable, myRing )

    local delta = 1000 / 30
    local span = 1000.0 --* (1 + upgradesMax.duration * upgrades.duration / maxLevel )
    local thisTimer
    local strokeChange = myRing.startingStrokeWidth* delta/span

    local function ringLoop( )
      if myRing == nil or goingDown == true then
        return
      end

      myRing.path.radius = myRing.path.radius + ringMaxRadius  * delta / span
      myRing.sW = myRing.sW - strokeChange
      myRing.strokeWidth =   myRing.sW

      if myRing == nil or myRing.strokeWidth < strokeChange then
        for i=1,#collisionsTable do
          if collisionsTable[i] == myRing then
            table.remove( collisionsTable, i )
          end
        end
        display.remove( myRing)

        for i=1,#timerTable do
          if timerTable[i] == thisTimer then
            table.remove( timerTable, i )
            return
          end
        end
      else
        timer.performWithDelay( delta, ringLoop )
      end

    end


    thisTimer =  timer.performWithDelay( delta, ringLoop )
    --print(thisTimer)
    table.insert( timerTable, thisTimer )


end

local function fireCircle( event )


  if ( event.phase == "began" ) then
    fireCircle2(event.x, event.y)
  elseif ( event.phase == "moved") then
  elseif ( event.phase == "ended" ) then

  end
end
local nextWave
local function nextWaveF()
  nextWave()
end

local function gameLoop()
  if #ballsTable == 0 then
    --timer.cancel( gameLoopTimer )
    nextWaveF()
    return
  end
  for i=1,#ballsTable do
    if i > #ballsTable then
      break
    end

    if ballsTable[i] ~= nil and ballsTable[i].y > border and ballsTable[i].y < display.contentWidth - border then
      local x = ballsTable[i].x
      local y = ballsTable[i].y
      local s = ballsTable[i].s
      -- Gravity:
      local dx = display.contentCenterX - x
      local dy = display.contentCenterY - y
      local d  = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

      dx = dx / d
      dy = dy / d

      local stopingForce = {}
      stopingForce.x = 0
      stopingForce.y = 0

      local velocity = {}
      velocity.x, velocity.y = ballsTable[i]:getLinearVelocity()
      local xAccel = dx * Acceleration / ballsTable[i].s
      local yAccel = dy * Acceleration / ballsTable[i].s
      velocity.x = velocity.x + xAccel
      velocity.y = velocity.y + yAccel

      for j=1,#collisionsTable do
        if collisionsTable[j] ~= nil then
          local dx2 = x - collisionsTable[j].x
          local dy2 = y - collisionsTable[j].y
          local d2 = math.sqrt(math.pow(dx2, 2) + math.pow(dy2, 2))
          if collisionsTable[j].strokeWidth/2 > math.abs( collisionsTable[j].path.radius - d2 )then
            local baseDamage =  (collisionsTable[j].strokeWidth / collisionsTable[j].startingStrokeWidth  ) / ballsTable[i].mySize * (1 + upgradesMax.damage *upgrades.damage / maxLevel) / 2
            local baseForce =  (collisionsTable[j].strokeWidth / collisionsTable[j].startingStrokeWidth  )
            for k=1,3 do
              ballsTable[i].currentColor[k] =   ballsTable[i].currentColor[k] - (ballsTable[i].baseColor[k] - ballsTable[i].deathColor[k]) * baseDamage
            end
            ballsTable[i]:setFillColor(unpack( ballsTable[i].currentColor))
            stopingForce.x = stopingForce.x + baseForce * ( dx2  / d2 )  * velocity.x  / ballsTable[i].s * (1 + upgradesMax.pushback * upgrades.pushback / maxLevel) / 60
            stopingForce.y = stopingForce.y + baseForce * ( dy2  / d2 )  * velocity.y  / ballsTable[i].s * (1 + upgradesMax.pushback * upgrades.pushback / maxLevel) / 60

  		    end
        end
      end
      velocity.x = velocity.x - stopingForce.x
      velocity.y = velocity.y - stopingForce.y
      if math.abs(xAccel) > math.abs(velocity.x) or math.sign(xAccel) ~=  math.sign(velocity.x) then
        velocity.x = xAccel
      end

      if math.abs(yAccel) > math.abs(velocity.y) or math.sign(yAccel) ~=  math.sign(velocity.y) then
        velocity.y = yAccel
      end


      if ballsTable[i].currentColor[1] < 0 or ballsTable[i].currentColor[1] > 1 or math.abs(ballsTable[i].currentColor[1] - ballsTable[i].deathColor[1]) < math.abs(ballsTable[i].baseColor[1] - ballsTable[i].deathColor[1])/2 then

        -- Score++:
        local addScore = ballsTable[i].mySize * 100
        score = score + addScore
        local scorePlus = display.newText( uiGroup, "+"..addScore, ballsTable[i].x,  ballsTable[i].y, "titillium-bold.ttf", ballSize / ballsTable[i].s / 2 )
        transition.to( scorePlus, { time=250, alpha=0, transition=easing.linear, delay=250} )

        ballsTable[i].onDestroy()
        physics.removeBody( ballsTable[i] )
        display.remove(ballsTable[i])
        table.remove(ballsTable, i)
        i = i - 1

      else
        ballsTable[i]:setLinearVelocity( velocity.x, velocity.y )
      end
    elseif ballsTable[i].y < border then
        ballsTable[i]:setLinearVelocity( 0, display.contentWidth / 20 )
    elseif ballsTable[i].y > display.contentWidth - border then
        ballsTable[i]:setLinearVelocity( 0, -display.contentWidth / 20 )
    end
  end

end

local function nextWave3()

  physics.start(  )
  --physics.pause(  )
  gameLoopTimer = timer.performWithDelay( 1000/60, gameLoop, 0 )

end
local function nextWave2()

  gameLoopTimer = timer.performWithDelay( 1000/60, gameLoop, 0 )

end
nextWave = function()

  waveNumber = waveNumber + 1
  local newWaveText = display.newText(uiGroup, "WAVE ".. waveNumber , display.contentCenterX, 0, "titillium-bold.ttf", display.contentHeight / 8 )
  newWaveText.anchorY = 0
  newWaveText.y =  display.contentHeight / 32
  if waveNumber  ~= 1 then
    --timer.cancel( gameLoopTimer )
    --Runtime:removeEventListener(  "touch", fireCircle )

    local bonusScore = 1000 * waveNumber
    local bonusScoreText = display.newText(uiGroup, "+".. bonusScore , display.contentCenterX, newWaveText.y + display.contentWidth/8,   "titillium-bold.ttf", display.contentHeight / 16 )
    bonusScoreText.anchorY = 0
    bonusScoreText.y = newWaveText.y +  newWaveText.height/2 + bonusScoreText.height/2
    score = score + bonusScore
    transition.to(bonusScoreText, {delay = 500, time = 800, alpha = 0, onComplete=
      function() if bonusScoreText ~= nil then
        display.remove(bonusScoreText)
      end
    end})
    local bonusMoney = waveNumber
    income = income + bonusMoney

    local moneyBonusText = display.newText(uiGroup, "+".. bonusMoney .. "⋆" , display.contentCenterX, bonusScoreText.y + bonusScoreText.height/3 ,   "titillium-bold.ttf", display.contentHeight / (16) )
    moneyBonusText.anchorY = 0
    moneyBonusText.y = bonusScoreText.y + bonusScoreText.height/2 + moneyBonusText.height/2
    transition.to(moneyBonusText, {delay = 500, time = 800, alpha = 0, onComplete=
      function()
      if moneyBonusText ~= nil then
        display.remove(moneyBonusText)
      end
      -- if moneyText ~= nil then
      --   moneyText.text = "" .. money
      -- end
    end})
  end



  --timer.performWithDelay( 1000, nextWave2, 1 )
  transition.to(newWaveText, {delay = 500, time = 1000, alpha = 0, onComplete = function() display.remove(newWaveText) end})
  --upperWall.y = - 2* ballSize
  --lowerWall.y = display.contentWidth + 2 * ballSize

  --makeBalls(waveTable[waveNumber])
  makeBalls(waveTable[waveNumber])
  --timer.performWithDelay( 100, nextWave2, 1 )
  --transition.to( upperWall, { time=10000, y=0, transition=easing.linear, delay=2000} )
  --transition.to( lowerWall, { time=10000, y= display.contentWidth, transition=easing.linear, delay=2000} )

end
local function endGame()

  local newWaveText = display.newText(uiGroup, "GAME OVER" , display.contentCenterX,border + ( display.contentWidth/2 - display.contentHeight / 4 - border)/2, "titillium-bold.ttf", display.contentHeight / 6 )

  Runtime:removeEventListener(  "touch", fireCircle )


	composer.setVariable( "score", score )
  composer.setVariable( "income", income )

  composer.gotoScene( "menu", {effect = "fade", time = 800})

end

local function onCollision( event )

  local obj1 = event.object1
  local obj2 = event.object2

  local ball
  if obj1.myName == "ball" then
    ball = obj1

  elseif obj2.myName == "ball" then
    ball = obj2

  else
    ball = nil
  end

if ( obj1.myName == "lowerWall" or obj2.myName == "lowerWall" ) then
  if(ball == nil) then
    return
  end
  local vx, vy = ball:getLinearVelocity()
  if vy >= 0 then
    ball:setLinearVelocity(-vx, -display.contentWidth/20)
  end

elseif ( obj1.myName == "upperWall" or obj2.myName == "upperWall" ) then
  if(ball == nil) then
    return
  end
  local vx, vy = ball:getLinearVelocity()
  if vy <= 0 then
    ball:setLinearVelocity(-vx, display.contentWidth/20)
  end
end

  if ( event.phase == "began") then

    if ( obj1.myName == "baseCircle" or obj2.myName == "baseCircle" )
    then
      if(ball == nil) then
        return
      end
      if( gameLoopTimer ~= nil) then timer.cancel( gameLoopTimer )end
      touchRect:removeEventListener( "touch", fireCircle )
      function onEnd()
        if goingDown then
          return
        end
        display.remove(ball)
        endGame()
        -- return
        -- if goingDown then
        --   return
        -- end
        -- local baseDamage =   math.abs((ball.deathColor[1] - ball.currentColor[1]) / (ball.baseColor[1] - ball.deathColor[1]))
        -- for k=1,3 do
        --   baseCircle.currentColor[k] =   baseCircle.currentColor[k] - ((baseCircle.baseColor[k] - baseCircle.deathColor[k]) * baseDamage / 64) * ball.mySize
        --   --print(baseDamage)
        -- end
        -- if baseCircle.currentColor[1] > baseCircle.deathColor[1] then
        --   endGame()
        -- end
        -- baseCircle:setFillColor(unpack(baseCircle.currentColor))
        --
      end
      --display.remove(ball.backgroundBall)
      transition.to( ball, {time=500, x=baseCircle.x, y=baseCircle.y,
        transition=easing.inQuad, onComplete=onEnd} )

    end
  elseif( event.phase == "ended") then
    if ( obj1.myName == "baseCircle" or obj2.myName == "baseCircle" ) then
      local ball
      if obj1.myName == "ball" then
        ball = obj1
      elseif obj2.myName == "ball" then
        ball = obj2
      else
        return
      end

      physics.removeBody( ball )
    end

  end

end

local function handleButtonEvent( event )

    local id = tonumber(event.target.id)

    if event.phase == "began" then
      if id == 10 then

      elseif id == 20 then

      end

    elseif ( "ended" == event.phase ) then

      audio.play( clickSound )
      if id == pause then
        composer.setVariable( "highScoreString", highScoreText2.text )
        composer.setVariable( "themeColor", themeColor )

        composer.removeScene( "pausemenu" )
        composer.gotoScene( "pausemenu")

      elseif id == 100 then


      end

    end
    return true
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

  system.activate( "multitouch" )

  local pos = math.random(1, #colors)
  themeColor = {convertColor(colors[pos])}
  table.remove( colors, pos )

  print("ballSize " .. ballSize .. " size " .. display.contentHeight)

  ballsTable = {}
  audio.setVolume( 0.5 )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	physics.pause()  -- Temporarily pause the physics engine

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



	-- Load the background
	-- local background1 = display.newRect( underGroup2, display.contentCenterX, border/2, display.contentHeight, border )
  -- background1:setFillColor(0,0,0)
  --
  -- local background2 = display.newRect( underGroup2, display.contentCenterX, display.contentWidth - border/2, display.contentHeight, border)
  -- background2:setFillColor(0,0,0)

  touchRect = display.newRect( backGroup, display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight ) --, display.contentHeight / 2  )
  touchRect:setFillColor(convertColor(0x2A2F36))

  --local titleBackGround = display.newRect(underGroup2, display.contentCenterX, (display.contentHeight / 16), display.contentWidth, (display.contentHeight / 8) )
  --titleBackGround:setFillColor(unpack(themeColor))
  --local titleBackGround2 = display.newRect(uiGroup, display.contentCenterX, (display.contentHeight / 16), display.contentWidth, (display.contentHeight / 8) )
  --local tempT = {unpack(themeColor)}
  --tempT[4] = 0.25
  --titleBackGround2:setFillColor(unpack(tempT))

  --local downBackGround2 = display.newRect(underGroup2, display.contentCenterX, display.contentWidth - (display.contentHeight / 16), display.contentHeight, (display.contentHeight / 8) )
  --downBackGround2:setFillColor(unpack(themeColor))
  --local downBackGround = display.newRect(uiGroup, display.contentCenterX, display.contentWidth - (display.contentHeight / 16), display.contentHeight, (display.contentHeight / 8) )
  --downBackGround:setFillColor(unpack(tempT))

  highScore = composer.getVariable( "highScore" )
  local highScoreString = "" .. highScore
  while string.len(highScoreString) < 6 do
    highScoreString = "0" .. highScoreString
  end

  --local highScoreBackground = display.newRoundedRect(sceneGroup, display.contentWidth/4 , titleBackGround.y  , display.contentWidth/2 - 2*  (display.contentWidth / 32),(display.contentWidth / 16) *   0.7 , (display.contentWidth / 16) *   0.7/2  )
  --highScoreBackground:setFillColor(convertColor(0x2A2F36))
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


  local pauseButton = widget.newButton(
  {
    x=0,
    y=highScoreText1.y +  highScoreText1.height/2,
    fillColor = { default={convertColor(0x2A2F36)}, over={1,1,1,0.2}},
    emboss = false,
    shape = "circle",
    radius=display.contentHeight/24,
    onEvent= handleButtonEvent,
    id = pause
  })


  pauseButton.x = display.contentWidth-(display.contentHeight / 32) - pauseButton.width/2
  sceneGroup:insert(pauseButton)
  local newImg = display.newImage( sceneGroup, "pause.png", pauseButton.x  , pauseButton.y )

  fitImage(newImg, 1.25* display.contentHeight/24  , 1.25* display.contentHeight/24  )

  -- leftWall = display.newRect(0 , display.contentCenterY, 1, display.contentWidth + 4 * ballSize)
  -- leftWall:setFillColor(1,1,1)
  -- physics.addBody( leftWall, "static" )
  --
  -- rightWall = display.newRect( display.contentHeight , display.contentCenterY, 1, display.contentWidth + 4 * ballSize)
  -- rightWall:setFillColor(1,1,1)
  -- physics.addBody( rightWall, "static" )

  -- upperWall = display.newRect(backGroup, display.contentCenterX, border, display.contentHeight, 1)
  -- upperWall:setFillColor(1,1,1,0)
  -- physics.addBody( upperWall, "static" )
  -- upperWall.isSensor = true
  -- upperWall.myName = "upperWall"
  --
  -- lowerWall = display.newRect(backGroup, display.contentCenterX, display.contentWidth - border , display.contentHeight, 1)
  -- lowerWall:setFillColor(1,1,1,0)
  -- physics.addBody( lowerWall, "static" )
  -- lowerWall.isSensor = true
  -- lowerWall.myName = "lowerWall"

  baseCircle = display.newCircle( uiGroup, display.contentCenterX, display.contentCenterY, display.contentHeight / 4) --, display.contentHeight / 2  )
  baseCircle:setFillColor(unpack(themeColor))
  --baseCircle.baseColor = {unpack(themeColor)}
  --baseCircle.deathColor = {convertColor(0xF23C55)}
  --baseCircle.currentColor ={convertColor(0x61C791)}
  baseCircle.myName = "baseCircle"
  physics.addBody( baseCircle,"static", {radius = display.contentHeight / 4} )
  baseCircle.isSensor = true
  baseCircle:addEventListener( "touch",  function() return true end)
  -- local bottomSensor = display.newRect( display.contentCenterX, display.contentWidth + ballSize / 10, display.contentHeight, 20 )
  -- physics.addBody( bottomSensor, "static" )
  -- bottomSensor.myName = "bottomSensor"
  -- bottomSensor.isSensor = true

  touchRect:addEventListener( "touch", fireCircle )

	-- Display lives and score
	--livesText = display.newText( uiGroup, "Lives: " .. lives, 200, 80, native.systemFont, 36 )
	scoreText = display.newText( uiGroup, "000000", display.contentCenterX,  display.contentCenterY, "titillium-bold.ttf", display.contentHeight / 9 )
  scoreText:setTextColor(1,1,1)
  --local moneyBackground = display.newRoundedRect(uiGroup, display.contentHeight/2 ,scoreText.y + 1.2 *  scoreText.height/2  ,display.contentHeight / 3,(display.contentHeight / 8) *   0.7,(display.contentHeight / 8) *   0.7 , (display.contentHeight / 8) *   0.7/2  )
  --moneyBackground:setFillColor(convertColor(0x2A2F36))

  --moneyText.x = moneyText.x - border*0.5/2
  -- local playButtonRadius = display.contentHeight/4
  -- local circlesY = (display.contentWidth/2 -  playButtonRadius)/12
  -- local circlesRadius = 2 * circlesY


  --local moneyImage2 = display.newImage( backGroup, "particleWhite_3.png", display.contentCenterX  , display.contentCenterY + playButtonRadius + (display.contentWidth/2 - border - playButtonRadius)/2 )
  --fitImage(moneyImage2, 3 * circlesRadius , 3 * circlesRadius )
  --moneyText = display.newText( backGroup, "" .. money,moneyImage2.x ,moneyImage2.y  , "titillium-bold.ttf", display.contentHeight / (14) )
  --moneyText:setTextColor(1,1,1)
  upgrades = composer.getVariable( "upgrades" )

  math.randomseed( os.time() )

  -- local info = {}
  -- info.s = 4
  -- info.m = 1
  -- info.b = 1
  --makeBalls(info)

end


-- show()
function scene:show( event )

  -- Activate multitouch
  goingDown = false
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
    native.setProperty( "androidSystemUiVisibility", "lowProfile" )

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener( "collision", onCollision )
    --money = composer.getVariable("money")
    --moneyText.text = "" .. money

    -- if(bShowTutotorial) then
    --   showTutorial()
    --   timer.performWithDelay( 4000, nextWave, 1 )
    -- else
    --   timer.performWithDelay( 500, nextWave, 1 )
    -- end
    gameLoopTimer = timer.performWithDelay( 1000/60, gameLoop, 0 )
    updateTextTimer = timer.performWithDelay( 1000/60, updateText, 0 )
	end

end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

    if( gameLoopTimer ~= nil) then timer.cancel( gameLoopTimer )end
    Runtime:removeEventListener(  "touch", fireCircle )
    for i=1,#timerTable do
      timer.cancel( timerTable[i] )
    end
    if  myTimer ~= nil and myTimer.myTimer ~= nil then
      timer.cancel(  myTimer.myTimer )
    end
    myTimer = nil

    if  updateTextTimer ~= nil  then
      timer.cancel( updateTextTimer )
    end

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener( "collision", onCollision )

	end
end


-- destroy()
function scene:destroy( event )
  goingDown = true
	local sceneGroup = self.view
  if( gameLoopTimer ~= nil) then timer.cancel( gameLoopTimer )end
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
