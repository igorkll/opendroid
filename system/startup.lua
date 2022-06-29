local bootfs = component.proxy(computer.getBootAddress())
local package = require("package")

----------------------------------

--взято с форума computer craft - https://computercraft.ru/topic/2518-zaschitnik-tablits-tprotect/?tab=comments#comment-37169
--надеюсь штучька надежная так как нужна она мне для сирьезных вешей

local tprotect={} 
local raw_rawset=rawset -- Сохраняем rawset для дальнейшего пользования
local raw_rawget=rawget -- Сохраняем rawget для дальнейшего пользования
local getmetatable=getmetatable --
local setmetatable=setmetatable --
local type=type                 -- Дополнительная зашыта --так вот от куда эти рофлы.... это не мой комент, а автора бибиотеки
local error=error               --
local assert=assert             --
local protectid={}
local nextid={}
function rawget(t,k)
  if type(t)=="table" and raw_rawget(t,protectid) then
    error("СЕРЬЁЗНАЯ ПРОБЛЕМА БЕЗОПАСНОСТИ ДЕТЕКТЕД. УНИЧТОЖАЕМ ОПАСНОСТЬ...",2)
  end
  return raw_rawget(t,k)
end
local raw_next=next
-- НИКТО НЕ ДОЛЖЕН УЗНАТЬ МАСТЕР-КЛЮЧ!!!
function next(t,k)
  if type(t)=="table" and raw_rawget(t,protectid) then
    error("СЕРЬЁЗНАЯ ПРОБЛЕМА БЕЗОПАСНОСТИ ДЕТЕКТЕД. УНИЧТОЖАЕМ ОПАСНОСТЬ...",2)
  end
  local ok,k,v=xpcall(raw_next,debug.traceback,t,k)
  if not ok then
    error(k,0)
  end
  return k,v
end
local raw_ipairs=ipairs
function ipairs(...)
  local f,t,z=raw_ipairs(...)
  return function(t,k)
    if type(t)=="table" and raw_rawget(t,protectid) then
      error("СЕРЬЁЗНАЯ ПРОБЛЕМА БЕЗОПАСНОСТИ ДЕТЕКТЕД. УНИЧТОЖАЕМ ОПАСНОСТЬ...",2)
    end
    return f(t,k)
  end,t,z
