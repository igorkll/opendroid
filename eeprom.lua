-----------------graphic init

local gpu = component.proxy(component.list("gpu")())
gpu.bind(component.list("screen")(), true)
gpu.setDepth(4)
colors = {
    white = 0xF0F0F0,
    orange = F2B233,
    magenta = E57FD8,
    lightBlue = 99B2F2,
    yellow = DEDE6C,
    lime = 7FCC19,
    pink = F2B2CC,
    gray = 4C4C4C,
    lightGray = 999999,
    cyan = 4C99B2,
    purple = B266E5,
    blue = 3366CC,
    brown = 7F664C,
    green = 57A64E,
    red = CC4C4C,
    black = 191919,
}

local function menu(label, strs, funcs)
    
end

-----------------