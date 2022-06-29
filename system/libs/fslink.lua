local parts = require("parts")

----------------------------------

local fslink = {}

function fslink.repath(mainpath, path)
    return parts.sconcat(mainpath, path) or mainpath
end

function fslink.link(fs, path, maxOpen, size)
    local fileCount = 0

    local vfs = {}

    vfs.open = function(path, mode)
        local file, err = fs.open(fslink.repath(path), mode)
        if file then
            local closed
            fileCount = fileCount + 1

            local obj = {}
            function obj.read(readCount)
                if closed then return end
                return fs.read(file, readCount)
            end
            function obj.write(data)
                if closed then return end
                return fs.write(file, data)
            end
            function obj.close()
                if closed then return end
                fileCount = fileCount - 1
                closed = true
                return fs.close(file)
            end
            function obj.seek(...)
                if closed then return end
                return fs.seek(file, ...)
            end

            return obj
        end
        return nil, err
    end
    vfs.open = function(path, mode)
        return fs.open(fslink.repath(path), mode)
    end

    return vfs
end

return fslink