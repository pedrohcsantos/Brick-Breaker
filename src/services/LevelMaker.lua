
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3


SOLID = 1           
ALTERNATE = 2      
SKIP = 3            
NONE = 4            

LevelMaker = Class{}

function LevelMaker.createMap(level)
  local bricks = {}

  local numRows = math.random(1, 5)
  local numCols = math.random(7, 13)
  numCols = numCols % 2 == 0 and (numCols + 1) or numCols

  local highestTier = math.min(3, math.floor(level / 3))
  local highestColor = math.min(5, level % 3 + 3)

  local maxLockedBricksCount = level * 2
  local lockedBricksCount = 0

  for y = 1, numRows do
    local skipPattern = math.random(2) == 1 and true or false
    local alternatePattern = math.random(2) == 1 and true or false
    
    local alternateColor1 = math.random(1, highestColor)
    local alternateColor2 = math.random(1, highestColor)
    local alternateTier1 = math.random(0, highestTier)
    local alternateTier2 = math.random(0, highestTier)
    
    local skipFlag = math.random(2) == 1 and true or false
    local alternateFlag = math.random(2) == 1 and true or false

    local solidColor = math.random(1, highestColor)
    local solidTier = math.random(0, highestTier)

    for x = 1, numCols do
      if skipPattern and skipFlag then
        skipFlag = not skipFlag
        goto continue
      else
        skipFlag = not skipFlag
      end

      if lockedBricksCount < maxLockedBricksCount then
        b = Brick(
          (x-1) * 32 + 8 + (13 - numCols) * 16,
          y * 16,
          math.random(1, 2) == 1
        )
        lockedBricksCount = lockedBricksCount + 1
      else
        b = Brick(
          (x-1) * 32 + 8 + (13 - numCols) * 16,
          y * 16
        )
      end

      if alternatePattern and alternateFlag then
        b.color = alternateColor1
        b.tier = alternateTier1
        alternateFlag = not alternateFlag
      else
        b.color = alternateColor2
        b.tier = alternateTier2
        alternateFlag = not alternateFlag
      end

      if not alternatePattern then
        b.color = solidColor
        b.tier = solidTier
      end

      table.insert(bricks, b)


      ::continue::
    end
  end

  if #bricks == 0 then
    return LevelMaker.createMap(level)
  else
    return bricks
  end
end