LevelMaker = Class{}

function LevelMaker.createMap(level)
    local bricks = {}

    local numRows = math.random(1, 5)
    local numCols = math.random(7, 13)

    local totalWidth = numCols * 32

    local horizontalOffset = (VIRTUAL_WIDTH - totalWidth) / 2
    for y = 1, numRows do
        for x = 1, numCols do
            b = Brick((x - 1) * 32 + horizontalOffset, y * 16)
            table.insert(bricks, b)
        end
    end

    return bricks
end