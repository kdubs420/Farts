local Players = game:GetService("Players")

local Match = require(script.Match)
local Darkness = require(script.Darkness)
local Spawns = require(script.Spawns)
local Interact = require(script.Interact)
local Tagging = require(script.Tagging)
local Economy = require(script.Economy)
local Save = require(script.Save)

local darkness = Darkness.new()
local spawns = Spawns.new()
local economy = Economy.new()
local match = Match.new({
    darkness = darkness,
    spawns = spawns,
    economy = economy,
})
local tagging = Tagging.new(match, spawns, economy)
match:SetTagging(tagging)
local interact = Interact.new()
match:SetInteract(interact)

Save.init()

Players.PlayerAdded:Connect(function(plr)
    Save.load(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
    Save.save(plr)
end)

match:Start()
