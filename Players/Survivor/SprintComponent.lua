local RunService = game:GetService("RunService")

local SprintComponent = {}
SprintComponent.__index = SprintComponent

SprintComponent.MAX_STAMINA = 100
SprintComponent.REGEN_RATE = 18 -- per second
SprintComponent.DRAIN_RATE = 25 -- per second while sprinting
SprintComponent.WALK_SPEED = 14
SprintComponent.SPRINT_SPEED = 18

function SprintComponent.new(humanoid)
    local self = setmetatable({}, SprintComponent)
    self.humanoid = humanoid
    self.stamina = SprintComponent.MAX_STAMINA
    self.isSprinting = false
    self.inShadow = false
    self.humanoid.WalkSpeed = SprintComponent.WALK_SPEED
    self.breathSound = Instance.new("Sound")
    self.breathSound.SoundId = "rbxassetid://0" -- replace with uploaded breathing asset id
    self.breathSound.Looped = true
    self.breathSound.Volume = 0
    self.breathSound.Parent = humanoid.RootPart or humanoid.Parent:WaitForChild("HumanoidRootPart")
    self.breathSound:Play()
    self._conn = RunService.Heartbeat:Connect(function(dt)
        self:update(dt)
    end)
    return self
end

function SprintComponent:SetInShadow(inShadow)
    self.inShadow = inShadow and true or false
end

function SprintComponent:start()
    if self.stamina > 0 then
        self.isSprinting = true
        self.humanoid.WalkSpeed = SprintComponent.SPRINT_SPEED
        self.breathSound.Volume = 0.6
    end
end

function SprintComponent:stop()
    if self.isSprinting then
        self.isSprinting = false
        self.humanoid.WalkSpeed = SprintComponent.WALK_SPEED
        self.breathSound.Volume = 0
    end
end

function SprintComponent:update(dt)
    if self.isSprinting then
        self.stamina = math.max(0, self.stamina - SprintComponent.DRAIN_RATE * dt)
        if self.stamina <= 0 then
            self:stop()
        end
    else
        local regen = SprintComponent.REGEN_RATE
        if self.inShadow then
            regen = regen * 0.5
        end
        self.stamina = math.min(SprintComponent.MAX_STAMINA, self.stamina + regen * dt)
    end
end

function SprintComponent:Destroy()
    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end
    if self.breathSound then
        self.breathSound:Destroy()
        self.breathSound = nil
    end
end

return SprintComponent

