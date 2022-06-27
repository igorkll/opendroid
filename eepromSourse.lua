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
local indexColors = {
    colorsArray.white,
    colorsArray.orange,
    colorsArray.magenta,
    colorsArray.lightBlue,
    colorsArray.yellow,
    colorsArray.lime,
    colorsArray.pink,
    colorsArray.gray,
    colorsArray.lightGray,
    colorsArray.cyan,
    colorsArray.purple,
    colorsArray.blue,
    colorsArray.brown,
    colorsArray.green,
    colorsArray.red,
    colorsArray.black,
}
local colorsIds = {}

for i, v in ipairs(indexColors) do
    gpu.setPaletteColor(i - 1, v)
    local k
    for k2, v2 in pairs(colorsArray) do
        if v == v2 then
            k = k2
            break
        end
    end
    colorsIds[k] = i
end

local colors = setmetatable({}, {__newindex = function(self, key, value)
    if key and value and colorsArray[key] then
        colorsArray[key] = value
        gpu.setPaletteColor(colorsIds[key], value)
    end
end, __index = function(_, key)
    return colorsArray[key]
end})

package.loaded.indexColors = indexColors
package.loaded.colorsIds = colorsIds
package.loaded.colors = colors

----------------------------------image lib

local image = {}

function image.draw(img, x, y)
    local oldColor = gpu.getBackground()
    for cy, str in ipairs(img) do
        local drawPos = 1
        while 1 do
            if drawPos > #str then break end

            local newDrawPos
            local notSet
            local drawSize = 0
            for i = drawPos, #str do
                drawSize = drawSize + 1
                if i == #str or str:byte(i) ~= str:byte(i + 1) then
                    local col = tonumber(str:sub(i, i), 16)
                    newDrawPos = i + 1
                    if col then
                        gpu.setBackground(indexColors[col + 1])
                    else
                        notSet = true
                    end
                    break
                end
            end
            if not notSet then
                gpu.set((drawPos + x) - 1, (cy + y) - 1, (" "):rep(drawSize))
            end
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

-----------------gui

local function clear()
    gpu.setBackground(colors.black)
    gpu.fill(1, 1, rx, ry, " ")
end

local function drawImageInCenter(img)
    local ix, iy = image.getSize(img)
    image.draw(img, math.ceil((rx / 2) - (ix / 2)), math.ceil((ry / 2) - (iy / 2)))
end

local function menu(label, strs, funcs, img)
    local num = 1

    local function draw()
        clear()
        if img then
            drawImageInCenter(img)
        end

        gpu.setForeground(colors.red)
        gpu.setBackground(colors.black)
        gpu.set(1, 1, label)
        gpu.setForeground(colors.lightBlue)
        gpu.fill(1, 2, rx, 1, "─")
        gpu.fill(1, 3 + #strs, rx, 1, "─")
        for i, v in ipairs(strs) do
            if i == num then
                gpu.setBackground(colors.lightBlue)
                gpu.setForeground(colors.white)
                v = v .. (" "):rep(rx - #v)
            else
                gpu.setBackground(colors.black)
                gpu.setForeground(colors.lightBlue)
            end
            gpu.set(1, i + 2, v)
        end
    end

    draw()
    while 1 do
        local eventData = {computer.pullSignal()}
        if eventData[1] == "key_down" then
            if eventData[4] == 28 then
                if not funcs[num] then
                    return
                end
                funcs[num]()
                draw()
            elseif eventData[4] == 200 then
                if num > 1 then
                    num = num - 1
                    draw()
                end
            elseif eventData[4] == 208 then
                if num < #strs then
                    num = num + 1
                    draw()
                end
            end
        end
    end
end

-----------------main

clear()
drawImageInCenter(image.images.osLogo)

local deviceinfo = computer.getDeviceInfo()
local bootdevice
for address in component.list("filesystem") do
    
end

deviceinfo = nil

local inTime = computer.uptime()
while computer.uptime() - inTime < 1 do
    local eventData = {computer.pullSignal(0.1)}
    if eventData[1] == "key_down" and eventData[4] == 56 then
        menu("Opendroid Recovery", strs, funcs, image.images.recoveryLogo)
        break
    end
end

