local HttpService = game:GetService("HttpService")
local Util = require(script.Parent.Util)

local ConfigManager = {}
ConfigManager.__index = ConfigManager

local Config = {}
Config.__index = Config

local function available(name)
    return type(getgenv) == "function" and type(getgenv()[name]) == "function" or type(_G[name]) == "function"
end

local function fn(name)
    if type(getgenv) == "function" then
        local env = getgenv()
        if type(env[name]) == "function" then
            return env[name]
        end
    end
    return _G[name]
end

function ConfigManager.new(folder)
    return setmetatable({
        Folder = folder or "Xyneria",
        Entries = {},
    }, ConfigManager)
end

function ConfigManager:Register(flag, getter, setter)
    if type(flag) ~= "string" or flag == "" then
        return
    end
    self.Entries[flag] = { Get = getter, Set = setter }
end

function ConfigManager:Config(name)
    return setmetatable({ Manager = self, Name = tostring(name or "default") }, Config)
end

function Config:_path()
    return self.Manager.Folder .. "/" .. self.Name .. ".json"
end

function Config:Save()
    if not (available("writefile") and available("makefolder")) then
        return false, "filesystem API is unavailable"
    end

    local data = {}
    for flag, entry in pairs(self.Manager.Entries) do
        local ok, value = pcall(entry.Get)
        if ok then
            if typeof(value) == "Color3" then
                value = { __type = "Color3", value = Util.hex(value) }
            elseif typeof(value) == "EnumItem" then
                value = { __type = "EnumItem", value = value.Name }
            end
            data[flag] = value
        end
    end

    pcall(fn("makefolder"), self.Manager.Folder)
    local encoded = HttpService:JSONEncode(data)
    fn("writefile")(self:_path(), encoded)
    return true
end

function Config:Load()
    if not (available("readfile") and available("isfile")) then
        return false, "filesystem API is unavailable"
    end

    local path = self:_path()
    if not fn("isfile")(path) then
        return false, "config does not exist"
    end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(fn("readfile")(path))
    end)
    if not ok or type(decoded) ~= "table" then
        return false, "invalid config"
    end

    for flag, value in pairs(decoded) do
        local entry = self.Manager.Entries[flag]
        if entry and type(entry.Set) == "function" then
            if type(value) == "table" and value.__type == "Color3" then
                value = Util.fromHex(value.value)
            end
            pcall(entry.Set, value)
        end
    end

    return true
end

return ConfigManager
