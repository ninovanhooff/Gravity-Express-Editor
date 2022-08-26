---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 19/08/2022 13:52
---

up = "up"
down = "down"
left = "left"
right = "right"

class("MenuViewModel").extends()

function MenuViewModel:init(header, list, changeFunc, specialIndex)
    MenuViewModel.super.init()
    self.header = header
    self.list = list
    self.onChange = changeFunc
    print(self.onChange)
    self.specialIndex = specialIndex

    self.menuSel = 1
end

function MenuViewModel:keypressed(key)
    local curItem = self.list[self.menuSel]
    curItem[4] = curItem[4] or 1
    if key == left then
        if type(curItem[3])=="number" then
            if curItem.val>curItem[2] then
                curItem.val = curItem.val-curItem[4]
            end
        else
            if curItem.val>1 then curItem.val = curItem.val-1 end
        end
    elseif key == right then
        if type(curItem[3])=="number" then
            if curItem.val<curItem[3] then
                curItem.val = curItem.val+curItem[4]
            end
        else
            if curItem.val<#curItem[3] then
                curItem.val = curItem.val+curItem[4]
            end
        end
    elseif key == down then
        if self.menuSel<#self.list then
            self.menuSel = self.menuSel + 1
        end
    elseif key == up then
        if self.menuSel>1 then
            self.menuSel = self.menuSel - 1
        end
    elseif key == "escape" or key == "return" then
        self.isFinished = true
        return
    end

    -- apply changes
    if ( key == left or key == right ) and self.onChange then
        self.list = self.onChange(self.list,self.menuSel,self.specialIndex)
        CheckSpecial(specialT[self.specialIndex])
        changed = true
    end
end