---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 15/05/2022 19:25
---

function writeLua( filepath, table_to_export )
    assert( filepath, "writeLua, filepath required")
    assert( table_to_export, "writeLua, table_to_export required")

    local file, file_error = io.open( filepath, "w")
    if not file then
        print("writeLua, Cannot open file ", filepath," (", file_error, ")")
        return
    end

    local _isArray = function( t )
        if type(t[1])=="nil" then return false end

        local pairs_count = 0
        for key in pairs(t) do
            pairs_count = pairs_count + 1
            if type(key)~="number" then
                return false
            end
        end

        return pairs_count==#t
    end

    local _write_entry
    _write_entry = function( entry, name )
        local entry_type = type(entry)

        if entry_type=="table" then
            file:write("{")
            if _isArray( entry ) then
                for key, value in ipairs(entry) do
                    _write_entry(value, key)
                    file:write(",")
                end
            else
                for key, value in pairs(entry) do
                    file:write("[\""..tostring(key).."\"]=")
                    _write_entry(value, key)
                    file:write(",")
                end
            end
            file:write("}")
        elseif entry_type=="string" then
            file:write("\""..tostring(entry).."\"")
        elseif entry_type=="boolean" or entry_type=="number" then
            file:write(tostring(entry))
        else
            file:write("nil")
        end
    end

    file:write("return ")
    _write_entry( table_to_export )

    file:close()
end

function writeCompressedBrickT(filepath)
    local compressedBrickT, packFormat = table.compress(deepcopy(brickT))
    print("--- writing "..filepath)
    assert( filepath, "writeBrickT, filepath required")
    assert( compressedBrickT, "writeBrickT, table_to_export required")

    local file, file_error = io.open( filepath, "wb")
    if not file then
        print("writeLua, Cannot open file ", filepath," (", file_error, ")")
        return
    end

    for x, xtem in ipairs(compressedBrickT) do
        for y,ytem in ipairs(xtem.compressed) do
            file:write(ytem)
        end
    end

    file:close()
    return packFormat
end
