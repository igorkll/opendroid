-----------------env init

local raw_load = load
function load(data, name, bt, env) --disable byte code
    bt = "t"
    return raw_load(data, name, bt, env)
end

-----------------graphic init

local gpu = component.proxy(component.list"gpu"())
gpu.bind(component.list"screen"(), true)
gpu.setDepth(4)
local rx, ry = gpu.getResolution()

-----------------package init

local package = {}
package.loaded = {package = package, loaders = {}}
function require(name)
    if not package.loaded[name] then
        for i, v in ipairs(package.loaders) do
            package.loaded[name] = v(name)
            if package.loaded[name] then break end
        end
    end
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

function image.draw(img, x, y, customSet)
    local oldColor = gpu.getBackground()
    for cy, str in ipairs(img) do
        local drawPos = 1
        while 1 do
            if drawPos > #str then break end

            local drawSize, newDrawPos, notSet = 0

            for i = drawPos, #str do
                drawSize = drawSize + 1
                if customSet or i == #str or str:byte(i) ~= str:byte(i + 1) then
                    local col = tonumber(str:sub(i, i), 16)
                    newDrawPos = i + 1
                    if col then
                        gpu.setBackground(indexColors[col + 1])
                    else
                        notSet = 1
                    end
                    break
                end
            end
            if not notSet then
                if customSet then
                    local oldChar, oldFore, oldBack = gpu.get(x, y)
                    gpu.setForeground(oldFore)
                    gpu.set((drawPos + x) - 1, (cy + y) - 1, oldChar)
                else
                    gpu.set((drawPos + x) - 1, (cy + y) - 1, (" "):rep(drawSize))
                end
            end
            drawPos = newDrawPos
        end
    end
    gpu.setBackground(colors.black)
    gpu.setForeground(colors.white)
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
    gpu.setForeground(colors.white)
    gpu.fill(1, 1, rx, ry, " ")
end

local function drawImageInCenter(img, customSet)
    local ix, iy = image.getSize(img)
    image.draw(img, math.ceil((rx / 2) - (ix / 2)), math.ceil((ry / 2) - (iy / 2)), customSet)
end

local function menu(label, strs, funcs, img)
    local num = 1

    local function draw()
        clear()

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

        if img then
            drawImageInCenter(img)
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
                if funcs[num]() then
                    break
                end
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
computer.beep(150, .1)

local deviceinfo, oldSlot, bootdevice = computer.getDeviceInfo(), math.huge
for address in component.list"filesystem" do
    local slot = component.slot(address)
    if deviceinfo[address].clock and deviceinfo[address].clock ~= "20/20/20" and slot >= 0 and slot < oldSlot then
        oldSlot = slot
        bootdevice = component.proxy(address)
    end
end
deviceinfo = N

function fatalError(str)
    clear()
    drawImageInCenter(image.images.errorImage)
    gpu.setForeground(colors.red)
    gpu.set(1, ry, str)
    while 1 do computer.pullSignal() end
end

if not bootdevice then
    fatalError"Hardware Error: no internal HDD found"
end

local inTime = computer.uptime()
while computer.uptime() - inTime < 1 do
    local eventData = {computer.pullSignal(.1)}
    if eventData[1] == "key_down" and eventData[4] == 56 then
        menu("Opendroid Recovery", {"reboot system new", "wipe data/factory reset", "view recovery logs", "power down"},
        {function()
            computer.shutdown(1)
        end, function()
            local strs = {}
            local funcs = {}
            for i = 1, 8 do
                table.insert(strs, "no")
                table.insert(funcs, false)
            end
            table.insert(strs, "yes")
            table.insert(funcs, function()
                bootdevice.remove"data"
                return 1
            end)
            for i = 1, 3 do
                table.insert(strs, "no")
                table.insert(funcs, false)
            end

            menu("confirm factory reset", strs, funcs, image.images.recoveryLogo)
        end, function()
            local strs = {"no logs found"}
            if bootdevice.exists"data/logs/bootErrors.log" then
                local file = bootdevice.open("data/logs/bootErrors.log", "rb")
                if file then
                    strs = {}
                    while 1 do
                        local mainData = ""
                        while 1 do
                            local data = bootdevice.read(file, 1)
                            if not data then goto exit end
                            if data == "\n" then break end
                            mainData = mainData .. data
                        end
                        table.insert(strs, mainData)
                    end
                    ::exit::
                    bootdevice.close(file)
                end
            end

            local num = 1
            local function draw()
                clear()

                for i, v in ipairs(strs) do
                    local posY = i - num
                    if posY > 0 and posY < ry then
                        gpu.set(1, math.floor((ry / 2) + .5), strs[i])
                    end
                end

                drawImageInCenter(image.images.errorImage, 1)
            end
            while 1 do
                local eventData = {computer.pullSignal()}
                if eventData[1] == "key_down" then
                    if eventData[4] == 42 then
                        break
                    elseif eventData[4] == 200 then
                        if num > 1 then num = num - 1 draw() end
                    elseif eventData[4] == 208 then
                        if num < #strs then num = num + 1 draw() end
                    end
                end
            end
        end, computer.shutdown}, image.images.recoveryLogo)
        break
    end
end

bootdevice.makeDirectory"data/logs"

local function addErrToLog(err)
    local file = bootdevice.open("data/logs/bootErrors.log", "ab")
    if file then
        bootdevice.write(file, (err or "unknown error") .. "\n")
        bootdevice.close(file)
    end
end

if not bootdevice.exists"system/startup.lua" then
    addErrToLog"System Error: not found file startup.lua"
    computer.shutdown(1)
end

local file, buffer = assert(bootdevice.open("system/startup.lua", "rb")), ""
while 1 do
    local data = bootdevice.read(file, math.huge)
    if not data then break end
    buffer = buffer .. data
end
bootdevice.close(file)

local code, err = load(buffer, "=startup")
if not code then
    addErrToLog("System Syntax Error: " .. err)
    computer.shutdown(1)
end

function computer.getBootAddress(address)
    return bootdevice.address
end

local ok, err = pcall(code)
if not ok then
    addErrToLog("System Error: " .. err)
    computer.shutdown(1)
end