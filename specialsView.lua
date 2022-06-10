---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 12/03/2022 15:42
---

local floor = math.floor
local fmod = math.fmod

local white = {1,1,1} -- rgb
local yellow = {1,1,0} -- rgb

local pltfrmCoordT = {{224,178},{192,194},{0,216},{0,194},{0,178}}

function RenderPlatform(item)
    -- generic
    local barY
    if item.pType<5 then
        barY = item.pType*6+264
    else
        barY = item.color*6+288
    end
    local pltfrmY = scrY+32
    drawSprite(scrX, pltfrmY, unFlipped, pltfrmCoordT[(item.w-8)*0.25][1], pltfrmCoordT[(item.w-8)*0.25][2], item.w*8, 16) -- platform
    drawSprite(scrX+6, pltfrmY+4, unFlipped, 392, barY, 26, 6)--left end colored bar
    for j= 1,(item.w-8)*0.25 do
        drawSprite(scrX+j*32, pltfrmY+4, unFlipped, 416, barY, 32, 6)--middle tiling colored bar
    end
    drawSprite(scrX+32+(item.w-8)*8, pltfrmY+4, unFlipped, 449, barY, 26, 6)--right end colored bar

    -- type-specific
    if item.pType==1 then -- home
        if item.arrows==1 then
            drawSprite(scrX, scrY, unFlipped, 313,414,24, 32, 0, 150)
            drawSprite(scrX+(item.w-3)*8, scrY, unFlipped, 313,446,24, 32, 0, 150)
        end
    elseif item.pType==2 then -- freight
        for i = 1,item.amnt,1 do
            if i == 1 then
                drawSprite(scrX+8, pltfrmY-16, unFlipped, 80+item.type*16, 346, 16, 16)
            elseif fmod(i,2)==0 then -- lower pos
                drawSprite(scrX+8*(i+1), pltfrmY-16, unFlipped, 80+item.type*16, 346, 16, 16)
            else
                drawSprite(scrX+8*(i-1), scrY, unFlipped, 80+item.type*16, 346, 16, 16)
            end
        end
    elseif item.pType==3 then-- fuel
        for i = 1,item.amnt,1 do
            if i == 1 then
                drawSprite(scrX+8, pltfrmY-16, unFlipped, 64, 346, 16, 16)
            elseif fmod(i,2)==0 then -- lower pos
                drawSprite(scrX+8*(i+1), pltfrmY-16, unFlipped, 64, 346, 16, 16)
            else
                drawSprite(scrX+8*(i-1), scrY, unFlipped, 64, 346, 16, 16)
            end
        end
    elseif item.pType==4 and item.amnt>0 then-- extras
        drawSprite(scrX+8, pltfrmY-16, unFlipped, 128+16*item.type, 346, 16, 16)
    elseif item.pType==5 and item.amnt>0 then-- key
        drawSprite(scrX+8, pltfrmY-24, unFlipped, 185+(frameCounter%7)*16, 398+16*item.color, 16, 16)
    end
    if editorMode then
        pgeDrawRectoutline(scrX,scrY,item.w*8,32,white)
    end
end

function RenderBlower(item)
    if item.direction==1 then
        drawSprite(scrX, scrY+item.distance*8+16, unFlipped, 320+(frameCounter%3)*48, 142-(item.grating-1)*48, 48, 48) -- body
        drawSprite(scrX, scrY+item.distance*8, unFlipped, 380, 372+(item.direction-1)*16, 48, 16)
        if editorMode then
            pgeDrawRectoutline(scrX,scrY,48,item.distance*8,white)
        end
    elseif item.direction==2 then
        drawSprite(scrX, scrY, unFlipped, 320+(frameCounter%3)*48, 142-(item.grating-1)*48, 48, 48) -- body
        drawSprite(scrX, scrY+48, unFlipped, 380, 372+(item.direction-1)*16, 48, 16)
        if editorMode then
            pgeDrawRectoutline(scrX,scrY+64,48,item.distance*8,white)
        end
    elseif item.direction==3 then
        drawSprite(scrX+item.distance*8+16, scrY, unFlipped, 320+(frameCounter%3)*48, 142-(item.grating-1)*48, 48, 48) -- body
        drawSprite(scrX+item.distance*8, scrY, unFlipped, 464+(item.direction-3)*16, 94, 16, 48)
        if editorMode then
            pgeDrawRectoutline(scrX,scrY,item.distance*8,48,white)
        end
    elseif item.direction==4 then
        drawSprite(scrX, scrY, unFlipped, 320+(frameCounter%3)*48, 142-(item.grating-1)*48, 48, 48) -- body
        drawSprite(scrX+48, scrY, unFlipped, 464+(item.direction-3)*16, 94, 16, 48)
        if editorMode then
            pgeDrawRectoutline(scrX+64,scrY,item.distance*8,48,white)
        end
    end
