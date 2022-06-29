local parts = require("parts")

----------------------------------

local fslink = {}

function fslink.repath(mainpath, path)
    return parts.sconcat(mainpath, path) or mainpath
end

function fslink.link(fs, path, maxOpen, size, readonly)
    local fileCount = 0

    local vfs = {}

    vfs.open = function(path, mode)
        if readonly and mode and mode:sub(1, 1) == "w" then return nil, "filesystem is readonly" end
        if fileCount >= maxOpen then return nil, "bad file descriptor" end
        local file, err = fs.open(fslink.repath(path), mode)
        if file then
            local closed
            fileCount = fileCount + 1

            local obj = {}

            function obj.read(readCount)
                if closed then return nil, "too many open handles" end
                return fs.read(file, readCount)
            end
            function obj.write(data)
                if closed then return nil, "too many open handles" end
                return fs.write(file, data)
            end
            function obj.close()
                if closed then return nil, "too many open handles" end
                fileCount = fileCount - 1
                closed = true
                return fs.close(file)
            end
            function obj.seek(...)
                if closed then return nil, "too many open handles" end
                return fs.seek(file, ...)
            end

            return obj
        end
        return nil, err
    end

    vfs.list = function(path)
        return fs.list(fslink.repath(path))
    end
    vfs.exists = function(path)
        return fs.exists(fslink.repath(path))
    end
    vfs.isDirectory = function(path)
        return fs.isDirectory(fslink.repath(path))
    end
    vfs.lastModified = function(path)
        return fs.lastModified(fslink.repath(path))
    end

    vfs.remove = function(path)
        if readonly then return nil, "filesystem is readonly" end
        return fs.remove(fslink.repath(path))
    end
    vfs.rename = function(path, path2)
        if readonly then return nil, "filesystem is readonly" end
        return fs.rename(fslink.repath(path), fslink.repath(path2))
    end
    vfs.makeDirectory = function(path)
        if readonly then return nil, "filesystem is readonly" end
        return fs.makeDirectory(fslink.repath(path))
    end
    vfs.rename = function(path, path2)
        if readonly then return nil, "filesystem is readonly" end
        return fs.rename(fslink.repath(path), fslink.repath(path2))
    end

    return vfs
end

return fslink