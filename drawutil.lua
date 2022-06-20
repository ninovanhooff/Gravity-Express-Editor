---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 15/05/2022 18:32
---

local floor = math.floor
local gfx  = love.graphics

local quadCache = {}


function drawSprite(x,y,_,srcX,srcY,w,h)
    local cacheKey = "" .. srcX .. srcY .. w ..h
    local quad = quadCache[cacheKey]
    if not quad then
        quad = gfx.newQuad(srcX, srcY, w, h, sprite:getWidth(), sprite:getHeight())
        quadCache[cacheKey] = quad
    end
    gfx.draw(sprite, quad, x, y)
end

function pgeDrawRectoutline(x, y, w, h, color)
    gfx.setColor(color)
    gfx.rectangle("line", x, y, w, h)
    gfx.setColor(white)
end

function loopAnim(frames,skip)
    return floor((frameCounter % (frames*skip))*(1/skip))
end