end

function RenderMagnet(item)
    if item.direction==1 then
        drawSprite(scrX, scrY+item.distance*8+16, unFlipped, 0, 234, 32, 32) -- body
        drawSprite(scrX, scrY+item.distance*8, unFlipped, 0+loopAnim(3,2)*32, 282, 32, 16)
        if editorMode then pgeDrawRectoutline(scrX,scrY,32,item.distance*8,white) end
    elseif item.direction==2 then
        drawSprite(scrX, scrY, unFlipped, 0, 234, 32, 32) -- body
        drawSprite(scrX, scrY+32, unFlipped, 0+loopAnim(3,2)*32, 266, 32, 16)
        if editorMode then pgeDrawRectoutline(scrX,scrY+32+16,32,item.distance*8,white) end
    elseif item.direction==3 then
        drawSprite(scrX+item.distance*8+16, scrY, unFlipped, 0, 234, 32, 32) -- body
        drawSprite(scrX+item.distance*8, scrY, unFlipped, 79+loopAnim(3,2)*16, 234, 16, 32)
        if editorMode then pgeDrawRectoutline(scrX,scrY,item.distance*8,32,white) end
    elseif item.direction==4 then
        drawSprite(scrX, scrY, unFlipped, 0, 234, 32, 32) -- body
        drawSprite(scrX+32, scrY, unFlipped, 32+loopAnim(3,2)*16, 234, 16, 32)
        if editorMode then pgeDrawRectoutline(scrX+32+16,scrY,item.distance*8,32,white) end
    end
end

--[[function RenderRotator(item)
	if item.direction==1 then
	elseif item.direction==2 then
	elseif item.direction==3 then
	elseif item.direction==4 then
end]]


function RenderRotator(item)
    if item.direction==1 then
        drawSprite(scrX, scrY+item.distance*8+24, unFlipped, 0+loopAnim(8,2)*40, 96+(item.rotates-1)*40, 40, 40)
        drawSprite(scrX, scrY+item.distance*8, unFlipped, 320+(item.rotates-1)*80, 190, 40, 24)
        if editorMode then pgeDrawRectoutline(scrX,scrY,40,item.distance*8,white) end
    elseif item.direction==2 then
        drawSprite(scrX, scrY, unFlipped, 0+loopAnim(8,2)*40, 96+(item.rotates-1)*40, 40, 40) -- body
        drawSprite(scrX, scrY+40, unFlipped, 363+(item.rotates-1)*80, 190, 40, 24) -- nozzle
        if editorMode then pgeDrawRectoutline(scrX,scrY+40+24,40,item.distance*8,white) end
    elseif item.direction==3 then
        drawSprite(scrX+item.distance*8+24, scrY, unFlipped, 0+loopAnim(8,2)*40, 96+(item.rotates-1)*40, 40, 40)
        drawSprite(scrX+item.distance*8, scrY, unFlipped, (item.rotates-1)*48, 298, 24, 40)
        if editorMode then pgeDrawRectoutline(scrX,scrY,item.distance*8,40,white) end
    elseif item.direction==4 then
        drawSprite(scrX, scrY, unFlipped, 0+loopAnim(8,2)*40, 96+(item.rotates-1)*40, 40, 40)
        drawSprite(scrX+40, scrY, unFlipped, 24+(item.rotates-1)*48, 298, 24, 40)
        if editorMode then pgeDrawRectoutline(scrX+40+24,scrY,item.distance*8,40,white) end
    end
end

function RenderCannon(item)
    if item.direction==1 then -- up

        if editorMode then
            pgeDrawRectoutline(scrX,scrY,24,item.distance*8,white)
        else
            for j,jtem in ipairs(item.balls) do
                local bOff = (floor((frameCounter-jtem[2])%72/3))*8
                drawSprite(scrX+8, scrY+item.distance*8-jtem[1], unFlipped, 240+bOff, 72, 8, 8)
            end
        end
        drawSprite(scrX, scrY+item.distance*8, unFlipped, 396, 405, 24, 40) -- body
        drawSprite(scrX+4, scrY, unFlipped, 472, 150, 16, 24) -- receiver
    elseif item.direction==2 then -- down

        if editorMode then
            pgeDrawRectoutline(scrX,scrY+40,24,item.distance*8,white)
        else
            for j,jtem in ipairs(item.balls) do
                local bOff = (floor((frameCounter-jtem[2])%72/3))*8
                drawSprite(scrX+8, scrY+jtem[1]+24, unFlipped, 240+bOff, 72, 8, 8)
            end
        end
        drawSprite(scrX, scrY, unFlipped, 396, 421, 24, 40) -- body
        drawSprite(scrX+4, scrY+item.distance*8+16, unFlipped, 472, 142, 16, 24) -- receiver
    elseif item.direction==3 then -- left

        if editorMode then
            pgeDrawRectoutline(scrX,scrY,item.distance*8,24,white)
        else
            for j,jtem in ipairs(item.balls) do
                local bOff = (floor((frameCounter-jtem[2])%72/3))*8
                drawSprite(scrX+item.distance*8-jtem[1], scrY+8, unFlipped, 240+bOff, 72, 8, 8)
            end
        end
        drawSprite(scrX+item.distance*8, scrY, unFlipped, 380, 421, 40, 24) -- body
        drawSprite(scrX, scrY+4, unFlipped, 472, 150, 24, 16) -- receiver
    else -- right

        if editorMode then
            pgeDrawRectoutline(scrX+40,scrY,item.distance*8,24,white)
        else
            for j,jtem in ipairs(item.balls) do
                local bOff = (floor((frameCounter-jtem[2])%72/3))*8
                drawSprite(scrX+24+jtem[1], scrY+8, unFlipped, 240+bOff, 72, 8, 8)
            end
        end
        drawSprite(scrX, scrY, unFlipped, 396, 421, 40, 24) -- body
        drawSprite(scrX+item.distance*8+16, scrY+4, unFlipped, 464, 150, 24, 16) -- receiver
    end

