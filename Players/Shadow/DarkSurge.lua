local Players = game:GetService("Players")

local SURGE_SOUND_ID = "rbxassetid://0" -- replace with uploaded dark surge asset id

local DarkSurge = {}
DarkSurge.__index = DarkSurge

DarkSurge.RADIUS = 6
DarkSurge.SLOW_FACTOR = 0.6
DarkSurge.BLACKOUT_TIME = 1.2
DarkSurge.COOLDOWN = 10

function DarkSurge.new(character)
    local self = setmetatable({}, DarkSurge)
    self.character = character
    self.lastUsed = 0
    local root = character:WaitForChild("HumanoidRootPart")
    self.sound = Instance.new("Sound")
    self.sound.SoundId = SURGE_SOUND_ID
    self.sound.Volume = 0.7
    self.sound.Parent = root
    return self
end

function DarkSurge:ready()
    return os.clock() - self.lastUsed >= DarkSurge.COOLDOWN
end

local function findLight(character)
    for _,desc in ipairs(character:GetDescendants()) do
        if desc:IsA("PointLight") or desc:IsA("SpotLight") or desc:IsA("SurfaceLight") then
            return desc
        end
    end
end

function DarkSurge:cast()
    if not self.character or not self:ready() then return end
    local root = self.character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    self.lastUsed = os.clock()
    if self.sound then
        self.sound:Play()
    end
    local origin = root.Position
    for _,plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char and char ~= self.character then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and (hrp.Position - origin).Magnitude <= DarkSurge.RADIUS then
                local originalSpeed = hum.WalkSpeed
                hum.WalkSpeed = originalSpeed * DarkSurge.SLOW_FACTOR
                task.delay(DarkSurge.BLACKOUT_TIME, function()
                    if hum then
                        hum.WalkSpeed = originalSpeed
                    end
                end)
                local light = findLight(char)
                if light then
                    local wasEnabled = light.Enabled
                    light.Enabled = false
                    task.delay(DarkSurge.BLACKOUT_TIME, function()
                        if light then
                            light.Enabled = wasEnabled
                        end
                    end)
                end
            end
        end
    end
end

return DarkSurge
