-----------------env init

local raw_load = load
function load(data, name, bt, env) --disable byte code
    bt = "t"
    return raw_load(data, name, bt, env)
end

-----------------graphic init

local gpu = component.proxy(component.list("gpu")())
gpu.bind(component.list("screen")(), true)
gpu.setDepth(4)

-----------------package init

local package = {}
package.loaded = {package = package}
function require(name)
    return package.loaded[name]
end

-----------------colors lib init

local colorsArray = { --computercraft colors
    white     = 0xF0F0F0,
    orange    = 0xF2B233,
    magenta   = 0xE57FD8,
    lightBlue = 0x99B2F2,
    yellow    = 0xDEDE6C,
    lime      = 0x7FCC19,
    pink      = 0xF2B2CC,
    gray      = 0x4C4C4C,
    lightGray = 0x999999,
    cyan      = 0x4C99B2,
    purple    = 0xB266E5,
    blue      = 0x3366CC,
    brown     = 0x7F664C,
    green     = 0x57A64E,
    red       = 0xCC4C4C,
    black     = 0x191919
}

local colorsIndexs = {}

local count = 0
for k, v in pairs(colorsArray) do
    gpu.setPaletteColor(count, v)
    colorsIndexs[k] = v
    count = count + 1
end

package.loaded.colors = setmetatable({}, {__newindex = function(self, key, value)
    if key and value and colorsArray[key] then
        colorsArray[key] = value
        gpu.setPaletteColor(colorsIndexs[key], value)
    end
end})

----------------------------------image lib

local image = {}

function image.draw(img, x, y)
    for cy, tbl in ipairs(img) do
        local drawPos = 1
        while true do
            if drawPos > #tbl then break end

            local newDrawPos
            local drawSize = 0
            for i = drawPos, #tbl do
                drawSize = drawSize + 1
                if i == #tbl or tbl[i] ~= tbl[i + 1] then
                    gpu.setBackground(tbl[i])
                    newDrawPos = i + 1
                    break
                end
            end
            gpu.set((drawPos + x) - 1, (cy + y) - 1, (tostring(math.floor(math.random(0, 9)))):rep(drawSize))
            drawPos = newDrawPos
        end
    end
end

package.loaded.image = image

-----------------

local function menu(label, strs, funcs)
    
end

-----------------