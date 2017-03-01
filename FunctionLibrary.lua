local json = require( "json" )
local F = {}



local function F.convertColor( hex )
  local color = {0 , 0, 0}

  color[1] = math.floor( hex / ( 16 * 16 * 16 * 16)) / 255
  color[2] = ( math.floor( (hex - (color[1] * 16 * 16 * 16 * 16 * 255)) / ( 16 * 16 ) ) ) / 255
  color[3] = ( hex - (color[1] * 16 * 16 * 16 * 16 * 255) - (color[2] * 16 * 16 * 255 ) ) / 255


  return color[1], color[2], color[3]
end

local function F.createButton(x, y,  r, id, img )
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




return F
