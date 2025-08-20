local Ambush = {}
Ambush.__index = Ambush

Ambush.LEAP_RANGE = 8
Ambush.WINDUP = 0.4

function Ambush.new(character)
    local self = setmetatable({}, Ambush)
    self.character = character
    self.clinging = false
    return self
end

function Ambush:cling()
    if self.clinging then return end
    local root = self.character and self.character:FindFirstChild("HumanoidRootPart")
    if root then
        root.Anchored = true
        self.clinging = true
    end
end

function Ambush:release()
    if not self.clinging then return end
    local root = self.character and self.character:FindFirstChild("HumanoidRootPart")
    if root then
        root.Anchored = false
    end
    self.clinging = false
end

function Ambush:leap(direction)
    if not self.clinging then return end
    local root = self.character:FindFirstChild("HumanoidRootPart")
    local humanoid = self.character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    direction = direction or root.CFrame.LookVector
    direction = direction.Unit
    self:release()
    task.delay(Ambush.WINDUP, function()
        if humanoid then
            humanoid:Move(direction * Ambush.LEAP_RANGE, true)
        end
    end)
end

return Ambush
