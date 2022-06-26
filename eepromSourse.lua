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
local rx, ry = gpu.getResolution()

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

local colors = setmetatable({}, {__newindex = function(self, key, value)
    if key and value and colorsArray[key] then
        colorsArray[key] = value
        gpu.setPaletteColor(colorsIndexs[key], value)
    end
end, __index = function(_, key)
    return colorsArray[key]
end})

package.loaded.colors = colors

----------------------------------image lib

local image = {}

function image.draw(img, x, y)
    for cy, str in ipairs(img) do
        local drawPos = 1
        while 1 do
            if drawPos > #str then break end

            local newDrawPos
            local drawSize = 0
            for i = drawPos, #str do
                drawSize = drawSize + 1
                if i == #str or str:byte(i) ~= str:byte(i) then
                    gpu.setBackground(str:byte(i))
                    newDrawPos = i + 1
                    break
                end
            end
            gpu.set((drawPos + x) - 1, (cy + y) - 1, (" "):rep(drawSize))
            drawPos = newDrawPos
        end
    end
end

function image.getSize(img)
    return #img[1], #img
end

image.images = {}
image.images.osLogo =
{
    "     4444     ",
    "   44111144   ",
    " 441F1111F144 ",
    "4111F1111F1114",
    "41111111111114",
    " 4411111F1144 ",
    "   441FF144   ",
    "     4444     "
}
image.images.recoveryLogo =
{
    "       555     ",
    " DDDDDD5555D4D ",
    " D94449555555D ",
    " D4F1F4555555D ",
    " D41114555555D ",
    " D94449555555D ",
    " DDDDDD5555D4D ",
    "       555     "
}
image.images.errorImage =
{
    "               ",
    "         44    ",
    "00E0     1F4   ",
    "0EE00E   114CCC",
    "0E00E0E  114CCC",
    "  0E0E011114CCC",
    "   0E0044444CCC",
    "       4CCCCCCC",
}

package.loaded.image = image

-----------------

local function menu(label, strs, funcs, img)
    local num = 1
    while 1 do
        gpu.setBackground(colors.black)
        gpu.fill(1, 1, rx, ry, " ")
        local ix, iy = image.getSize(img)
        image.draw(img, math.ceil((rx / 2) - (ix / 2)), math.ceil((ry / 2) - (iy / 2)))

        local function drawText(x, y, color, useForeground, str)
            if useForeground then
                gpu.setForeground(color)
            else
                gpu.setBackground(color)
            end
            for i = 1, #str do
                local x = x + (i - 1)

                local oldColor = ({gpu.get(x, y)})[useForeground and 3 or 2] --select длинее чем это решения
                if useForeground then
                    gpu.setBackground(oldColor)
                else
                    gpu.setForeground(oldColor)
                end
                gpu.set(x, y, str:sub(i, i))
            end
        end

        gpu.setForeground(colors.yellow)
        gpu.setBackground(colors.black)
        gpu.set(1, 1, label)
        for i, v in ipairs(strs) do
            local str = v .. (" "):rep(rx - #v)
            drawText(1, i + 1, colors.yellow, i ~= num, str)
        end

        computer.pullSignal()
    end
end
menu("Opendroid Recovery", {"asdasd123", "aaa"}, {function()
    computer.beep(2000)
end, function()
    computer.beep(1000)
end}, image.images.recoveryLogo)

-----------------