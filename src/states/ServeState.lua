ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    self.paddle = params.paddle
    self.ball = params.ball
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.level = params.level
end

function ServeState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    self.paddle:update(dt)
    self.ball.x = self.paddle.x + self.paddle.width / 2 - 4
    self.ball.y = self.paddle.y - self.ball.height


    if love.keyboard.wasPressed('space') then
        gStateMachine:change('play', {
            paddle = self.paddle,
            ball = self.ball,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            level = self.level
        })
    end
end

function ServeState:render()
    self.ball:render()
    self.paddle:render()

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderHealth(self.health)
    renderScore(self.score)

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, VIRTUAL_HEIGHT/ 3, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Space to Serve', 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
end
