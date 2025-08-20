local RunService = game:GetService("RunService")
local DarknessManager = require(game:GetService("ReplicatedStorage"):WaitForChild("World"):WaitForChild("DarknessManager"))

local FlashlightComponent = {}
FlashlightComponent.__index = FlashlightComponent

FlashlightComponent.MAX_BATTERY = 90 -- seconds of use
FlashlightComponent.RECHARGE_TIME = 12 -- seconds

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
    self._conn = RunService.Heartbeat:Connect(function(dt)
        self:update(dt)
    end)
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
    if self.light and self.light.Enabled then
        local parent = self.light.Parent
        local pos = parent and parent.Position or Vector3.new()
        local mult = DarknessManager and DarknessManager:GetLightMultiplier(pos) or 1
        self.light.Brightness = self.baseBrightness * mult
        self.light.Range = self.baseRange * mult
        self.battery = math.max(0, self.battery - dt)
        if self.battery <= 0 then
            self.light.Enabled = false
        end
    end
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
end

return FlashlightComponent