end

function RenderRod(item)
    local skip = 20
    if item.direction==2 then -- vertical
        if editorMode then
            pgeDrawRectoutline(scrX,scrY+24,24,item.distance*8,white)
        end
        drawSprite(scrX+2, scrY+item.distance*8, unFlipped, 4+loopAnim(2,skip)*28, 460, 20, 24) -- bottom
        drawSprite(scrX+2, scrY, unFlipped, 32-loopAnim(2,skip)*28, 464, 20, 24) -- top
        drawSprite(scrX+6, scrY+24, unFlipped, 500, 512-item.pos1, 12, item.pos1) -- top rod
        drawSprite(scrX+6, scrY+item.distance*8-item.pos2, unFlipped, 500, 204, 12, item.pos2) -- bottom rod
    elseif item.direction==1 then -- horizontal
        if editorMode then
            pgeDrawRectoutline(scrX+24,scrY,item.distance*8,24,white)
        end
        drawSprite(scrX, scrY+2, unFlipped, 4+loopAnim(2,skip)*28, 464, 24, 20) -- left
        drawSprite(scrX+item.distance*8, scrY+2, unFlipped, 28-loopAnim(2,skip)*28, 464, 24, 20) -- right
        drawSprite(scrX+24, scrY+6, unFlipped, 472-item.pos1, 80, item.pos1, 12) -- left rod
        drawSprite(scrX+item.distance*8-item.pos2, scrY+6, unFlipped, 164, 80, item.pos2, 12) -- right rod
    end

end

function Render1Way(item)
    if item.direction==1 then -- up
        drawSprite(scrX, scrY+item.distance*8-4, unFlipped, 160, 214, 96, 36) -- body
        drawSprite(scrX+32, scrY-4-item.pos+item.distance*8, unFlipped, 436, 352, 32, item.pos) -- barrier
        drawSprite(scrX+8+(item.XtoY-1)*64, scrY+8+item.distance*8, unFlipped, 32-(item.XtoY-1)*32, 338, 16, 16) -- direction sign
        if item.endStone==1 then
            drawSprite(scrX+32, scrY, unFlipped, 128, 234, 32, 16)
        end
        if editorMode then
            pgeDrawRectoutline(scrX+32+(item.XtoY-2)*(-32+item.actW*8),scrY+item.distance*4+18-item.actH*4-4,item.actW*8,item.actH*8,yellow)
        end
    elseif item.direction==2 then -- down
        drawSprite(scrX, scrY, unFlipped, 256, 214, 96, 36) -- body
        drawSprite(scrX+32, scrY+36, unFlipped, 436, 512-item.pos, 32, item.pos) -- barrier
        drawSprite(scrX+8+(item.XtoY-1)*64, scrY+8, unFlipped, 32-(item.XtoY-1)*32, 338, 16, 16) -- direction sign
        if item.endStone==1 then
            drawSprite(scrX+32, scrY+32+item.distance*8-16, unFlipped, 128, 254, 32, 16)
        end
        if editorMode then
            pgeDrawRectoutline(scrX+32+(item.XtoY-2)*(-32+item.actW*8),scrY+item.distance*4+18-item.actH*4-4,item.actW*8,item.actH*8,yellow)
        end
    elseif item.direction==3 then -- left
        drawSprite(scrX-4+item.distance*8, scrY, unFlipped, 196, 250, 36, 96) -- body
        drawSprite(scrX-4-item.pos+item.distance*8, scrY+32, unFlipped, 232, 250, item.pos, 32) -- barrier
        drawSprite(scrX+8+item.distance*8, scrY+8+(item.XtoY-1)*64, unFlipped, 48-(item.XtoY-1)*32, 338, 16, 16) -- direction sign
        if item.endStone==1 then
            drawSprite(scrX, scrY+32, unFlipped, 352, 214, 16, 32)
        end
        if editorMode then
            pgeDrawRectoutline(scrX+item.distance*4+18-item.actW*4-4,scrY+64-(item.XtoY-1)*32-boolToNum(item.XtoY==1)*item.actH*8,item.actW*8,item.actH*8,yellow)
        end
    else -- right
        drawSprite(scrX, scrY, unFlipped, 160, 250, 36, 96) -- body
        drawSprite(scrX+36, scrY+32, unFlipped, 392-item.pos, 250, item.pos, 32) -- barrier
        drawSprite(scrX+8, scrY+8+(item.XtoY-1)*64, unFlipped, 48-(item.XtoY-1)*32, 338, 16, 16) -- direction sign
        if item.endStone==1 then
            drawSprite(scrX+32+item.distance*8-16, scrY+32, unFlipped, 372, 214, 16, 32)
        end
        if editorMode then
            pgeDrawRectoutline(scrX+item.distance*4+18-item.actW*4-4,scrY+64-(item.XtoY-1)*32-boolToNum(item.XtoY==1)*item.actH*8,item.actW*8,item.actH*8,yellow)
        end
    end
