---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 17/08/2022 21:23
---

function InitEditor()
    curX,curY = 1,1 -- top-left
    camPos = {1,1,0,0} -- top left corner --refactor: titleX, titleY, offsetX, offsetY?
    brushSize = 1
    curBrush = SquareBrush(brushSize)
    selBrickType = 3
    changed = false
    frameCounter = 1
    keys = {true,true,true,true} -- make the barrier colors always lit
    editorMode = true
    editorStatusMsg = "Ready"
end

function generateLevel(w, h)
    levelProps = {fuel=6000,bg=0,sizeX=w,sizeY=h,tLimit=300,lives=5}
    brickT = nil
    brickT = {}
    specialT = {}
    for _=1,levelProps.sizeX do
        local tempCol = {}
        for _=1,levelProps.sizeY do
            table.insert(tempCol,{0,1,1,0,0}) -- type,w,h,subx,suby
        end
        table.insert(brickT,tempCol)
    end
    editorStatusMsg = "Created new level"
end

function decreaseLevelSizeX()
    local newSizeX = levelProps.sizeX - 1
    tempBrush = {}
    curX,curY = newSizeX+1,1
    for i=1,levelProps.sizeX-newSizeX do
        for j=1,levelProps.sizeY do
            table.insert(tempBrush,{i-1,j-1})
            printf(i-1,j-1)
        end
    end
    emptyBrush(tempBrush)
    tempBrush = nil
    for i = 1,levelProps.sizeX-newSizeX do
        table.remove(brickT) --remove last col
        for j=1,levelProps.sizeY do
            local foundIdx = SpecialCollision(levelProps.sizeX-i+1,j)
            if foundIdx then
                table.remove(specialT,foundIdx)
            end
        end
    end
    if curX>=levelProps.sizeX-brushSize then
        curX = levelProps.sizeX-brushSize+1
    end
    if camPos[1]+59>levelProps.sizeX then
        camPos[1] = levelProps.sizeX-59
    end
    printf("newXs",curX,camPos[1])
    levelProps.sizeX = levelProps.sizeX - 1
end

function increaseLevelSizeX()
    -- insert left of curX, except when rightmost row is selected
    if curX == levelProps.sizeX then
        curX = levelProps.sizeX + 1
    end
    local newSizeX = levelProps.sizeX + 1
    local tempT = {}
    for _=1,levelProps.sizeY do
        table.insert(tempT,{0,1,1,0,0} )
    end
    for _=1,newSizeX - levelProps.sizeX do
        table.insert(brickT,curX, deepcopy(tempT))
    end

    for _, item in ipairs(specialT) do
        if item.x >= curX then
            item.x = item.x + 1
        end
    end
    levelProps.sizeX = levelProps.sizeX + 1
end

function increaseLevelSizeY()
    -- insert above selected row, except when bottom row is selected
    if curY == levelProps.sizeY then
        curY = curY + 1
    end
    for _,item in ipairs(brickT) do
        table.insert(item, curY, {0,1,1,0,0}) --add empty tile at end
    end

    for _, item in ipairs(specialT) do
        if item.y >= curY then
            item.y = item.y + 1
        end
    end
    levelProps.sizeY = levelProps.sizeY + 1
end

function decreaseLevelSizeY()
    local curSizeY = levelProps.sizeY
    local newSizeY = curSizeY -1
    tempBrush = {}
    curX,curY = 1, newSizeY +1
    for i=1,levelProps.sizeX do
        for j=1,curSizeY- newSizeY do
            table.insert(tempBrush,{i-1,j-1})
        end
    end
    emptyBrush(tempBrush)
    tempBrush = nil
    for i,item in ipairs(brickT) do
        for j = 1,curSizeY- newSizeY do
            local foundIdx = SpecialCollision(i,curSizeY-j+1)
            if foundIdx then
                table.remove(specialT,foundIdx)
            end
            table.remove(item) --remove last y of col
        end
    end
    if curY>=levelProps.sizeY-brushSize then
        curY = levelProps.sizeY-brushSize+1
    end
    if camPos[2]+31>levelProps.sizeY then
        camPos[2] = levelProps.sizeY-31
    end
    levelProps.sizeY = levelProps.sizeY - 1
    printf("newYs",curY,camPos[2])
end
