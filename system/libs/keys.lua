local lib = {}

function lib.getType(key)
    for k, v in pairs(app.data.keys) do
        if key == v then
            return k
        end
    end
end

return lib