local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local HEARTBEAT_SOUND_ID = "rbxassetid://0" -- replace with uploaded heartbeat asset id

local HeartbeatComponent = {}
HeartbeatComponent.__index = HeartbeatComponent

function HeartbeatComponent.new(character)
    local self = setmetatable({}, HeartbeatComponent)
    self.character = character
    self.root = character:WaitForChild("HumanoidRootPart")
    self.sound = Instance.new("Sound")
    self.sound.SoundId = HEARTBEAT_SOUND_ID
    self.sound.Volume = 0
    self.sound.Looped = true
    self.sound.Parent = self.root
    self.sound:Play()
    self._conn = RunService.Heartbeat:Connect(function()
        self:update()
    end)
    return self
end

function HeartbeatComponent:getNearestShadowDistance()
    local minDist = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and plr:GetAttribute("Role") == "Shadow" then
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - self.root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                    end
                end
            end
        end
    end
    return minDist
end

function HeartbeatComponent:update()
    local dist = self:getNearestShadowDistance()
    if dist == math.huge then
        self.sound.Volume = 0
        self.sound.PlaybackSpeed = 1
    else
        local proximity = math.clamp(1 - dist / 60, 0, 1)
        self.sound.Volume = 0.2 + 0.8 * proximity
        self.sound.PlaybackSpeed = 1 + proximity
    end
end

function HeartbeatComponent:Destroy()
    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end
    if self.sound then
        self.sound:Destroy()
        self.sound = nil
    end
end

return HeartbeatComponent
