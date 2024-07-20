require 'src/Dependencies'

function love.conf(t)
    t.console = true
end


function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    love.window.setTitle("Breakout")

    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32),
    }

    gTextures = {
        ['background'] = love.graphics.newImage('images/background.png'),
        ['arrows'] = love.graphics.newImage('images/arrows.png'),
        ['blocks'] = love.graphics.newImage('images/blocks.png'),
        ['breakout_big'] = love.graphics.newImage('images/breakout_big.png'),
        ['breakout'] = love.graphics.newImage('images/breakout.png'),
        ['hearts'] = love.graphics.newImage('images/hearts.png'),
        ['particle'] = love.graphics.newImage('images/particle.png'),
        ['ui'] = love.graphics.newImage('images/ui.png'),
    }

    gSounds = {
        ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
        ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
        ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
        ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
        ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

        ['music'] = love.audio.newSource('sounds/music.wav', 'static')
    }

    gFrames = {
        ['paddles'] = GeneratePaddleQuads(gTextures['breakout']),
        ['balls'] = GenerateBallQuads(gTextures['breakout']),
        ['bricks'] = GenerateBrickQuads(gTextures['breakout']),
        ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9),
        ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24)
    }

    love.graphics.setFont(gFonts['small'])

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
    })

    print(table.getn(gFrames['paddles']))

    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['play'] = function() return PlayState() end,
        ['serve'] = function() return ServeState() end,
        ['game-over'] = function() return GameOverState() end,
        ['victory'] = function() return VictoryState() end,
        ['high-scores'] = function() return HighScoresState() end,
        ['enter-high-score'] = function() return EnterHighScoreState() end,
        ['paddle-select'] = function() return PaddleSelectState() end,
    
    }
    gStateMachine:change('start', {
        highScores = loadHighScores()
    })

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    gStateMachine:update(dt)
    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.draw()
    push:start()

    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(gTextures['background'], 0, 0, 0, VIRTUAL_WIDTH / backgroundWidth, VIRTUAL_HEIGHT / backgroundHeight)

    gStateMachine:render()

    displayFPS()

    push:finish()
end

function loadHighScores()
    love.filesystem.setIdentity('breakout')

if not love.filesystem.getInfo('breakout.lst') then
    local scores_str = ''
    for i = 10, 1, -1 do
        scores_str = scores_str .. 'CTO\n'
        scores_str = scores_str .. tostring(i * 1000) .. '\n'
    end

    love.filesystem.write('breakout.lst', scores_str)
end

local name = true
local currentName = nil
local counter = 1

local scores = {}

for i = 1, 10 do
    scores[i] = {
        name = nil,
        score = nil,
    }
end

for line in love.filesystem.lines('breakout.lst') do
    if name then
        scores[counter].name = string.sub(line, 1, 3)
    else
        scores[counter].score = tonumber(line)
        counter = counter + 1
    end

    name = not name

    -- Ensure counter doesn't exceed the bounds of the scores array
    if counter > #scores then
        break
    end
end

return scores
end

function displayFPS()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end

function renderScore(score)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Score:', VIRTUAL_WIDTH - 55, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end

function renderHealth(health)
    local healthX = VIRTUAL_WIDTH - 90
    
    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
        healthX = healthX + 10
    end

    for i = 1, 3 - health do
    love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
    healthX = healthX + 10
    end
end
