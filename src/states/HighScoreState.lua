HighScoreState = Class{__includes = BaseState}

function HighScoreState:enter(params)
  self.highScores = params.highScores
end

function HighScoreState:update(dt)
  if love.keyboard.wasPressed('escape') then
    
    gStateMachine:change('start', {
      highScores = self.highScores
    })
  end
end

function HighScoreState:render()
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf('High Scores', 0, 20, gameWidth, 'center')

  love.graphics.setFont(gFonts['medium'])

  for i = 1, 10 do
    local name = self.highScores[i].name or '---'
    local score = self.highScores[i].score or '---'

    love.graphics.printf(tostring(i) .. '.', gameWidth / 4,
      60 + i * 13, 50, 'left')

    love.graphics.printf(name, gameWidth / 4 + 38,
      60 + i * 13, 50, 'right')
    
    love.graphics.printf(tostring(score), gameWidth / 2,
      60 + i * 13, 100, 'right')
  end

  love.graphics.setFont(gFonts['small'])
  love.graphics.printf("Aperte a tecla Esc para retornar ao menu!",
    0, gameHeight - 18, gameWidth, 'center')
end