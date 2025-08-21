local Players = game:GetService("Players")

local Tagging = {}
Tagging.__index = Tagging

function Tagging.new(match, spawns, economy)
    local self = setmetatable({}, Tagging)
    self.match = match
    self.spawns = spawns
    self.economy = economy
    return self
end

function Tagging:Tag(shadow, target, isAmbush)
    if self.match.roles[target] ~= "Survivor" then
        return
    end
    self.match.roles[target] = "Shadow"
    self.economy:RecordTag(shadow, false, isAmbush)
    target:SetAttribute("Role", "Shadow")
    task.delay(3, function()
        self.spawns:Spawn(target, "Shadow")
    end)
end

return Tagging