end
function rawset(t,k,v) -- Потому что в защитные копии таблиц можно было бы записывать. Хоть это бы и не отразилось бы на оригинале, но при попытке индекснуть поле защитной копии будет подложено подмененное поле в обход __index :(
  if k==protectid then
    error("СЕРЬЁЗНАЯ ПРОБЛЕМА БЕЗОПАСНОСТИ ДЕТЕКТЕД. УНИЧТОЖАЕМ ОПАСНОСТЬ...",2)
  end
  assert(type(t)=="table","bad argument #1 to rawset (table expected, got "..type(t)..")")
  assert(type(k)~="nil","bad argument #2 to rawset (table index is nil)")
  local mt=getmetatable(t)
  local no_set=raw_rawget(t,protectid) or (type(mt)=="table" and raw_rawget(mt,protectid))
  if no_set then
    error("таблица рид-онли! Аксес дэняйд!",2)
  end
  raw_rawset(t,k,v)
  return t
end
function tprotect.protect(t)
  local tcopy={[protectid]=true}
  local mto=getmetatable(t)
  local tcopy_mt=type(mto)=="table" and mto or {}
  local mt={[protectid]=true}
  function mt:__index(k)
    local x=t[k]
    if tcopy_mt.__index and not x then
      return tcopy_mt.__index(t,k)
    end
    return t[k]
  end
  function mt:__pairs(self)
    if tcopy_mt.__pairs then
      return tcopy_mt.__pairs(t)
    end
    local function iter(x,i)
      assert(x==self)
      return next(t,i)
    end
    return iter,self,nil
  end
  function mt:__ipairs(self)
    if tcopy_mt.__ipairs then
      return tcopy_mt.__ipairs(t)
    end
    local f,x,i=ipairs(self)
    local function iter(self,i)
      return f(t,i)
    end
    return iter,x,i
  end
  function mt:__newindex(k,v)
    if tcopy_mt.__newindex then -- Мы доверяем нашим клиентам!
      return tcopy_mt.__newindex(self,k,v)
    end
    error("СРЕДНЕНЬКАЯ ПРОБЛЕМА БЕЗОПАСНОСТИ ДЕТЕКТЕД. УНИЧТОЖАЕМ ОПАСНОСТЬ...",2)
  end
  mt.__metatable={"Хочешь проблем? Попытайся взломать tprotect!"}
  setmetatable(mt,{__index=function(self,i)
    local v=tcopy_mt
    if type(v)=="function" then
      return function(self,...)
        return v(t,...)
      end
    end
    return v
  end})
  setmetatable(tcopy,mt)
  return tcopy,tcopy_mt
end
local tprotect_t,tprotect_mt=tprotect.protect(tprotect) -- Защитим нашу библиотечку
package.loaded.tprotect = tprotect_t
local tprotect = tprotect_t

----------------------------------

local parts = {}

function parts.segments(path)
    local parts = {}
    for part in path:gmatch("[^\\/]+") do
        local current, up = part:find("^%.?%.$")
        if current then
            if up == 2 then
                table.remove(parts)
            end
        else
            table.insert(parts, part)
        end
    end
    return parts
end

function parts.concat(...)
    local set = table.pack(...)
    for index, value in ipairs(set) do
      checkArg(index, value, "string")
    end
    return parts.canonical(table.concat(set, "/"))
end

function parts.xconcat(...)
    local set = table.pack(...)
    for index, value in ipairs(set) do
        checkArg(index, value, "string")
    end
    for index, value in ipairs(set) do
        if value:sub(1, 1) == "/" and index > 1 then
            local newset = {}
            for i = index, #set do
                table.insert(newset, set[i])
            end
            return parts.xconcat(table.unpack(newset))
        end
    end
    return parts.canonical(table.concat(set, "/"))
end

function parts.sconcat(main, ...)
    main = parts.canonical(main)
    local path = parts.concat(main, ...)
    if unicode.sub(path, 1, unicode.len(main)) == main then
        return path
    end
    return false
end

function parts.canonical(path)
    local result = table.concat(parts.segments(path), "/")
    if unicode.sub(path, 1, 1) == "/" then
        return "/" .. result
    else
        return result
    end
end

function parts.path(path)
    local parts = parts.segments(path)
    local result = table.concat(parts, "/", 1, #parts - 1) .. "/"
    if unicode.sub(path, 1, 1) == "/" and unicode.sub(result, 1, 1) ~= "/" then
        return "/" .. result
    else
        return result
    end
end
  
function parts.name(path)
    checkArg(1, path, "string")
    local parts = parts.segments(path)
    return parts[#parts]
end
  
package.loaded.paths = parts

----------------------------------

local simpleIO = {}

function simpleIO.getFile(fs, path)
    local file, err = fs.open(path, "rb")
    if not file then return nil, err end
    local buffer = ""
    while true do
        local data = fs.read(file, math.huge)
        if not data then break end
        buffer = buffer .. data
    end
    fs.close(file)
    return buffer
end

function simpleIO.saveFile(fs, path, data)
    local file, err = fs.open(path, "wb")
    if not file then return nil, err end
    fs.write(path, data)
    fs.close(file)
    return true
end

package.loaded.simpleIO = simpleIO

----------------------------------

local sandbox = {}

local function systemKey()
end

function sandbox.createSandbox(key)
    local globals, env = {}, {}

    local createTime = computer.uptime()
    --в _ENV так же лежит и обьект самого приложения
    --куда в будушем будет положены разные данные этого приложения, наример внутриняя файловая системма самого приложения
    env.app = {}
    env.app.data = {}
    env.app.key = key
    function env.app.uptime()
        return computer.uptime() - createTime
    end

    if key == systemKey then --system
        globals = _G --реальные глобалы
    elseif key == true then --sandbox
        globals.assert = assert --глобалы в данном случаи такие же личьные как и _ENV
        globals.error = error
        globals.getmetatable = getmetatable
        globals.setmetatable = setmetatable
        globals.ipairs = ipairs
        globals.pairs = pairs
        globals.load = load
        globals.next = next
        globals.select = select
        globals.pcall = pcall
        globals.xpcall = xpcall
        globals.tonumber = tonumber
        globals.tostring = tostring
        globals.type = type

        globals.rawequal = rawequal
        globals.rawget = rawget
        globals.rawset = rawset
        globals.rawlen = rawlen

        globals.table = table
        globals.unicode = unicode
        globals.string = string
        --env.coroutine = coroutine
        --env.debug = debug
        globals.utf8 = utf8
        globals.math = math
        --env.os = os

        globals._VERSION = _VERSION
        globals.executeApp = executeApp
        globals.require = function(name)
            if name ~= "package" then
                return tprotect.protect(require(name))
            end
        end
        for k, v in pairs(env) do
            if type(v) == "table" then
                env[k] = tprotect.protect(k)
            end
        end
    else
        error("this key is not found", 0)
    end

    setmetatable(env, {__index = function(_, key)
        return globals[key]
    end})
    return env
end

package.loaded.sandbox = sandbox

----------------------------------functions

local function isUnsupportedChars(data)
    return data:find("%.") or data:find("%\\") or data:find("%/")
end

----------------------------------

table.insert(package.loaders, function(name)
    if not isUnsupportedChars(name) then
        local path = parts.sconcat("/system/libs", name .. ".lua")
        if path and bootfs.exists(path) then
            local data = simpleIO.getFile(path)
            if data then
                local env = sandbox.createSandbox(systemKey)
                env.app.path = path

                if name == "keys" then
                    env.app.data.keys.systemKey = systemKey
                    env.app.data.keys.appKey = true
                end
                
                return load(data, "=" .. path, nil, env)
            end
        end
    end
end)

----------------------------------executing

function loadApp(name, key)
    --системма антихакер
    if isUnsupportedChars(name) then
        return nil, "the name contains unsupported characters"
    end

    --упровления путем
    local path
    local function checkPath(lpath)
        if bootfs.exists(lpath) then
            path = lpath
            return true
        end
    end
    local isSystem = true
    if not checkPath(parts.concat("/system/apps", name, "main.lua")) then
        isSystem = false
        if not checkPath(parts.concat("/data/apps", name, "main.lua")) then
            
        end
    end
    if not path then
        return nil, "application is not found"
    end

    --работа с ключем песочьницы
    if key == nil then
        if isSystem then
            key = systemKey
        else
            key = true
        end
    end

    --обработка песочьницы
    local env = sandbox.createSandbox(key)
    if key == systemKey then
        env.app.path = path
    end

    --получения исполняемого файла приложения
    local data = simpleIO.getFile(bootfs, path)
    local code = load(data, "=" .. path, nil, env)

    return code
end

function executeApp(name, key, ...)
    local code, err = loadApp(name, key)
    if not code then
        return nil, err
    end
    return pcall(code, ...)
end

----------------------------------main

assert(executeApp("shell"))