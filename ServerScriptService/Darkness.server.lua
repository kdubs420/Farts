local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Darkness = {}
Darkness.__index = Darkness

function Darkness.new()
    local self = setmetatable({}, Darkness)
    self.coverage = 0
    self.nodes = 0
    self.event = Instance.new("BindableEvent")
    self.event.Name = "DarknessUpdate"
    self.event.Parent = ReplicatedStorage
    return self
end

function Darkness:Start()
    local GameDef = require(ReplicatedStorage.Shared.GameDef)
    self.coverage = 0
    self.nodes = 0
    for _, step in ipairs(GameDef.Darkness.Expansion) do
        task.delay(step.t, function()
            if step.expand then
                self.coverage = math.min(GameDef.Darkness.MaxCoverage, self.coverage + step.expand)
            end
            if step.activateNodes then
                self.nodes = self.nodes + step.activateNodes
            end
            self.event:Fire(self.coverage, self.nodes)
        end)
    end
end

return Darkness