end

function RenderBarrier(item)
    local colorCoords = {}
    local pixDist = item.distance*8
    if item.direction==1 then -- up
        drawSprite(scrX, scrY+pixDist-4, unFlipped, 96, 274, 48, 36) -- body
        drawSprite(scrX+8, scrY+pixDist-4-item.pos, unFlipped, 468, 352, 32, item.pos) -- barrier
        if item.endStone==1 then
            drawSprite(scrX+8, scrY, unFlipped, 128, 234, 32, 16)
        end
        if editorMode then
            pgeDrawRectoutline(scrX+24-item.actW*4,scrY+pixDist-4-item.distance*4+8-item.actH*4,item.actW*8,item.actH*8,yellow)
        end
        colorCoords = {6,item.distance*8+6}
    elseif item.direction==2 then -- down
        drawSprite(scrX, scrY, unFlipped, 96, 310, 48, 36) -- body
        drawSprite(scrX+8, scrY+36, unFlipped, 468, 512-item.pos, 32, item.pos) -- barrier
        if item.endStone==1 then
            drawSprite(scrX+8, scrY+32+item.distance*8-16, unFlipped, 128, 254, 32, 16)
        end
        if editorMode then
            pgeDrawRectoutline(scrX+24-item.actW*4,scrY+36+item.distance*4-8-item.actH*4,item.actW*8,item.actH*8,yellow)
        end
        colorCoords = {22,6}
    elseif item.direction==3 then -- left
        drawSprite(scrX+pixDist-4, scrY, unFlipped, 428, 214, 36, 48) -- body
        drawSprite(scrX+pixDist-4-item.pos, scrY+8, unFlipped, 232, 282, item.pos, 32) -- barrier
        if item.endStone==1 then
            drawSprite(scrX, scrY+8, unFlipped, 352, 214, 16, 32)
        end
        if editorMode then
            pgeDrawRectoutline(scrX+pixDist-4-item.distance*4-item.actW*4,scrY+24-item.actH*4,item.actW*8,item.actH*8,yellow)
        end
        colorCoords={item.distance*8+6,22}
    else -- right
        drawSprite(scrX, scrY, unFlipped, 392, 214, 36, 48) -- body
        drawSprite(scrX+36, scrY+8, unFlipped, 392-item.pos, 282, item.pos, 32) -- barrier
        if item.endStone==1 then
            drawSprite(scrX+32+item.distance*8-16, scrY+8, unFlipped, 372, 214, 16, 32)
        end
        if editorMode then
            pgeDrawRectoutline(scrX+36+item.distance*4-item.actW*4-8,scrY+24-item.actH*4,item.actW*8,item.actH*8,yellow)
        end
        colorCoords = {6,6}
    end
    if item.activated or editorMode then -- plane in range
        for j,jtem in ipairs(colorT) do
            if item[jtem]==1 then -- required
                if keys[j] or frameCounter%20<10 then -- have key, else blink
                    drawSprite(scrX+colorCoords[1]+(j-1)%2*12, scrY+colorCoords[2]+floor(j*0.4)*12, unFlipped, 64+(j-1)*8, 338, 8, 8)
                end
            end
        end
    end
end



specialRenders = {
    RenderPlatform, -- index 1, sType == 8
    RenderBlower, -- 2
    RenderMagnet, -- 3
    RenderRotator, -- 4
    RenderCannon, -- 5
    RenderRod, -- 6
    Render1Way, -- 7
    RenderBarrier -- 8
}
