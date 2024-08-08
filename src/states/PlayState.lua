PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    self.paddle = params.paddle --Paddle(1, 2)
    self.ball = params.ball --Ball(math.random(1, 7))
    self.health = params.health
    self.score = params.score
    self.level = params.level
    self.highScores = params.highScores

    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)

    self.ball.x = params.ball.x
    self.ball.y = params.ball.y

    self.paused = false

    self.boosterActive = false
    self.elapsedTime = 0
    self.spawnInterval = math.random(15, 20)
    self.boosterDuration = 20
    self.spawnedBoosters = {}
    self.spawnedBalls = {}
    self.bricks = params.bricks --LevelMaker.createMap()
end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    self.elapsedTime = self.elapsedTime + dt

    if self.elapsedTime > self.spawnInterval and self.boosterActive == false then
        local choices = {3, 7}
        local randomIndex = math.random(1, #choices)
        local randomNumber = choices[randomIndex]
        local booster = Booster(randomNumber)
        self.elapsedTime = 0
        table.insert(self.spawnedBoosters, booster)
    end

    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    self.paddle:update(dt)
    self.ball:update(dt)
    if self.boosterActive == true then
        for k, ball in pairs(self.spawnedBalls) do
            ball:update(dt)
            self:handleCollisions(ball)
        end
    end

    if self.boosterActive == true and self.elapsedTime > self.boosterDuration then
        self.boosterActive = false
        self.spawnedBalls = {}
        self.elapsedTime = 0
    end

    for k, booster in pairs(self.spawnedBoosters) do
        if booster.inPlay == true then
            booster:update(dt)
            if booster:collides(self.paddle) then
                if booster.skin == 7 then
                    local new_skin

                    repeat
                        new_skin = math.random(1, 7)
                    until new_skin ~= self.ball.skin

                    local ball1 = Ball(new_skin)
                    local ball2 = Ball(new_skin)
                    ball1.dx = math.random(-200, 200)
                    ball1.dy = math.random(-50, -60)
                    ball2.dx = math.random(-200, 200)
                    ball2.dy = math.random(-50, -60)
                    ball1.x = self.ball.x
                    ball1.y = self.ball.y
                    ball2.x = self.ball.x
                    ball2.y = self.ball.y
                    table.insert(self.spawnedBalls, ball1)
                    table.insert(self.spawnedBalls, ball2)
                    self.boosterActive = true
                    booster.inPlay = false
                else
                    if self.health < 3 then
                        self.health = self.health + 1
                        gSounds['recover']:play()
                    end

                    self.boosterActive = false
                    booster.inplay = false
                end

            end
        end

    end

    self:handleCollisions(self.ball)

    if self.ball.y >= VIRTUAL_HEIGHT then
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score,
                highScores = self.highScores
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                ball = self.ball,
                score = self.score,
                health = self.health,
                level = self.level,
                highScores = self.highScores
            })
        end
    end

    for k, brick in pairs(self.bricks) do
        brick:update(dt)
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
    self.ball:render()
    if self.boosterActive == true then
        for k, ball in pairs(self.spawnedBalls) do
            ball:render()
        end
    end

    for k, booster in pairs(self.spawnedBoosters) do
        if booster.inPlay == true then
            booster:render()
        end
    end

    renderHealth(self.health)
    renderScore(self.score)

    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, "center")
    end

end

function PlayState:isVictorious()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end
    return true
end

function PlayState:handleCollisions(ball)
    if ball:collides(self.paddle) then
        ball.y = self.paddle.y - ball.height
        
        ball.dy = -ball.dy
        
        local paddleCenter = self.paddle.x + self.paddle.width / 2
        local ballCenter = ball.x + ball.width / 2
        local difference = ballCenter - paddleCenter
        
        local normalizedDifference = difference / (self.paddle.width / 2)
        
        ball.dx = normalizedDifference * 200  -- Scale the deflection angle
        
        ball.dx = ball.dx + self.paddle.dx * 0.5  -- Factor in the paddle's movement
        
        if math.abs(ball.dx) < 50 then
            ball.dx = 50 * (ball.dx / math.abs(ball.dx))
        end
        
        gSounds['paddle-hit']:play()
    end
    

    for k, brick in pairs(self.bricks) do
        if brick.inPlay and ball:collides(brick) then
            brick:hit()
            if self:isVictorious() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    ball = self.ball,
                    highScores = self.highScores
                })
            end

            self.score = self.score + (brick.tier * 200 + brick.color * 20)

            if ball.x + 2 < brick.x and ball.dx > 0 then
                ball.dx = -ball.dx
                ball.x = brick.x - ball.width
            elseif ball.x + ball.width > brick.x + brick.width and ball.dx < 0 then
                ball.dx = -ball.dx
                ball.x = brick.x + brick.width
            elseif ball.y + ball.height > brick.y + brick.height and ball.dy < 0 then
                ball.dy = -ball.dy
                ball.y = brick.y + brick.height
            else
                ball.dy = -ball.dy
                ball.y = brick.y - ball.height
            end

            ball.dy = ball.dy * 1.02

            break
        end
    end
end
