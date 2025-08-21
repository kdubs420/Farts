local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameDef = require(ReplicatedStorage.Shared.GameDef)

local Match = {}
Match.__index = Match

local function cloneArray(arr)
    local t = {}
    for i, v in ipairs(arr) do
        t[i] = v
    end
    return t
end

function Match.new(deps)
    local self = setmetatable({}, Match)
    self.darkness = deps.darkness
    self.spawns = deps.spawns
    self.economy = deps.economy
    self.tagging = nil
    self.interact = nil
    self.phase = "Lobby"
    self.roles = {}
    return self
end

function Match:SetTagging(tagging)
    self.tagging = tagging
end

function Match:SetInteract(interact)
    self.interact = interact
end

function Match:Start()
    self:Lobby()
end

function Match:Lobby()
    task.delay(15, function()
        if #Players:GetPlayers() > 0 then
            self:Prep()
        else
            self:Lobby()
        end
    end)
end

function Match:_assignRoles()
    local players = Players:GetPlayers()
    local pool = cloneArray(players)
    local shadows = math.max(1, math.floor(#players / 5))
    for i = 1, shadows do
        local idx = math.random(1, #pool)
        local plr = table.remove(pool, idx)
        self.roles[plr] = "Shadow"
    end
    for _, plr in ipairs(pool) do
        self.roles[plr] = "Survivor"
    end
end

function Match:Prep()
    self.phase = "Prep"
    self:_assignRoles()
    self.economy:BeginMatch(self.roles)
    for plr, role in pairs(self.roles) do
        self.spawns:Spawn(plr, role)
    end
    self.darkness:Start()
    task.delay(GameDef.Match.PrepTime, function()
        self:Hunt()
    end)
end

function Match:Hunt()
    self.phase = "Hunt"
    task.delay(GameDef.Match.HuntMax, function()
        self:Endgame()
    end)
end

function Match:Endgame()
    self.phase = "Endgame"
    task.delay(GameDef.Match.Endgame, function()
        self:Results()
    end)
end

function Match:Results()
    self.phase = "Results"
    local winner = self:WinningTeam()
    self.economy:Distribute(winner)
    task.delay(10, function()
        self.roles = {}
        self:Lobby()
    end)
end

function Match:WinningTeam()
    local alive = 0
    for plr, role in pairs(self.roles) do
        if role == "Survivor" and plr.Parent then
            alive = alive + 1
        end
    end
    return alive > 0 and "Survivors" or "Shadows"
end

return Match
