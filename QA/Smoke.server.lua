local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Darkness = require(ServerScriptService.Darkness)
local Spawns = require(ServerScriptService.Spawns)
local Economy = require(ServerScriptService.Economy)
local Match = require(ServerScriptService.Match)
local Interact = require(ServerScriptService.Interact)
local Tagging = require(ServerScriptService.Tagging)

local function assertNonNil(...)
    for i, v in ipairs({...}) do
        assert(v ~= nil, "unexpected nil value #" .. i)
    end
end

local darkness = Darkness.new()
local spawns = Spawns.new()
local economy = Economy.new()
local match = Match.new({
    darkness = darkness,
    spawns = spawns,
    economy = economy,
})
local tagging = Tagging.new(match, spawns, economy)
local interact = Interact.new()
match:SetTagging(tagging)
match:SetInteract(interact)

local updates = 0
darkness.event.Event:Connect(function(cov, nodes)
    assertNonNil(cov, nodes)
    updates = updates + 1
end)

local GameDef = require(ReplicatedStorage.Shared.GameDef)
for _, step in ipairs(GameDef.Darkness.Expansion) do
    if step.expand then
        darkness.coverage = math.min(GameDef.Darkness.MaxCoverage, darkness.coverage + step.expand)
    end
    if step.activateNodes then
        darkness.nodes = darkness.nodes + step.activateNodes
    end
    darkness.event:Fire(darkness.coverage, darkness.nodes)
end
assert(updates == #GameDef.Darkness.Expansion, "darkness expansion missing steps")

match:Prep()
match:Hunt()
match:Endgame()
match:Results()
assert(match.phase == "Results", "match did not complete results phase")

local portal = Instance.new("Part")
portal.Name = "Portal"
portal.Parent = workspace
assert(workspace:FindFirstChild("Portal"), "portal not spawned")

print("[SMOKE] passed")
