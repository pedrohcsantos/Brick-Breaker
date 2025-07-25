ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.health = params.health
  self.score = params.score
  self.highScores = params.highScores
  self.level = params.level
  self.recoverPoints = params.recoverPoints

  self.ball = Ball(math.random(7), 1)
end

function ServeState:update(dt)
  self.paddle:update(dt)
  
  self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
  self.ball.y = self.paddle.y - self.ball.width

  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    gStateMachine:change('play', {
      paddle = self.paddle,
      bricks = self.bricks,
      health = self.health,
      score = self.score,
      highScores = self.highScores,
      ball = self.ball,
      level = self.level,
      recoverPoints = self.recoverPoints
    })
  end

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

function ServeState:render()
  self.paddle:render()
  self.ball:render()

  for k, brick in pairs(self.bricks) do
    brick:render()
  end

  renderScore(self.score)
  renderHealth(self.health)

  love.graphics.setFont(gFonts['large'])
  love.graphics.printf('Level ' .. tostring(self.level), 0, gameHeight / 3,
    gameWidth, 'center')

  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Pressione Enter para iniciar!', 0, gameHeight / 2,
    gameWidth, 'center')
end