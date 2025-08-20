local InfectionManager = {}
InfectionManager.__index = InfectionManager

function InfectionManager.new()
    local self = setmetatable({}, InfectionManager)
    self.enabled = true
    self.pending = {}
    return self
end

function InfectionManager:setEnabled(state)
    self.enabled = state and true or false
end

function InfectionManager:toggle()
    self.enabled = not self.enabled
end

function InfectionManager:onTagged(player)
    if not self.enabled then return end
    if not player then return end
    self.pending[player] = true
    task.delay(3, function()
        if self.enabled and self.pending[player] then
            self.pending[player] = nil
            self:convert(player)
        end
    end)
end

function InfectionManager:convert(player)
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end
    player.Team = "Shadow"
end

return InfectionManager
