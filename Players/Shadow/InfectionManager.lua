local Debris = game:GetService("Debris")

local TAG_SOUND_ID = "rbxassetid://0" -- replace with uploaded tag impact asset id
local INFECT_SOUND_ID = "rbxassetid://0" -- replace with uploaded infection transform asset id

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
    local char = player.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local snd = Instance.new("Sound")
            snd.SoundId = TAG_SOUND_ID
            snd.Volume = 1
            snd.Parent = root
            snd:Play()
            Debris:AddItem(snd, 2)
        end
    end
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
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local snd = Instance.new("Sound")
            snd.SoundId = INFECT_SOUND_ID
            snd.Volume = 1
            snd.Parent = root
            snd:Play()
            Debris:AddItem(snd, 2)
        end
    end
    player.Team = "Shadow"
end

return InfectionManager
