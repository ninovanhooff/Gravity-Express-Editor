---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/06/2022 18:57
---

require("selection")

local DIR_UP = 1
local DIR_DOWN = 2
local DIR_LEFT = 3
local DIR_RIGHT = 4

local function markOccupied(item, coords)
    clearSelection(rectSelection(
        item.x+coords[1],
        item.y+coords[2],
        coords[3],
        coords[4]
    ), true)
end

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
                else
                    -- print("non-empty:", curBrick[1])
                end
            end
        end
    else
        -- print("sample test failed")
    end
end

local function repairPlatform(item)
    -- if the entire bottom row of tiles is non-empty, move the platform up
    local curBrick
    local overlap = true -- will be set to false
    for x = item.x, item.x + item.w - 1 do
        curBrick = table.deepGet(brickT, x, item.y + 5)
        if not curBrick then
            return
        end
        if curBrick[1] == 0 then
            overlap = false
            break
        end
    end
    if overlap then
        item.y = item.y -1
    end
end

local function repairBlower(item)
    local coords = {}
    if item.direction==1 then
        coords = {0,item.distance,6,8}
    elseif item.direction==2 then
        coords = {0,0,6,8}
    elseif item.direction==3 then
        coords = {item.distance,0,8,6}
    else
        coords = {0,0,8,6}
    end
    markOccupied(item,coords)
end

local function repairMagnet(item)
    local coords = {}
    if item.direction==1 then
        coords = {0,item.distance,4,6}
    elseif item.direction==2 then
        coords = {0,0,4,6}
    elseif item.direction==3 then
        coords = {item.distance,0,6,4}
    else
        coords = {0,0,6,4}
    end
    markOccupied(item, coords)
end

local function repairRotator(item)
    local coords = {}
    if item.direction==1 then
        coords = {0,item.distance,5,8}
    elseif item.direction==2 then
        coords = {0,0,5,8}
    elseif item.direction==3 then
        coords = {item.distance,0,8,5}
    else
        coords = {0,0,8,5}
    end
    markOccupied(item,coords)
end

local function repairCannon(item)
    local direction = item.direction
    if direction == DIR_UP or direction == DIR_DOWN then
        if direction == DIR_UP then
            clearSelection(rectSelection(item.x,item.y, 3,3), true) -- receiver
            clearSelection(rectSelection(item.x,item.y+item.h-5, 3,5), true) -- emitter
            -- fill holes bottom-left emitter
            fillBrickFromSample(
                item.x - 2, item.y + item.h - 3,
                item.x - 1, item.y + item.h - 3,
                1, 3
            )
        else
            clearSelection(rectSelection(item.x,item.y, 3,5), true) -- emitter
            clearSelection(rectSelection(item.x,item.y+item.h-3, 3,3), true) -- receiver
        end
        clearSelection(rectSelection(item.x+1, item.y, 1, item.h)) -- cannon ball travel path
    else -- horizontal
        if direction == DIR_RIGHT then
            clearSelection(rectSelection(item.x,item.y, 5,3), true) -- emitter
            clearSelection(rectSelection(item.x+item.w-3,item.y, 3,3), true) -- receiver
        else -- DIR_LEFT
            clearSelection(rectSelection(item.x,item.y, 3,3), true) -- receiver
            clearSelection(rectSelection(item.x+item.w-5,item.y, 5,3), true) -- emitter
            -- fill holes bottom-right emitter
            fillBrickFromSample(
                item.x + item.w - 3, item.y -2,
                item.x +item.w -3, item.y + - 1,
                3, 1
            )
        end
        clearSelection(rectSelection(item.x, item.y+1, item.w, 1)) -- cannon ball travel path
    end
end

