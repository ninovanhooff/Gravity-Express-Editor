---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 13/05/2022 16:58
---

local bit32 = require("bit")
local unpack = love.data.unpack
local random = love.math.random
local ceil = math.ceil
local max = math.max
local renderProgress = print
local curX, curY = 1,1
local camPos = {1,1,0,0}
local blockNames = {"Red","Yellow","Blue","Green","Grey","Platform","Blower","Magnet","Rotator","Cannon","Rod","1-way","Barrier"}
local levelProps = {}

local fileName = "LEVEL01.CGL"

local units_in_block = 8

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

function love.draw()
    --print("Frame-----")
    local numDraws = 0
    local brickT = brickT
    local quad, width, height, srcX, sizeOffsetX, sizeOffsetY
    local x,y = 1,1
    while x < levelProps.sizeX do
        y = 1
        while y < levelProps.sizeY do
            curBrick = brickT[x][y]
            if curBrick[1] ~= 0 and curBrick[4] == 0 and curBrick[5] == 0 then
                --print("Drawing ", curBrick[1])
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
                --todo creating quads has terrible performance
                quad = love.graphics.newQuad(srcX, sizeOffsetY, width, height, sprite:getWidth(), sprite:getHeight())
                love.graphics.draw(sprite, quad, (x-camPos[1])*8, (y-camPos[2])*8)
            end
            y = y + curBrick[3]-curBrick[5]
        end
        x = x + 1
    end
    --print("---- numDraws", numDraws)
end

local function assertHeader(self, name)
    print(name)
    local magicOrHeader = self:read(4)
    if(magicOrHeader == name) then return end
    assert(self:read(4) == name)
end

local function readInt(self, amount, bytesPerInt)
    result = {}
    if amount < 1 then
        return result
    end
    for i = 1,amount do
        result[i] = unpack("<I"..bytesPerInt, self:read(bytesPerInt))
    end
    return result
end

-- split a byte into first and second unsigned 4-bit numbers
local function splitByte(byte)
   return {
       bit32.rshift(byte, 4),
       bit32.band(byte, 15) -- mask lowest 4 bits
   }
end

--- parameters in CG units (1 unit = 4px)
local function geBrickType(cgGfxX, cgGfxY)
    if cgGfxX< 0 or cgGfxY<0 or cgGfxX > 108 or cgGfxY > 15 then
        print(cgGfxX, cgGfxY)
        error("outside brick range")
    end
    if cgGfxX < 15 then
        return 3 -- red a.k.a. brown
    elseif cgGfxX < 30 then
        return 4 -- yellow
    elseif cgGfxX < 45 then
        return 5 -- blue
    elseif cgGfxX < 60 then
        return 6 -- green
    else
        return 7 -- concrete
    end
end

local function brushContains(k, l, brush)
    --printf("contains?",k,l)
    for i,item in pairs(brush) do
        if item[1]==k and item[2]==l then
            return true
        end
    end
    return false
end


local function optimizeEmptySpace()
    for i=1,levelProps.sizeX do
        local lastJ = -1
        for j=levelProps.sizeY,1,-1 do
            if brickT[i][j][1]<3 and j>1 then -- empty space
                if lastJ==-1 then
                    lastJ = j
                end
            else -- always for j==1
                if lastJ~=-1 then
                    for k=j+1,lastJ do
                        --brickT[i][k][4]=lastJ-j
                        brickT[i][k][3]=lastJ-j -- h
                        brickT[i][k][5]=k-(j+1)
                    end
                    lastJ=-1
                end
            end
        end
    end
end

--- weighted bricksize, where larger bricks are more likely, returns 0-based size
local function randomBrickSize()
    local value = random()
    if value < 0.2 then
        return 0
    elseif value < 0.6 then
        return 1
    else
        return 2
    end
end

