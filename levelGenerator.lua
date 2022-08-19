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
