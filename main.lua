require("src/dependencies")

function love.load()
  love.window.setTitle('Brick breakout')

  love.graphics.setDefaultFilter('nearest', 'nearest')
  
  math.randomseed(os.time())

  gFonts = {
    ['small'] = love.graphics.newFont('assets/fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('assets/fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('assets/fonts/font.ttf', 32)
  }
  love.graphics.setFont(gFonts['small'])

  gTextures = {
    ['background'] = love.graphics.newImage('assets/graphics/background.jpg'),
    ['main'] = love.graphics.newImage('assets/graphics/breakout.png'),
    ['arrows'] = love.graphics.newImage('assets/graphics/arrows.png'),
    ['hearts'] = love.graphics.newImage('assets/graphics/hearts.png'),
    ['particle'] = love.graphics.newImage('assets/graphics/particle.png')
  }

  gFrames = {
    ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24),
    ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
    ['balls'] = GenerateQuadsBalls(gTextures['main']),
    ['bricks'] = GenerateQuadsBricks(gTextures['main']),
    ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9),
    ['powerups'] = GenerateQuadsPowerups(gTextures['main']),
  }

  push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
    fullscreen = false,
    resizable = true,
    vsync = true
  })


  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['high-scores'] = function() return HighScoreState() end,
    ['serve'] = function() return ServeState() end,
    ['paddle-select'] = function() return PaddleSelectState() end,
    ['play'] = function() return PlayState() end,
    ['victory'] = function() return VictoryState() end,
    ['game-over'] = function() return GameOverState() end,
    ['enter-high-score'] = function() return EnterHighScoreState() end
  }
  gStateMachine:change('start', {
    highScores = loadHighScores()
  })

  love.keyboard.keysPressed = {}
end

function love.resize(w, h)
  push:resize(w,h)
end

function love.update(dt)
  gStateMachine:update(dt)

  love.keyboard.keysPressed = {}
end

function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
  if love.keyboard.keysPressed[key] then
    return true
  else
    return false
  end
end

function love.draw()
  push:apply('start')

  local backgroundWidth = gTextures['background']:getWidth()
  local backgroundHeight = gTextures['background']:getHeight()

  love.graphics.draw(
    gTextures['background'],
    0, 0,
    0,
    gameWidth / (backgroundWidth - 1), gameHeight / (backgroundHeight - 1)
  )

  gStateMachine:render()


  push:apply('end')
end

function renderHealth(health)
  local healthX = gameWidth - 100

  for i = 1, health do
    love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
    healthX = healthX + 11
  end

  for i = 1, 3 - health do
    love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
    healthX = healthX + 11
  end
end

function renderScore(score)
  love.graphics.setFont(gFonts['small'])
  love.graphics.print('Score:', gameWidth - 60, 5)
  love.graphics.printf(tostring(score), gameWidth - 50, 5, 40, 'right')
end

function loadHighScores()
  love.filesystem.setIdentity('breakout')

  if not love.filesystem.getInfo('breakout.lst') then
    local scores = ''
    for i = 10, 1, -1 do
      scores = scores .. 'CTO\n'
      scores = scores .. tostring(i * 1000) .. '\n'
    end

    love.filesystem.write('breakout.lst', scores)
  end

  local name = true
  local counter = 1

  local scores = {}

  for i = 1, 10 do
    scores[i] = {
      name = nil,
      score = nil
    }
  end

  for line in love.filesystem.lines('breakout.lst') do
    if name then
      scores[counter].name = string.sub(line, 1, 3)
    else
      scores[counter].score = tonumber(line)
      counter = counter + 1
    end

    name = not name
  end

  return scores
end

function displayFPS()
  love.graphics.setFont(gFonts['small'])
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end