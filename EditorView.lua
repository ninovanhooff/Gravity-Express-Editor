---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 17/08/2022 22:17
---

require("checkerboard")
require("specialsView")


local floor = math.floor
local min = math.min
local gfx  = love.graphics
local sideBarWidth = 100

--- render a row of bricks, brute force, fail safe
function renderLineHoriz(i,j, drawOffsetY)
    local startI = i
    local endI = min(levelProps.sizeX, camPos[1] + editorSizeX())
    while i<=endI do
        local curBrick = brickT[i]
        if not curBrick then
            break
        end
        curBrick = curBrick[j]
        if not curBrick then
            break
        end

        if curBrick[1]>1 then
            if curBrick[1]>=7 then --concrete
                drawSprite(
                    (i -startI) * 8, drawOffsetY,
                    _,
                    240+curBrick[2]*curBrick[3]*8,
                    greySumT[curBrick[3]]+curBrick[5]*8,
                    8*(curBrick[3]-curBrick[4]),
                    8*(curBrick[3]-curBrick[5])
                )
                i = i + curBrick[3]-curBrick[4]
            elseif curBrick[1]>=3 then --color
                drawSprite(
                    (i -startI) * 8, drawOffsetY,
                    _,
                    (curBrick[1]-3)*48+sumT[curBrick[2]]+curBrick[4]*8,
                    sumT[curBrick[3]]+curBrick[5]*8,
                    (curBrick[2]-curBrick[4])*8,
                    (curBrick[3]-curBrick[5])*8
                )
                i = i + curBrick[2]-curBrick[4]
            elseif curBrick[1]==2 then --collision occupied
                fillRect(
                    (i -startI) * 8,
                    drawOffsetY,
                    (curBrick[2]-curBrick[4])*8,
                    tileSize,
                    red
                )
                i = i + curBrick[2]-curBrick[4]
            end
        else
            i = i + curBrick[2]-curBrick[4]
        end

    end
end

function drawBricks()
    for y = camPos[2], levelProps.sizeY do
        renderLineHoriz(camPos[1], y, (y - camPos[2])*tileSize)
    end
end

function drawEditor()
    fillCheckerBoard()

    drawSpecials(camPos)
    drawBricks()
    if not love.keyboard.isDown('up', 'down', 'left', 'right') then
        love.timer.sleep(0.1)
    end
    -- brush cursor
    drawBrush()
end
