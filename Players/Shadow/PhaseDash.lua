local Debris = game:GetService("Debris")

local DASH_SOUND_ID = "rbxassetid://0" -- replace with uploaded phase dash asset id

local PhaseDash = {}
PhaseDash.__index = PhaseDash

PhaseDash.DASH_DISTANCE = 10
PhaseDash.COOLDOWN = 8
PhaseDash.AFTERIMAGE_TIME = 0.4

function PhaseDash.new(character)
    local self = setmetatable({}, PhaseDash)
    self.character = character
    self.lastUsed = 0
    local root = character:WaitForChild("HumanoidRootPart")
    self.sound = Instance.new("Sound")
    self.sound.SoundId = DASH_SOUND_ID
    self.sound.Volume = 0.6
    self.sound.Parent = root
    return self
end

function PhaseDash:ready()
    return os.clock() - self.lastUsed >= PhaseDash.COOLDOWN
end

local function createAfterImage(character)
    local clone = character:Clone()
    for _,desc in ipairs(clone:GetDescendants()) do
        if desc:IsA("BasePart") then
            desc.Anchored = true
            desc.CanCollide = false
            desc.Transparency = math.clamp(desc.Transparency + 0.5, 0, 1)
        elseif desc:IsA("Decal") or desc:IsA("Texture") then
            desc.Transparency = math.clamp(desc.Transparency + 0.5, 0, 1)
        end
    end
    clone.Parent = workspace
    Debris:AddItem(clone, PhaseDash.AFTERIMAGE_TIME)
end

function PhaseDash:dash(direction)
    if not self.character then return end
    if not self:ready() then return end
    local root = self.character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    direction = direction or root.CFrame.LookVector
    direction = direction.Unit
    local targetPos = root.Position + direction * PhaseDash.DASH_DISTANCE
    createAfterImage(self.character)
    self.lastUsed = os.clock()
    if self.sound then
        self.sound:Play()
    end
    root.CFrame = CFrame.new(targetPos)
end

return PhaseDash
