local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local DarknessManager = require(game:GetService("ReplicatedStorage"):WaitForChild("World"):WaitForChild("DarknessManager"))

local FlashlightComponent = {}
FlashlightComponent.__index = FlashlightComponent

FlashlightComponent.MAX_BATTERY = 90 -- seconds of use
FlashlightComponent.RECHARGE_TIME = 12 -- seconds
FlashlightComponent.RAYCAST_LIMIT = 10
FlashlightComponent.AUTO_TOGGLE = UserInputService.TouchEnabled

function FlashlightComponent.new(light)
    local self = setmetatable({}, FlashlightComponent)
    self.light = light
    self.battery = FlashlightComponent.MAX_BATTERY
    self.recharging = false
    if self.light then
        self.light.Enabled = false
        self.baseBrightness = self.light.Brightness
        self.baseRange = self.light.Range
    end
    self.flickerSound = Instance.new("Sound")
    self.flickerSound.SoundId = "rbxassetid://0" -- replace with uploaded flicker asset id
    self.flickerSound.Volume = 0.5
    self.flickerSound.Parent = light and light.Parent or workspace

    -- aura that glows while the survivor has battery charge
    self.aura = Instance.new("PointLight")
    self.aura.Brightness = 0.6
    self.aura.Range = 12
    self.aura.Color = Color3.new(1, 0.95, 0.8)
    self.aura.Enabled = false
    self.aura.Parent = light and light.Parent or workspace

    self._conn = RunService.Heartbeat:Connect(function(dt)
        self:update(dt)
    end)
    self._raycastCount = 0
    self._raycastTime = os.clock()
    return self
end

function FlashlightComponent:toggle()
    if self.recharging then
        return
    end
    if self.light then
        if self.light.Enabled then
            self.light.Enabled = false
            self.flickerSound:Play()
        elseif self.battery > 0 then
            self.light.Enabled = true
            self.flickerSound:Play()
        end
    end
end

function FlashlightComponent:update(dt)
    if FlashlightComponent.AUTO_TOGGLE and self.light and not self.recharging then
        local parent = self.light.Parent
        local pos = parent and parent.Position or Vector3.new()
        local inDark = DarknessManager and DarknessManager:IsInDarkness(pos)
        self.light.Enabled = inDark and self.battery > 0
    end

    if self.light and self.light.Enabled then
        local parent = self.light.Parent
        local pos = parent and parent.Position or Vector3.new()
        local mult = DarknessManager and DarknessManager:GetLightMultiplier(pos) or 1
        self.light.Brightness = self.baseBrightness * mult
        self.light.Range = self.baseRange * mult
        self.battery = math.max(0, self.battery - dt)
        if self.battery <= 0 then
            self.light.Enabled = false
        else
            self:_raycastForward()
        end
    end

    if self.aura then
        self.aura.Enabled = self.battery > 0
    end
end

function FlashlightComponent:_raycastForward()
    local now = os.clock()
    if now - self._raycastTime >= 1 then
        self._raycastTime = now
        self._raycastCount = 0
    end
    if self._raycastCount >= FlashlightComponent.RAYCAST_LIMIT then
        return
    end
    self._raycastCount = self._raycastCount + 1
    local parent = self.light and self.light.Parent
    if not parent then return end
    local origin = parent.Position
    local direction = parent.CFrame.LookVector * self.baseRange
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {parent}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    workspace:Raycast(origin, direction, params)
end

function FlashlightComponent:startRecharge(station)
    if self.recharging then
        return
    end
    self.recharging = true
    if self.light then
        self.light.Enabled = false
    end
    task.delay(FlashlightComponent.RECHARGE_TIME, function()
        self.battery = FlashlightComponent.MAX_BATTERY
        self.recharging = false
    end)
end

function FlashlightComponent:Destroy()
    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end
    if self.flickerSound then
        self.flickerSound:Destroy()
        self.flickerSound = nil
    end
    if self.aura then
        self.aura:Destroy()
        self.aura = nil
    end
end

return FlashlightComponent

