PlayState = Class{__includes = BaseState}

function PlayState:init(params)
    self.paddle = Paddle(1, 2)
    self.ball = Ball(math.random(1, 7))

    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)

    self.ball.x = VIRTUAL_WIDTH / 2 - 4
    self.ball.y = VIRTUAL_HEIGHT - 42
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    self.paddle:update(dt)
    self.ball:update(dt)
end

function PlayState:render()
    self.paddle:render()
    self.ball:render()
end