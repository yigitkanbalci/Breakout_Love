Booster = Class{}

function Booster:init()
    self.x = math.random(0, VIRTUAL_WIDTH)
    self.y = 0
    
    self.dy = 1

    self.width = 16
    self.height = 16

    self.inPlay = true
end

function Booster:update(dt)
    self.y = self.y + self.dy

    if self.y >= VIRTUAL_HEIGHT then
        self.inPlay = false
    end
end

function Booster:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    self.inPlay = false
    return true
end

function Booster:render()
    if self.inPlay then
        love.graphics.draw(gTextures['breakout'], gFrames['boosters'][7], self.x, self.y)
    end
end