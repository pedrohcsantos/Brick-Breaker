VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
  self.level = params.level
  self.score = params.score
  self.paddle = params.paddle
  self.health = params.health
  self.ball = params.ball
  self.recoverPoints = params.recoverPoints
end

function VictoryState:update(dt)
  self.paddle:update(dt)

  self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
  self.ball.y = self.paddle.y - self.ball.width

  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    gStateMachine:change('serve', {
      level = self.level + 1,
      bricks = LevelMaker.createMap(self.level + 1),
      paddle = self.paddle,
      health = self.health,
      score = self.score,
      recoverPoints = self.recoverPoints
    })
  end
end

function VictoryState:render()
    self.paddle:render()
    self.ball:render()

    renderHealth(self.health)
    renderScore(self.score)

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("Level " .. tostring(self.level) .. " completo!",
      0, gameHeight / 4, gameWidth, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Pressione Enter para iniciar!', 0, gameHeight / 2,
      gameWidth, 'center')
end