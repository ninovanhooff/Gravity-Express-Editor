--- Reads brickT data from CGL1 (Crazy Gravity) binary files
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 19/06/2022 15:54
---

local unpack = love.data.unpack
local bit32 = require("bit")
local random = love.math.random
local ceil = math.ceil

local units_in_block = 8

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
            local width = ceil(sob[3]/2)
            local height = ceil(sob[4]/2)
            -- color
            for x = 0, width-1 do
                for y = 0, height-1 do
                    local curBrick = {
                        curBrickType,
                        1,1,
                        0,0
                    }
                    brickT[curBrickX+x][curBrickY+y] = curBrick
                end
            end
        end
    end

    return brickT
end


function readCglBrickT(fileName)
    local fp = io.open("test-levels/" .. fileName .. ".CGL", "rb")

    if not fp then
        error("file not found:" .. fileName)
    end

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

    return createBrickT(size, sobs)
end