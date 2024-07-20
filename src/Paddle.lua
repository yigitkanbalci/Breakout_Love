Paddle = Class{}

function Paddle:init(paddle)
    self.x = VIRTUAL_WIDTH / 2 - 32
    self.y = VIRTUAL_HEIGHT / 2 + 112

    self.dx = 0

    self.width = 64
    self.height = 16

    self.currentPaddle = paddle
end

function Paddle:update(dt)
    if love.keyboard.isDown('left') then
        self.dx = -PADDLE_SPEED
    elseif love.keyboard.isDown('right') then
        self.dx = PADDLE_SPEED
    else
        self.dx = 0
    end
    self.x = self.x + self.dx * dt

    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end

end

function Paddle:render()
    print(self.size)
    love.graphics.draw(gTextures['breakout'], gFrames['paddles'][((self.currentPaddle - 1) % 4) * 4 + (math.floor((self.currentPaddle - 1) / 4)) + 1], self.x, self.y)
end
