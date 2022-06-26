-----------------graphic init

gpu = component.proxy(component.list("gpu")())
gpu.bind(component.list("screen")(), true)
gpu.setDepth(4)

local package = {}
package.loaded = {package = package}
function require(name)
    return 
end

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

local function refreshPalette()
    setmetatable(colors, {__})
end

local function menu(label, strs, funcs)
    
end

-----------------