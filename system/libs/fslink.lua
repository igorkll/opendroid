local parts = require("parts")

----------------------------------

local fslink = {}

function fslink.repath(mainpath, path)
    return parts.sconcat(mainpath, path) or mainpath
end

function fslink.link(fs, path)
    local vfs = {}

    return vfs
end

return fslink