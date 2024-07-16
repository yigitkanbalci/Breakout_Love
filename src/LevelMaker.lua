LevelMaker = Class{}

function LevelMaker.createMap(level)
    local bricks = {}

    local numRows = math.random(1, 5)
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and numCols + 1 or numCols

    local highestTier = math.min(3, math.floor(level / 5))
    local highestColor = math.min(5, level % 5 + 3)


    local totalWidth = numCols * 32

    local horizontalOffset = (VIRTUAL_WIDTH - totalWidth) / 2
    for y = 1, numRows do
        -- whether we want to enable skipping for this row
        local skipPattern = math.random(1, 2) == 1 and true or false

        -- whether we want to enable alternating colors for this row
        local alternatePattern = math.random(1, 2) == 1 and true or false
        
        -- choose two colors to alternate between
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)
        
        -- used only when we want to skip a block, for skip pattern
        local skipFlag = math.random(2) == 1 and true or false

        -- used only when we want to alternate a block, for alternate pattern
        local alternateFlag = math.random(2) == 1 and true or false

        -- solid color we'll use if we're not alternating
        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(0, highestTier)
        for x = 1, numCols do

            if skipPattern and skipFlag then
                skipFlag = not skipFlag
                goto continue
            else
                skipFlag = not skipFlag
            end
            b = Brick((x - 1) * 32 + horizontalOffset, y * 16)

            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end
            table.insert(bricks, b)

            ::continue::
        end
    end

    if #bricks == 0 then
        return self.createMap(level)
    else
        return bricks
    end
end