local function fillBrush(forceSize, brush, percentProgress)
    print("START FILL", curX, curY)
    brush = brush or curBrush
    local fillCount = 0
    for i,item in ipairs(brush) do
        --item = brush[1]
        --printf("brusht",item[1],item[2])
        if brickT[curX+item[1]][curY+item[2]][1]==0 then -- if the first square is empty, double check?
            local tryWidth = forceSize or randomBrickSize()
            local tryHeight = forceSize or randomBrickSize()
            print("try", tryWidth, tryHeight)
            local maxW = tryWidth -- zero based!
            local maxH = tryHeight
            --printf("tries",maxW,maxH)
            for k=0,tryWidth do
                for l=0,tryHeight do
                    --[[if not BrushContains(item[1]+k,item[2]+l,brush) then
                        printf("failed brush bounds",k,l)
                        --constrK,constrL = BrushLimit(item[1]+k,item[2]+l)
                        maxW = math.fmin(maxW,k-1)--+constrK)
                        maxH = math.fmin(maxH,l-1)--+constrL)
                        --printf("new minima",maxW,maxH)
                        break]]
                    if not brushContains(item[1]+k,item[2]+l,brush) or brickT[curX+item[1]+k][curY+item[2]+l][1]~=0 then --curX+item[1]+k+1<levelProps.sizeX and curX+item[1]+k+1<levelProps.sizeY
                        --printf("fail: occupied",item[1],k,item[2],l)
                        if l==0 then
                            maxW = math.min(maxW,k-1)
                        else
                            maxH = math.min(maxH,l-1)
                        end
                        break
                    end
                end
            end
            if maxW<0 then maxW=0 end
            if maxH<0 then maxH=0 end
            --printf(item[1],item[2],"maxWH",maxW,maxH)
            for k=0,maxW do -- now fill it
                for l=0,maxH do
                    brickT[curX+item[1]+k][curY+item[2]+l] = {selBrickType,maxW+1,maxH+1,k,l} -- max is 1-based here!!
                    --	printf(selBrickType,maxW,maxH,k,l)
                    --if k==0 and l==0 then printf("fill",maxW,maxH) end
                end
            end
            fillCount = fillCount+1
            if math.fmod(fillCount,20)==19 then
                renderProgress(editorStatusMsg,i/#brush)
            end
            --printf("endfill")
        end
    end
end

local function emptyBrush(brush)
    brush = brush or curBrush
    for i,item in pairs(brush) do
        local curBrick = brickT[curX+item[1]][curY+item[2]]
        if curBrick[1]>2 then -- if the  square is not empty
            if curBrick[1]==7 then
                kmax = curBrick[3]-1-curBrick[4]
                lmax = curBrick[3]-1-curBrick[5]
            else
                kmax = curBrick[2]-1-curBrick[4]
                lmax = curBrick[3]-1-curBrick[5]
            end
            for k = 0-curBrick[4],kmax do
                for l = 0-curBrick[5],lmax do
                    brickT[curX+item[1]+k][curY+item[2]+l] = {0,1,1,0,0}
                end
            end
        end
    end
end

local function condenseBricks()
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
                    print("insert",i,j)
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

local function createBrickT(cgSizeInBlocks, sobs)
    -- cg blocks are 32x32 pixels, eg tiles are 8x8. So, multiply by 4 to get the same dimensions
    local geSizeX = cgSizeInBlocks[1] * 4
    local geSizeY = cgSizeInBlocks[2] * 4
    local brickT = {}
    local floor = math.floor

    local function concreteLast(a, b)
        -- by processing concrete last, we make sure colored bricks don't overlap concrete
        return a[5] < b[5]
    end
    table.sort(sobs, concreteLast)

    -- initialize empty brickT
    for x = 1, geSizeX do
        brickT[x] = {}
        for y = 1, geSizeY do
            brickT[x][y] = {0,1,1,0,0} -- type,w,h,subx,suby
        end
    end

    print("brickT dim", #brickT, #brickT[1])


    local curBrick, curBrickX, curBrickY, curBrickType
    for _,sob in ipairs(sobs) do
        curBrickX = floor(sob[1]/2) + 1
        curBrickY = floor(sob[2]/2) + 1
        curBrick = brickT[curBrickX][curBrickY]
        curBrickType = geBrickType(sob[5], sob[6])
        curBrick[1] = curBrickType
        if curBrick[1] == 7 then
            -- concrete; set width and height
            local concreteSize = sob[4]/2
            local pattern = math.ceil(random(0, greyVariations[concreteSize])) -- pattern
            curBrick[2] = pattern
            curBrick[3] = concreteSize -- size
            for x = 0, concreteSize-1 do
                for y = 0, concreteSize-1 do
                    brickT[curBrickX+x][curBrickY+y] = {
                        curBrickType,
                        pattern, concreteSize,
                        x,y
                    }
                end
            end
        else
            local width = ceil(sob[3]/2) -- todo floor seems too conservative, ceil overwrites concrete blocks
            local height = ceil(sob[4]/2)
            print("color", width, height)
            -- color
            for x = 0, width-1 do
                for y = 0, height-1 do
                    brickT[curBrickX+x][curBrickY+y] = {
                        curBrickType,
                        1,1,
                        0,0
                    }

                end
            end
        end
    end

    return brickT
end

function love.load()
    love.keyboard.setKeyRepeat( true )
    brickT = {}
    sprite = love.graphics.newImage("sprite.png")


    local fp = io.open(fileName, "rb")

    print("file", fp, type(fp))

    -- file header
    assertHeader(fp, "CGL1")

    assertHeader(fp, "SIZE")
    local size = readInt(fp, 2, 4)
    inspect(size)

    assertHeader(fp, "SOIN")
    local soin = readInt(fp, size[1]*size[2], 1)
    for i,item in ipairs(soin) do
        soin[i] = bit32.band(item, 127) -- ignore most significant bit
    end numSobs = table.sum(soin)

    assertHeader(fp, "SOBS")
    local sobs = {}

    local x,y = 1,1
    local blockOffX = 0
    local blockOffY = 0
    local tile, posInBlock, tileDim
    for i = 1, #soin do
        blockOffX = (x-1) * units_in_block
        blockOffY = (y-1) * units_in_block
        for _ = 1, soin[i] do
            tile = readInt(fp, 4, 1)
            posInBlock = splitByte(tile[1])
            tileDim = splitByte(tile[2])

            table.insert(sobs, {
                blockOffX+posInBlock[1],
                blockOffY+posInBlock[2],
                tileDim[1],
                tileDim[2],
                tile[4], -- gfx x. In the level, they are swapped
                tile[3] -- gfx y
            })
        end
        x = x + 1
        if x > size[1] then
            -- go to next row
            x = 1
            y = y + 1
        end
    end

    print("numsobs", numSobs, #sobs)
    brickT = createBrickT(size, sobs)
    levelProps.sizeX = #brickT
    levelProps.sizeY = #brickT[1]
    condenseBricks()

    for i,item in ipairs(brickT) do
        for j,jtem in ipairs(item) do
            if jtem[1] == 3 and jtem[4] == 0 and jtem[5] == 0 then
                print("-- ", i, j)
                inspect(jtem)
            end
        end
    end

    local displayIdx = 2
    love.window.setMode( size[1]*32,size[2]*32, {display=displayIdx, resizable = true, x=1, y=1} )


    --assertHeader(fp, "VENT")
    --local numFans = readInt(fp, 1, 4)[1]
    --print("numFans", numFans)
    --readInt(fp, numFans * 38, 1)
    --
    --assertHeader(fp, "MAGN")
    --local numMagnets = readInt(fp, 1, 4)[1]
    --print("numMagnets", numMagnets)
    --readInt(fp, numMagnets * 38, 1)
    --
    --assertHeader(fp, "DIST")
    --local numRotators = readInt(fp, 1, 4)[1]
    --print("numRotators", numRotators)
    --readInt(fp, numRotators * 38, 1)
    --
    --assertHeader(fp, "CANO")
    --local numCannons = readInt(fp, 1, 4)[1]
    --print("numCannons", numCannons)
    --readInt(fp, numCannons * 51, 1)
    --
    --assertHeader(fp, "PIPE")
    --local numRods = readInt(fp, 1, 4)[1]
    --print("numRods", numRods)
    --readInt(fp, numRods * 38, 1)
    --
    --assertHeader(fp, "ONEW")
    --local numOneWays = readInt(fp, 1, 4)[1]
    --print("numOneWays", numOneWays)
    --readInt(fp, numOneWays * 38, 1)
    --
    --assertHeader(fp, "BARR")
    --local numBarriers = readInt(fp, 1, 4)[1]
    --print("numBarriers", numBarriers)
    --readInt(fp, numBarriers * 38, 1)
    

    --love.event.quit()

end

function love.keypressed(key, _, _)
    if key == "right" then
        camPos[1] = camPos[1] + 1
    elseif key == "down" then
        camPos[2] = camPos[2] + 1
    end
end
