local ServerScriptService = game:GetService("ServerScriptService")

local Tagging = require(ServerScriptService.Tagging)

local Player = {}
Player.__index = Player

function Player.new(name)
    local self = setmetatable({}, Player)
    self.Name = name
    self.Parent = game:GetService("Players")
    self.Character = {}
    self.attributes = {}
    return self
end

function Player:LoadCharacter()
    self.Character = {}
end

function Player:SetAttribute(attr, value)
    self.attributes[attr] = value
end

function Player:GetAttribute(attr)
    return self.attributes[attr]
end

local FakeSpawns = {}
FakeSpawns.__index = FakeSpawns

function FakeSpawns.new()
    return setmetatable({}, FakeSpawns)
end

function FakeSpawns:Spawn(plr, role)
    plr:SetAttribute("Role", role)
end

local FakeEconomy = {}
FakeEconomy.__index = FakeEconomy

function FakeEconomy.new()
    return setmetatable({}, FakeEconomy)
end

function FakeEconomy:RecordTag()
end

local match = { roles = {} }
local spawns = FakeSpawns.new()
local economy = FakeEconomy.new()
local tagging = Tagging.new(match, spawns, economy)

local shadow = Player.new("Shadow")
local survivor = Player.new("Survivor")
match.roles[shadow] = "Shadow"
match.roles[survivor] = "Survivor"

local conversions = 0
spawns.Spawn = function(self, plr, role)
    plr:SetAttribute("Role", role)
    conversions = conversions + 1
end

local oldDelay = task.delay
task.delay = function(_, fn)
    fn()
    return 0
end

tagging:Tag(shadow, survivor, false)

task.delay = oldDelay

assert(match.roles[survivor] == "Shadow", "survivor not converted")
assert(survivor:GetAttribute("Role") == "Shadow", "attribute not set")
assert(conversions > 0, "spawn not triggered")

print("[TAGFLOW] passed")
