PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.score = params.score
  self.highScores = params.highScores
  self.health = params.health
  self.level = params.level
  
  self.ball = params.ball
  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-60, -70)
  self.ball.inPlay = true
  self.balls = {
    [1] = self.ball,
  }
  self.ballsCount = 1
  
  self.recoverPoints = params.recoverPoints
  self.powerup = nil
  self.paused = false
  self.lastPowerupTime = love.timer.getTime()
end

function PlayState:update(dt)
  if self.paused then
    if love.keyboard.wasPressed('space') then
      self.paused = false

    else
      return
    end
  elseif love.keyboard.wasPressed('space') then
    self.paused = true

    return
  end


  if self.powerup and self.powerup.inPlay then
    if self.powerup:collides(self.paddle) then
      self.powerup.inPlay = false

      if not (self.powerup.type == 4) then
        self.score = self.score + 200
      end

      if self.powerup.type == 3 then
        self.health = math.min(3, self.health + 1)
      end
      
      if self.powerup.type == 4 then
        self:takeHealth()
      end
      
      if self.powerup.type == 5 then
        self.paddle:increaseSize()
      end
      
      if self.powerup.type == 6 then
        self.paddle:decreaseSize()
      end

      if self.powerup.type == 7 then
        for b, ball in pairs(self.balls) do
          ball:decreaseSize()
        end
      end
      
      if self.powerup.type == 8 then
        for b, ball in pairs(self.balls) do
          ball:increaseSize()
        end
      end
      
      if self.powerup.type == 10 then
        for i = #self.bricks, 1, -1 do
          brick = self.bricks[i]
          
          if brick.isLocked then
            brick.isLocked = false
            break
          end
      end
    end
      if self.powerup.type == 9 and self.ballsCount < 3 then
        local extraBallIndex = self.ballsCount + 1

        for key, value in pairs(self.balls) do
          if not value.inPlay then
            extraBallIndex = key
          end
        end

        local extraBall = Ball(math.random(7), extraBallIndex)
        extraBall.inPlay = true
        extraBall.x = self.paddle.x + (self.paddle.width / 2) - 4
        extraBall.y = self.paddle.y - extraBall.width
        extraBall.dx = math.random(-200, 200)
        extraBall.dy = math.random(-60, -70)
        
        self.balls[extraBallIndex] = extraBall
        self.ballsCount = self.ballsCount + 1
      end
    end
  else
    local maxPowerup = self:hasLockedBricks() and 10 or 9
    
    local sinceLastPowerup = love.timer.getTime() - self.lastPowerupTime
    
    if sinceLastPowerup > math.random(12, 20) then
      self.powerup = Powerup(math.random(3, maxPowerup))
      self.lastPowerupTime = love.timer.getTime()
    end
  end


  for b, ball in pairs(self.balls) do
    if ball.inPlay then
      ball:update(dt)

      if ball:collides(self.paddle) then
        ball.y = self.paddle.y - ball.width
        ball.dy = -ball.dy
    

        if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
          ball.dx = -50 + -(ball.width * (self.paddle.x + self.paddle.width / 2 - ball.x))

        elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
          ball.dx = 50 + (ball.width * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
        end
        
      end

      for k, brick in pairs(self.bricks) do
        brick:update(dt)
        
        if brick.inPlay and ball:collides(brick) then
          if not brick.isLocked then
            brick:hit()
            
            self.score = self.score + (brick.tier * 200 + brick.color * 25)

            if self.score > self.recoverPoints then
              self.health = math.min(3, self.health + 1)

              self.recoverPoints = math.min(100000, self.recoverPoints * 2)

            end

            if self:checkVictory() then
              self.paddle:resetSize()

              gStateMachine:change('victory', {
                level = self.level,
                paddle = self.paddle,
                health = self.health,
                score = self.score,
                ball = self.balls[1],
                recoverPoints = self.recoverPoints
              })
            end
          end


          if ball.x + 2 < brick.x and ball.dx > 0 then
            ball.dx = -ball.dx
            ball.x = brick.x - ball.width
          

          elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
            ball.dx = -ball.dx
            ball.x = brick.x + 32
          

          elseif ball.y < brick.y then
            ball.dy = -ball.dy
            ball.y = brick.y - ball.width
          

          else
            ball.dy = -ball.dy
            ball.y = brick.y + 16
          end

          ball.dy = ball.dy * 1.02
          break
        end
      end

      
      if ball.y >= gameHeight and ball.inPlay then
        local lastBall = self.ballsCount == 1
        ball.inPlay = false
        self.ballsCount = math.max(0, self.ballsCount - 1)
        
        if lastBall then
          self:takeHealth()
        end
      end
    end
  end

  self.paddle:update(dt)
  
  if self.powerup and self.powerup.inPlay then
    self.powerup:update(dt)
  end

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

function PlayState:render()
  for k, brick in pairs(self.bricks) do
    brick:render()
  end

  for k, brick in pairs(self.bricks) do
    brick:renderParticles()
  end
  
  self.paddle:render()

  for b, ball in pairs(self.balls) do
    if ball.inPlay then
      ball:render()
    end
  end
  
  if self.powerup then
    self.powerup:render()
  end

  renderScore(self.score)
  renderHealth(self.health)
  
  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("Pausado", 0, gameHeight / 2 - 16, gameWidth, 'center')
  end
end

function PlayState:checkVictory()
  for k, brick in pairs(self.bricks) do
    if brick.inPlay then
      return false
    end
  end

  return true
end

function PlayState:hasLockedBricks()
  for k, brick in pairs(self.bricks) do
    if brick.isLocked then
      return true
    end
  end

  return false
end

function PlayState:takeHealth()
  self.health = self.health - 1

  if self.health == 0 then
    gStateMachine:change('game-over', {
      score = self.score,
      highScores = self.highScores
    })
  else
    gStateMachine:change('serve', {
      paddle = self.paddle,
      bricks = self.bricks,
      health = self.health,
      score = self.score,
      level = self.level,
      highScores = self.highScores,
      recoverPoints = self.recoverPoints
    })
  end
end