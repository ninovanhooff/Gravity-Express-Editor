---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 13/05/2022 16:58
---

------ Name without extension
require("cglReader")
require("util")
require("drawutil")
require("specialsView")
require("specialsRepair")
require("brush")
require("serialize")

--- width/height in pixels of a single Gravity Express tile
tileSize = 8
gfxEnabled = true -- when false, no image displayed, but written to file. Useful for commandline-usage
editorMode = true
condenseEnabled = true
curX, curY = 1,1
white = {1,1,1} -- rgb
yellow = {1,1,0} -- rgb
purple = {1,0,1} -- rgb

local camPos = {1,1,0,0}
local blockNames = {"Red","Yellow","Blue","Green","Grey","Platform","Blower","Magnet","Rotator","Cannon","Rod","1-way","Barrier"}
local canvas

-- barrier key color names
colorT = {"red","green","blue","yellow"}
keys = {true,true,true,true} -- make the barrier colors always lit
-- brickT constants
sumT = {0,8,24}
greySumT = {-1,56,32,0} -- -1:unused
greyVariations = {-1, 11, 7 , 5}

function inspect(tbl)
    for i,item in pairs(tbl) do
        print(i,item)
    end
end

function table.sum(tbl)
    local sum = 0
    for i,item in pairs(tbl) do
        sum = sum + item
    end
    return sum
end

local function drawBricks()
    local numDraws = 0
    local brickT = brickT
    local x,y = 1,1
    while x < levelProps.sizeX do
        y = 1
        while y < levelProps.sizeY do
            curBrick = brickT[x][y]
            if curBrick[1] > 2 and curBrick[4] == 0 and curBrick[5] == 0 then
                numDraws = numDraws + 1
                height = curBrick[3] * 8
                if curBrick[1] == 7 then
                    width = curBrick[3] * 8
                    srcX = 240 + curBrick[2]*curBrick[3]*8
                    sizeOffsetX = greySumT[curBrick[3]]
                    sizeOffsetY = greySumT[curBrick[3]]
                else
                    width = curBrick[2] * 8
                    sizeOffsetX = sumT[curBrick[2]]
                    sizeOffsetY = sumT[curBrick[3]]
                    srcX = (curBrick[1] - 3) * 48 + sizeOffsetX
                end
                drawSprite((x-camPos[1])*8, (y-camPos[2])*8, _, srcX, sizeOffsetY, width, height)
            end
            y = y + curBrick[3]-curBrick[5]
        end
        x = x + 1
    end
end

function love.draw()
    drawSpecials(camPos)
    drawBricks()
end

--- replace all non-cencrete bricks by 1x1 tiles, including empty space
--- in other words, keep only the type([1]), and set sizing values to 1,1,0,0
local function unOptimize()
    print("--- unOptimizing")
    for _, xTem in ipairs(brickT) do
        for y, yTem in ipairs(xTem) do
            if yTem[1] < 7 then
                xTem[y] = {yTem[1], 1, 1, 0, 0}
            end
        end
    end
end

local function optimizeEmptySpace()
    print("--- optimizing empty space")
    for i=1,levelProps.sizeX do
        local lastJ = -1
        for j=levelProps.sizeY,1,-1 do -- traverse column BACKWARDS
            if brickT[i][j][1]<3 and j>1 and (lastJ == -1 or lastJ - j < 255) then -- empty space with max height of 254
                if lastJ==-1 then
                    lastJ = j -- set END y of empty space
                end
            else -- always for j==1
                if lastJ~=-1 then
                    for k=j+1,lastJ do
                        --brickT[i][k][4]=lastJ-j
                        brickT[i][k][3]=lastJ-j -- h
                        brickT[i][k][5]=k-(j+1) -- cur Y sub index. 0-based
                    end
                    lastJ=-1
                end
            end

        end
    end
    -- todo horizontal direction too? then maybe we need purely column / row based drawing. not the "fast" approach
end

local function condenseBricks()
    print("--- condensing bricks")
    --local brickTypeBU = selBrickType
    --xBU,yBU,curX,curY = curX,curY,1,1
    for color = 3,6 do
        editorStatusMsg = "Compacting "..blockNames[color-2].."s..."
        condenseBrush = {}
        --add all 1x1 of color
        for i = 1,levelProps.sizeX do
            for j = 1,levelProps.sizeY do
                local curBrick = brickT[i][j]
                if curBrick[1]==color and curBrick[2]==1 and curBrick[3]==1 then
                    table.insert(condenseBrush,{i-1,j-1})
                end
                curBrick = nil
            end
        end
        emptyBrush(condenseBrush)
        selBrickType = color
        fillBrush(nil,condenseBrush,true) -- todo use no forcesize but random
    end
    --selBrickType = brickTypeBU
    --curX,curY = xBU,yBU
    --brickTypeBU = nil
    editorStatusMsg = "Compacting done"
    --RenderEditor()
end

function love.load(args)
    love.keyboard.setKeyRepeat( true )
    sprite = love.graphics.newImage("sprite.png")
    frameCounter = 0

    local fileName = args[1]
    print("Filename", fileName)

    -- READ INPUT FILE from args
    if args[2] == "lua" then
        print("Reading Gravity Express format")
        local levelT = require("lua-levels/" .. fileName)
        specialT = levelT.specialT
        levelProps = levelT.levelProps
        brickT = levelT.brickT
        unOptimize()
    else
        print("Converting cgl + intermediate lua result from cgl reader")
        levelT = require("intermediates/" .. fileName .. "_intermediate")
        specialT = levelT.specialT
        levelProps = levelT.levelProps
        brickT = {}

        brickT = readCglBrickT(fileName)
        unOptimize()

        assert(levelProps.sizeX == #brickT, "Level width does not match beteen CGL and lua files!")
        assert(levelProps.sizeY == #brickT[1], "Level height does not match beteen CGL and lua files!")
        repairSpecials()
    end

    if condenseEnabled then
        condenseBricks()
    end
    optimizeEmptySpace()

    gameWidthTiles, gameHeightTiles = levelProps.sizeX, levelProps.sizeY

    table.compress(brickT)

    -- FILE WRITE
    local luaFilePath = "lua-levels/" .. fileName .. ".lua"
    print("--- writing ".. luaFilePath)
    writeLua(luaFilePath, {
        levelProps = levelProps,
        specialT = specialT
    })

    writeBrickT("lua-levels/" .. fileName .. ".bin", brickT)

    -- IMAGE OUT
    if gfxEnabled then
        local displayIdx = 2
        love.window.setMode(levelProps.sizeX*tileSize,levelProps.sizeY*tileSize, {display=displayIdx, resizable = true, x=1, y=1} )
        love.window.setPosition(20,20, displayIdx)
    else
        canvas = love.graphics.newCanvas(levelProps.sizeX*tileSize,levelProps.sizeY*tileSize)
        love.graphics.setCanvas(canvas)
        --print("Frame-----")
        drawBricks()
        drawSpecials(camPos)
        --print("---- numDraws", numDraws)
        love.graphics.setCanvas()

        love.filesystem.setIdentity( "GravityExpressEditor" )
        canvas:newImageData():encode("png",fileName .. ".png")
        love.event.quit()
    end

end

function love.keypressed(key, _, _)
    if key == "left" and camPos[1] > 1 then
        camPos[1] = camPos[1] - 1
    elseif key == "up" and camPos[2] > 1 then
        camPos[2] = camPos[2] - 1
    elseif key == "right" then
        camPos[1] = camPos[1] + 1
    elseif key == "down" then
        camPos[2] = camPos[2] + 1
    end
end
