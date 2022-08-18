---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 13/05/2022 16:58
---

lume = require "lume"

------ Name without extension
require("cglBrickReader")
require("util")
require("drawutil")
require("specialsView")
require("specialsRepair")
require("brush")
require("levelGenerator")
require("EditorView")
require("serialize")

local floor = math.floor

--- width/height in pixels of a single Gravity Express tile
tileSize = 8
gfxEnabled = true -- when false, no image displayed, but written to file. Useful for commandline-usage
editorMode = true
condenseEnabled = false
curX, curY = 1,1
white = {1,1,1} -- rgb
yellow = {1,1,0} -- rgb
purple = {1,0,1} -- rgb
red = {1,0,0, 0.5} -- rgba

camPos = {1,1,0,0}
local blockNames = {"Red","Yellow","Blue","Green","Grey","Platform","Blower","Magnet","Rotator","Cannon","Rod","1-way","Barrier"}

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
    for _,item in pairs(tbl) do
        sum = sum + item
    end
    return sum
end

function love.draw()
    drawEditor()
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
        local lastBrickType = -1
        local lastJ = -1
        for j=levelProps.sizeY,1,-1 do -- traverse column BACKWARDS
            if lastBrickType == -1 and brickT[i][j][1] < 3 then
                lastBrickType = brickT[i][j][1]
            end
            if brickT[i][j][1] == lastBrickType and j>1 and (lastJ == -1 or lastJ - j < 255) then -- empty space with max height of 254
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
                    lastBrickType=-1
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

local function readBinaryBrickT(fileName)
    print("Reading brickT from bin file")
    local packFormat = levelProps.packFormat
    local packSize = love.data.getPackedSize(packFormat)
    local brickFile = io.open("lua-levels/"..fileName..".bin", "rb")
    local tile
    brickT = {}
    for x = 1, levelProps.sizeX do
        brickT[x] = {}
        for y = 1, levelProps.sizeY do
            tile = { love.data.unpack(packFormat, brickFile:read(packSize)) }
            table.remove(tile) -- remove the extra positional element returned by unpack
            brickT[x][y] = tile
        end
    end
end

function love.load(args)
    love.keyboard.setKeyRepeat( true )
    sprite = love.graphics.newImage("sprite.png")
    print("sprite", sprite)
    frameCounter = 0

    local fileName = args[1]
    print("Filename", fileName)

    -- READ INPUT FILE from args
    if not fileName then
        print("Creating new level")
        InitEditor(60,60)
        local displayIdx = 1
        love.window.setMode(levelProps.sizeX*tileSize,levelProps.sizeY*tileSize, {display=displayIdx, resizable = true, x=1, y=1} )
        love.window.setPosition(20,20, displayIdx)
    elseif args[2] == "lua" then
        print("Reading Gravity Express format")
        local levelT = require("lua-levels/" .. fileName)
        specialT = levelT.specialT
        levelProps = levelT.levelProps
        brickT = levelT.brickT
        if not brickT then
            readBinaryBrickT(fileName)
        else
            print("brickT read from lua file")
        end
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

    gameWidthTiles, gameHeightTiles = levelProps.sizeX, levelProps.sizeY

    if (fileName) then

        if condenseEnabled then
            condenseBricks()
        end
        optimizeEmptySpace()

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
        if not gfxEnabled then
            local canvas = love.graphics.newCanvas(levelProps.sizeX*tileSize,levelProps.sizeY*tileSize)
            love.graphics.setCanvas(canvas)
            --print("Frame-----")
            drawSpecials(camPos)
            drawBricks()
            --print("---- numDraws", numDraws)
            love.graphics.setCanvas()

            love.filesystem.setIdentity( "GravityExpressEditor" )
            canvas:newImageData():encode("png",fileName .. ".png")
            love.event.quit()
        end
    end

end

function love.update(dt)
    curX = (floor(love.mouse.getX() / tileSize - brushSize/2)) + camPos[1]
    curY = (floor(love.mouse.getY() / tileSize - brushSize/2)) + camPos[2]

    curX = lume.clamp(curX, 1, levelProps.sizeX - brushSize + 1)
    curY = lume.clamp(curY, 1, levelProps.sizeY - brushSize + 1)

    if love.mouse.isDown(1) then
        fillBrush()
    elseif love.mouse.isDown(2) then
        emptyBrush()
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
