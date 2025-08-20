local Players = game:GetService("Players")

local PushComponent = {}
PushComponent.__index = PushComponent

PushComponent.COOLDOWN = 10
PushComponent.RANGE = 3
PushComponent.FORCE = 50

function PushComponent.new(character)
    local self = setmetatable({}, PushComponent)
    self.character = character
    self.hrp = character:WaitForChild("HumanoidRootPart")
    self.lastPush = 0
    return self
end

function PushComponent:canPush()
    return os.clock() - self.lastPush >= PushComponent.COOLDOWN
end

function PushComponent:push()
    if not self:canPush() then
        return false
    end
    self.lastPush = os.clock()
    local origin = self.hrp.Position
    local look = self.hrp.CFrame.LookVector
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char and char ~= self.character then
            local target = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if target and hum and hum.Health > 0 then
                local offset = target.Position - origin
                local dist = offset.Magnitude
                if dist <= PushComponent.RANGE then
                    local dir = offset.Unit
                    if dir:Dot(look) > 0.5 then
                        target:ApplyImpulse(dir * PushComponent.FORCE * hum.Mass)
                    end
                end
            end
        end
    end
    return true
end

return PushComponent

