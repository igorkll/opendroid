local bootfs = component.proxy(computer.getBootAddress())
local package = require("package")

----------------------------------

local parts = {}

function parts.segments(path)
    local parts = {}
    for part in path:gmatch("[^\\/]+") do
        local current, up = part:find("^%.?%.$")
        if current then
            if up == 2 then
                table.remove(parts)
            end
        else
            table.insert(parts, part)
        end
    end
    return parts
end

function parts.concat(...)
    local set = table.pack(...)
    for index, value in ipairs(set) do
      checkArg(index, value, "string")
    end
    return parts.canonical(table.concat(set, "/"))
end

function parts.xconcat(...)
    local set = table.pack(...)
    for index, value in ipairs(set) do
        checkArg(index, value, "string")
    end
    for index, value in ipairs(set) do
        if value:sub(1, 1) == "/" and index > 1 then
            local newset = {}
            for i = index, #set do
                table.insert(newset, set[i])
            end
            return parts.xconcat(table.unpack(newset))
        end
    end
    return parts.canonical(table.concat(set, "/"))
end

function parts.canonical(path)
    local result = table.concat(parts.segments(path), "/")
    if unicode.sub(path, 1, 1) == "/" then
        return "/" .. result
    else
        return result
    end
end

function parts.path(path)
    local parts = parts.segments(path)
    local result = table.concat(parts, "/", 1, #parts - 1) .. "/"
    if unicode.sub(path, 1, 1) == "/" and unicode.sub(result, 1, 1) ~= "/" then
        return "/" .. result
    else
        return result
    end
end
  
function parts.name(path)
    checkArg(1, path, "string")
    local parts = parts.segments(path)
    return parts[#parts]
end
  
package.loaded.paths = parts

----------------------------------

local getters = {}

package.loaded.paths = parts

----------------------------------


table.insert(package.loaders, function()
    
end)