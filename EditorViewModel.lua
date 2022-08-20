---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 18/08/2022 22:56
---

local mouse = love.mouse
local floor = math.floor
local min = math.min
local isDown = love.keyboard.isDown
local sign = lume.sign
local abs = math.abs

class("EditorViewModel").extends()

EditorViewModel.dragDirectionThreshold = 5

function EditorViewModel:init(fileName)
    self.fileName = fileName
    EditorViewModel.super.init()
end

-- may return menu specs to display
function EditorViewModel:update()
    -- keyboard events handled in keypressed

    if love.mouse.isDown(1) then
        local menuVM = self:applyBrush()
        if menuVM then return menuVM end
    elseif love.mouse.isDown(2) then
        if selBrickType < 8 then
            emptyBrush()
        else
            local curOidxx = SpecialCollision(curX,curY)
            if curOidxx then
                table.remove(specialT,curOidxx)
            end
        end
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
            self:updateCursorPosition()
        end
    end

    checkX()
    checkY()
end

--- update cursorPsition; optionally constraining to 8 cardinal directions
function EditorViewModel:updateCursorPosition()
    -- update cursor position
    local newX = (floor(love.mouse.getX() / tileSize - brushSize/2)) + camPos[1]
    local newY = (floor(love.mouse.getY() / tileSize - brushSize/2)) + camPos[2]

    if isDown("lshift", "rshift") then -- constrain to right angles
        if not self.dragStart then
            self.dragStart = {x = newX, y = newY, signX = 1, signY = 1}
        elseif not self.dragStart.directions then
            local dragDirectionThreshold = EditorViewModel.dragDirectionThreshold
            local dx, dy = newX - self.dragStart.x, newY - self.dragStart.y
            local xEligible = math.abs(dx) > dragDirectionThreshold
            local yEligible = math.abs(dy) > dragDirectionThreshold
            if xEligible then
                self.dragStart.majorAxis = "x"
                if math.abs(dy) >= dragDirectionThreshold /2 then
                    self.dragStart.directions = "xy"
                    if sign(dx) ~= sign(dy) then
                        self.dragStart.signY = -1
                    end
                else
                    self.dragStart.directions = "x"
                    self.dragStart.signX = 1
                end
            elseif yEligible then
                self.dragStart.majorAxis = "y"
                if math.abs(dx) >= dragDirectionThreshold /2 then
                    self.dragStart.directions = "xy"
                    if sign(dx) ~= sign(dy) then
                        self.dragStart.signX = -1
                    end
                else
                    self.dragStart.directions = "y"
                end
            end
        else
            local dx, dy = newX - self.dragStart.x, newY - self.dragStart.y
            local magnitude

            if self.dragStart.majorAxis == "x" then
                magnitude = dx
            else
                magnitude = dy
            end

            if self.dragStart.directions == "xy" then
                curX = self.dragStart.x + magnitude*self.dragStart.signX
                curY = self.dragStart.y + magnitude*self.dragStart.signY
            elseif self.dragStart.directions == "y" then
                curY = self.dragStart.y + magnitude*self.dragStart.signY
            else
                curX = self.dragStart.x + magnitude*self.dragStart.signX
            end
        end
    else
        self.dragStart = nil
        curX = newX
        curY = newY
    end
end

function EditorViewModel:wheelMoved(_,y)
    if y < 0 then
        -- decrease brush size
        if brushSize>1 and (selBrickType~=7 or brushSize>2) then
            brushSize = brushSize - 1
            if BrushType == CircleBrush then brushSize = brushSize-1 end
            if brushSize==0 then --circle brush
                curBrush = SquareBrush(1)
                brushSize = 1
                BrushType = CircleBrush
            else
                curBrush = BrushType(brushSize)
            end
            if curX>levelProps.sizeX-brushSize then
                curX = levelProps.sizeX-brushSize
            end

            if curY>levelProps.sizeY-brushSize then
                curY = levelProps.sizeY-brushSize
            end
        end
    elseif y > 0 then
        -- increase brush size
        if brushSize<30 and (selBrickType~=7 or brushSize<4) then
            brushSize = brushSize + 1
            if BrushType == CircleBrush then brushSize = brushSize+1 end
            curBrush = BrushType(brushSize)
            if curX+brushSize>levelProps.sizeX then
                curX = levelProps.sizeX-brushSize+1
            end
            if curY+brushSize>levelProps.sizeY then
                curY = levelProps.sizeY-brushSize+1
            end
        end
    end
end

