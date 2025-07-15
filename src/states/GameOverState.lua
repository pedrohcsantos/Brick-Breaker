GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
  self.score = params.score
  self.highScores = params.highScores
end

function GameOverState:update(dt)
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    local highScore = false

    for i = 10, 1, -1 do
      local score = self.highScores[i].score or 0
      
      if self.score > score then
        highScoreIndex = i
        highScore = true
      end
    end

    if highScore then
      
      gStateMachine:change('enter-high-score', {
        highScores = self.highScores,
        score = self.score,
        scoreIndex = highScoreIndex
      })
    else
      gStateMachine:change('start', {
        highScores = self.highScores
      })
    end
  end

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

function GameOverState:render()
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf('FIM DE JOGO', 0, gameHeight / 3, gameWidth, 'center')
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Pontos finais: ' .. tostring(self.score), 0, gameHeight / 2,
    gameWidth, 'center')
  love.graphics.printf('Pressione Enter!', 0, gameHeight - gameHeight / 4,
    gameWidth, 'center')
end