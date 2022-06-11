---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/06/2022 18:57
---

require("brush")

local DIR_UP = 1
local DIR_DOWN = 2
local DIR_LEFT = 3
local DIR_RIGHT = 4

local function fillBrickFromSample(sampleX, sampleY, startX, startY, w, h)
    local sample = table.deepGet(brickT, sampleX, sampleY)
    if sample == nil then
        return
    end

    if sample[1] >= 3 and sample[1] < 7 then
        for x = startX, startX + w - 1 do
            for y = startY, startY + h - 1 do
                local curBrick = table.deepGet(brickT, x, y)
                if curBrick and curBrick[1] == 0 then
                    brickT[x][y] = { sample[1], 1, 1, 0, 0 } -- 1x1 brick of sampled color
                end
            end
        end
    end
end

local function repairPlatform(item)
    -- if the entire bottom row of tiles is non-empty, move the platform up
    local curBrick
    local overlap = true -- will be set to false
    for x = item.x, item.x + item.w - 1 do
        curBrick = table.deepGet(brickT, x, item.y + 5)
        if curBrick[1] == 0 then
            overlap = false
            break
        end
    end
    if overlap then
        item.y = item.y -1
    end
end

local function repairBarrier(item)
    local direction = item.direction
    if direction == DIR_UP then
        fillBrickFromSample(
            item.x + 7, item.y + item.h - 6,
            item.x + 6, item.y + item.h - 6,
            1, 2
        )
    elseif direction == DIR_DOWN then
            fillBrickFromSample(
                item.x + 7, item.y,
                item.x + 6, item.y,
                1, 4
            )
    elseif direction == DIR_LEFT then
            fillBrickFromSample(
                item.x + item.w - 6, item.y + 7,
                item.x + item.w - 6, item.y + 6,
                4, 1
            )
    elseif direction == DIR_RIGHT then
            fillBrickFromSample(
                item.x + 2, item.y + 7,
                item.x + 2, item.y + 6,
                2, 1
            )
        end
    end


    local specialRepairs = {
        [8] = repairPlatform,
        [15] = repairBarrier
    }

    function repairSpecials()
        for _, item in ipairs(specialT) do
            local repairFun = specialRepairs[item.sType]
            if repairFun then
                repairFun(item)
            end
        end
    end
