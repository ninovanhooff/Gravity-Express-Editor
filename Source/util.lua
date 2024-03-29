---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 10/06/2022 13:52
---

require("tableCompressor")

function boolToNum(bool)
    if bool then return 1 else return 0 end
end

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end


function printf(...)
    if Debug then
        print(unpack(arg))
    end
end

function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

--- returns value from a nested table, or nil
--- example: table.deepGet({{a = 5}}, 1, "a") --> 5
function table.deepGet(tbl, ...)
    local indexes = {...}
    local result = tbl[indexes[1]]
    if not result then
        return nil
    end
    for i = 2, #indexes do
        result = result[indexes[i]]
        if result == nil then
            return nil
        end
    end
    return result
end

function Trunc_Zeros(num,precision)
    local precision = precision or 2
    local numString = string.format("%0."..precision.."f",num)
    local result = numString:gsub("%.?0+$","",1)
    --printf(result)
    return result
end
