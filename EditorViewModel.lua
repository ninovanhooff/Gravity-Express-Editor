---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 18/08/2022 22:56
---

require("object")


local mouse = love.mouse
local floor = math.floor
local min = math.min
sideBarWidth = 100

class("EditorViewModel").extends()

-- global singleton
if not editorViewModel then
    editorViewModel = EditorViewModel()
end

function EditorViewModel:init()
    EditorViewModel.super.init()
end

function EditorViewModel:update()
    if love.mouse.isDown(1) then
        fillBrush()
    elseif love.mouse.isDown(2) then
        emptyBrush()
    end

    if love.mouse.isDown(3) then -- middle mouse button
        if not self.isPanning then
            self.panStart = {
                mouseX = love.mouse.getX(),
                mouseY = love.mouse.getY(),
                camX = camPos[1],
                camY = camPos[2]
            }
            self.isPanning = true
        else
            local panX = floor((mouse.getX() - self.panStart.mouseX)/tileSize)
            local panY = floor((mouse.getY() - self.panStart.mouseY)/tileSize)
            camPos[1] = self.panStart.camX - panX
            camPos[2] = self.panStart.camY - panY
        end
    else
        if self.isPanning then
            self.isPanning = false
        else
            curX = (floor(love.mouse.getX() / tileSize - brushSize/2)) + camPos[1]
            curY = (floor(love.mouse.getY() / tileSize - brushSize/2)) + camPos[2]
        end
    end

    checkX()
    checkY()
end

function editorSizeX()
    -- reserve width for side
    local width = love.window.getMode() --- first return value is width
    return floor((width - sideBarWidth)/tileSize)
end

function editorSizeY()
    local _,height = love.window.getMode() --- first return value is width
    return floor(height/tileSize)
end

function checkX() --whether curX and camPos[1] are in bounds
    local editorSizeX = editorSizeX()

    camPos[1] = lume.clamp(camPos[1], 1, levelProps.sizeX - editorSizeX)

    if curX<1 then curX=1 end
    if camPos[1]<1 then camPos[1]=1 end

    if curX<camPos[1] then curX = camPos[1] end
    if curX>=levelProps.sizeX-brushSize then
        curX = levelProps.sizeX-brushSize+1
    end

end

function checkY()
    local editorSizeY = editorSizeY()

    camPos[2] = lume.clamp(camPos[2], 1, levelProps.sizeY - editorSizeY)

    if curY<1 then curY=1 end
    if camPos[2]<1 then camPos[2]=1 end

    if curY<camPos[2] then curY = camPos[2] end
    if curY>=levelProps.sizeY-brushSize then
        curY = levelProps.sizeY-brushSize+1
    end
end

--function checkY()
--    local editorSizeY = editorSizeY()
--
--    if curY<1 then curY = 1 end
--    if camPos[2]<1 then camPos[2] = 1 end
--
--    if curY>=levelProps.sizeY-brushSize then
--        curY = levelProps.sizeY-brushSize+1
--    end
--    if curY<camPos[2] then curY = camPos[2] end
--    if camPos[2]+editorSizeY -1>levelProps.sizeY or curY+brushSize>camPos[2]+editorSizeY then
--        camPos[2] = curY+brushSize-editorSizeY
--    end
--end