local function setCollisionBarrier(item)
    if item.direction== DIR_UP then
        for i=0,5 do
            for j=0,3 do
                if not (j>1 and i>3) then
                    brickT[item.x+i][item.y+j+item.distance]={2,1,1,0,0} -- collision occupied
                end
            end
        end
        if item.endStone==1 then
            for i = 1,4 do
                for j =0,1 do
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
    elseif item.direction==DIR_DOWN then
        for i=0,5 do
            for j=0,3 do
                if i>1 or j>1 then
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
        if item.endStone==1 then
            for i = 1,4 do
                for j =4+item.distance-2,4+item.distance-1 do
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
    elseif item.direction==DIR_LEFT then
        for i=0,3 do
            for j=0,5 do
                if not (i>1 and j<2) then
                    brickT[item.x+i+item.distance][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
        if item.endStone==1 then
            for i=0,1 do
                for j=1,4 do
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
    else -- DIR_RIGHT
        for i=0,3 do
            for j=0,5 do
                if not (i<2 and j>3) then
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
        if item.endStone==1 then
            for i=4+item.distance-2,4+item.distance-1 do
                for j=1,4 do
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
    end
end

local function repairRod(item)
    if item.direction==1 then -- horiz
        clearSelection(rectSelection(item.x,item.y, 3,3), true)
        clearSelection(rectSelection(item.x+item.distance,item.y,3,3), true)
        clearSelection(rectSelection(item.x+3,item.y,item.distance,3), false) -- clear rod path
    elseif item.direction==2 then -- vert
        clearSelection(rectSelection(item.x, item.y,3,3), true)
        clearSelection(rectSelection(item.x,item.y+item.distance,3,3), true)
        clearSelection(rectSelection(item.x,item.y+3,3,item.distance), false) -- clear rod path
    end
end

local function setCollision1Way(item)
    if item.direction==1 then
        for i=0,11 do
            for j=0,3 do
                if not (j>1 and i>3 and i<8) then
                    brickT[item.x+i][item.y+j+item.distance]={2,1,1,0,0} -- collision occupied
                end
            end
        end
        if item.endStone==1 then
            for i = 4,7 do
                for j =0,1 do
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
    elseif item.direction==2 then
        for i=0,11 do
            for j=0,3 do
                if not (j<2 and i>3 and i<8) then
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
        if item.endStone==1 then
            for i = 4,7 do
                for j =4+item.distance-2,4+item.distance-1 do
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
    elseif item.direction==3 then
        for i=0,3 do
            for j=0,11 do
                if not (i>1 and j>3 and j<8) then
                    brickT[item.x+i+item.distance][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
        if item.endStone==1 then
            for i=0,1 do
                for j=4,7 do
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
    else -- direction is right
        for i=0,3 do
            for j=0,11 do
                if not (i<2 and j>3 and j<8) then
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
        if item.endStone==1 then
            for i=4+item.distance-2,4+item.distance-1 do
                for j=4,7 do
                    brickT[item.x+i][item.y+j]={2,1,1,0,0} -- collision occupied
                end
            end
        end
    end
end

local function repair1Way(item)
    local direction = item.direction
    if direction == DIR_UP then
        if isEmpty(rectSelection(item.x,item.y+item.h,4,1)) then
            item.distance = item.distance + 1
            item.h = item.h + 1
            item.pos = item.pos + tileSize
        end
    elseif direction == DIR_DOWN then

    elseif direction == DIR_LEFT then
        if isEmpty(rectSelection(item.x+item.w,item.y,1,4)) then
            item.distance = item.distance + 1
            item.w = item.w + 1
            item.pos = item.pos + tileSize
        end
    elseif direction == DIR_RIGHT then

    end
    setCollision1Way(item)
end

local function repairBarrier(item)
    local direction = item.direction
    if direction == DIR_UP then
        fillBrickFromSample(
            item.x + 7, item.y + item.h - 4,
            item.x + 6, item.y + item.h - 4,
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
            item.x + item.w - 4, item.y + 7,
            item.x + item.w - 4, item.y + 6,
            4, 1
        )
        if item.endStone == 1 then
            -- bottom endStone
            fillBrickFromSample(
                item.x, item.y + item.h,
                item.x, item.y + item.h - 1,
                2, 1
            )
        end
    elseif direction == DIR_RIGHT then
        -- base
        fillBrickFromSample(
            item.x + 2, item.y + 7,
            item.x + 2, item.y + 6,
            2, 1
        )
        if item.endStone == 1 then
            -- bottom endStone
            fillBrickFromSample(
                item.x + item.w - 1, item.y + item.h,
                item.x + item.w - 2, item.y + item.h - 1,
                2, 1
            )
        end
    end
    setCollisionBarrier(item)
end

local specialRepairs = {
    [8] = repairPlatform,
    [9] = repairBlower,
    [10] = repairMagnet,
    [11] = repairRotator,
    [12] = repairCannon,
    [13] = repairRod,
    [14] = repair1Way,
    [15] = repairBarrier
}

function repairSpecials()
    print("--- repairSpecials")
    for _, item in ipairs(specialT) do
        local repairFun = specialRepairs[item.sType]
        if repairFun then
            repairFun(item)
        end
    end
end