function EditorViewModel:keypressed(key)
    if key =="." then
        -- change brush
        if selBrickType<7 then
            if BrushType==CircleBrush then
                curBrush = SquareBrush(brushSize)
                editorStatusMsg = "brush changed to square"
            else -- paint brush
                curBrush = CircleBrush(brushSize)
                editorStatusMsg = "brush changed to circle"
            end
        else
            editorStatusMsg = "Can only change brush when bricks are selected"
        end
    elseif isDown("lgui", "rgui") and isDown("s") then
        saveCompressedLevel(luaLevelDir .. self.fileName)
    end

    -- block type
    for i = 3, 8 do
        if key == tostring(i) then
            if i == 8 then
                if selBrickType < 7 then
                    selBrickType = 8
                else
                    selBrickType = selBrickType + 1
                end
                if not blockNames[selBrickType] then
                    selBrickType = 8
                end
            else
                selBrickType = i
            end
            self:setBrickType(selBrickType)
            break
        end
    end


    checkY()
    checkY()
end

-- may return a menu spec to display
function EditorViewModel:applyBrush()
    if selBrickType < 7 then -- colors
        fillBrush(0)
    elseif selBrickType == 7 then -- concrete
        local occupied = false
        printf("test ocupied")
        for k=0,brushSize-1 do
            for l=0,brushSize-1 do
                if brickT[curX+k][curY+l][1]~= 0 then
                    occupied = true
                    break
                end
            end
        end
        printf("ocu",occupied)
        if not occupied then
            local pattern = math.random(0,greyMaxT[brushSize])
            for k=0,brushSize-1 do
                for l=0,brushSize-1 do
                    brickT[curX+k][curY+l] = {7,pattern,brushSize,k,l}
                end
            end
        end
        printf("done concrete")
    else
        -- special
        curOidx = SpecialCollision(curX,curY)
        local tempT = deepcopy(specialDefs[selBrickType])

        if curOidx then
            -- show menu where user edits a special object
            curO = deepcopy(specialT[curOidx])
            if curO then
                local curList = deepcopy(specialVars[curO.sType])
                table.insert(curList,1,{"x",1,levelProps.sizeX})
                table.insert(curList,2,{"y",1,levelProps.sizeY})
                for _,item in ipairs(curList) do
                    item.val = curO[item[1]]
                end
                if curO.sType==8 then -- platform, load pType specific vals
                    for _,item in ipairs(pltfrmDefs[curO.pType]) do
                        table.insert(curList,item)
                        curList[#curList].val = curO[item[1]]
                    end
                end
                local changeFunc = changeFuncs[curO.sType-7]
                if not changeFunc then
                    error("no changeFunc for sType" .. curO.sType)
                end
                return MenuViewModel(
                    blockNames[curO.sType],
                    curList,
                    changeFunc,
                    curOidx
                )
            end
        else
            -- create new
            --if curX+specialDefs[selBrickType].w-1<=levelProps.sizeX and curY+specialDefs[selBrickType].h-1<=levelProps.sizeY then
            tempT.x,tempT.y = curX,curY
            table.insert(specialT,tempT)
            CheckSpecial(specialT[#specialT])
            editorStatusMsg = "Press square to edit object properties"
            --else
            --editorStatusMsg="Not inside level bounds, enlarge level"
            --end
        end
    end
end

function EditorViewModel:setBrickType(idx)
    selBrickType = idx
    if selBrickType==7 then -- concrete
        curBrush = SquareBrush(4)
    elseif selBrickType > 7 then
        curBrush = SquareBrush(1)
    end
end

function CheckSpecial(item)
    if item.x+item.w-1>levelProps.sizeX then
        item.x = levelProps.sizeX-item.w+1
        editorStatusMsg = "Adjusted x to fit inside level"
    end
    if item.y+item.h-1>levelProps.sizeY then
        item.y = levelProps.sizeY-item.h+1
        editorStatusMsg = "Adjusted y to fit inside level"
    end
end


function checkX() --whether curX and camPos[1] are in bounds
    local editorSizeX = editorTilesX()

    camPos[1] = lume.clamp(camPos[1], 1, levelProps.sizeX - editorSizeX)

    if curX<1 then curX=1 end
    if camPos[1]<1 then camPos[1]=1 end

    if curX<camPos[1] then curX = camPos[1] end
    if curX>levelProps.sizeX-brushSize then
        curX = levelProps.sizeX-brushSize+1
    end

end

function checkY()
    local editorSizeY = editorTilesY()

    camPos[2] = lume.clamp(camPos[2], 1, levelProps.sizeY - editorSizeY)

    if curY<1 then curY=1 end
    if camPos[2]<1 then camPos[2]=1 end

    if curY<camPos[2] then curY = camPos[2] end
    if curY>levelProps.sizeY-brushSize then
        curY = levelProps.sizeY-brushSize+1
    end
end

function SpecialCollision(testX,testY)
    for i,item in ipairs(specialT) do
        if item.x<=testX and item.x+item.w>testX and item.y<=testY and item.y+item.h>testY then
            return i
        end
    end
    return false
end
