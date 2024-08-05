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
        local booster = Booster()
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
            if ball:collides(self.paddle) then
                ball.y = self.paddle.y - ball.height
                ball.dy = -ball.dy
        
                if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                    ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
                elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                    ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
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
                local ball1 = Ball(math.random(1, 7))
                local ball2 = Ball(math.random(1, 7))
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
            end
        end

    end

    if self.ball:collides(self.paddle) then
        self.ball.y = self.paddle.y - self.ball.height
        self.ball.dy = -self.ball.dy

        if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
            self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
        elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
            self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
        end

        gSounds['paddle-hit']:play()
    end

    for k, brick in pairs(self.bricks) do
        if brick.inPlay and self.ball:collides(brick) then
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

            if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - self.ball.width
            elseif self.ball.x + self.ball.width > brick.x + brick.width and self.ball.dx < 0 then
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + brick.width
            elseif self.ball.y + self.ball.height > brick.y + brick.height and self.ball.dy < 0 then
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + brick.height
            else
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - self.ball.height
            end

            self.ball.dy = self.ball.dy * 1.02

            break
        end
    end

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