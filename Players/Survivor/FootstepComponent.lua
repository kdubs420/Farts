local RunService = game:GetService("RunService")

local FootstepComponent = {}
FootstepComponent.__index = FootstepComponent

local FOOTSTEP_SOUND_ID = "rbxassetid://0" -- replace with uploaded footstep asset id

function FootstepComponent.new(humanoid)
    local self = setmetatable({}, FootstepComponent)
    self.humanoid = humanoid
    self.root = humanoid.Parent:WaitForChild("HumanoidRootPart")
    self.sound = Instance.new("Sound")
    self.sound.SoundId = FOOTSTEP_SOUND_ID
    self.sound.Volume = 0.5
    self.sound.Parent = self.root
    self.speed = 0
    self.stepAccum = 0
    self.runningConn = humanoid.Running:Connect(function(speed)
        self.speed = speed
    end)
    self._conn = RunService.Heartbeat:Connect(function(dt)
        self:update(dt)
    end)
    return self
end

function FootstepComponent:update(dt)
    if self.speed > 2 then
        self.stepAccum = self.stepAccum + dt * self.speed / 14
        if self.stepAccum >= 0.5 then
            self.stepAccum = self.stepAccum - 0.5
            self.sound:Play()
        end
    else
        self.stepAccum = 0
    end
end

function FootstepComponent:Destroy()
    if self.runningConn then
        self.runningConn:Disconnect()
        self.runningConn = nil
    end
    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end
    if self.sound then
        self.sound:Destroy()
        self.sound = nil
    end
end

return FootstepComponent
