PaddleSelectState = Class{__includes=BaseState}

function PaddleSelectState:enter(params)
    self.highScores = params.highScores
    
end

function PaddleSelectState:init()
    self.currentPaddle = 1
end

function PaddleSelectState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    if love.keyboard.wasPressed('left') then
        if self.currentPaddle == 1 then
            gSounds['no-select']:play()
        else
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle - 1
        end
    elseif love.keyboard.wasPressed('right') then
        if self.currentPaddle == 16 then
            gSounds['no-select']:play()
        else
            gSounds['select']:play()
            self.currentPaddle = self.currentPaddle + 1
        end
    end

    if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        gSounds['confirm']:play()

        gStateMachine:change('serve', {
            paddle = Paddle(self.currentPaddle),
            bricks = LevelMaker.createMap(1),
            ball = Ball(math.random(1,7)),
            health = 3, 
            score = 0,
            highScores = self.highScores,
            level = 1,

        })
    end
end

function PaddleSelectState:render()
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Select your paddle with left and right arrows!', 0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(gFonts['small'])
    love.graphics.printf('(Press Enter to continue!)', 0, VIRTUAL_HEIGHT / 4 + 100, VIRTUAL_WIDTH, 'center')

    if self.currentPaddle == 1 then
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    end

    if self.currentPaddle <= 4 then
        x_index = VIRTUAL_WIDTH / 2 - 16
    elseif self.currentPaddle > 4 and self.currentPaddle <= 8 then
        x_index = VIRTUAL_WIDTH / 2 - 32
    elseif self.currentPaddle > 8 and self.currentPaddle <= 12 then
        x_index = VIRTUAL_WIDTH / 2 - 48
    else
        x_index = VIRTUAL_WIDTH / 2 - 64
    end

    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][1], VIRTUAL_WIDTH / 4 - 24, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
    love.graphics.setColor(1,1,1,1)

    if self.currentPaddle == 16 then
        love.graphics.setColor(40/255, 40/255, 40/255, 128/255)
    end

    love.graphics.draw(gTextures['arrows'], gFrames['arrows'][2], VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(gTextures['breakout'], gFrames['paddles'][((self.currentPaddle - 1) % 4) * 4 + (math.floor((self.currentPaddle - 1) / 4)) + 1],
    x_index, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
end