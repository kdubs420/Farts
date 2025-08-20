local RunService = game:GetService("RunService")

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
    end
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
        elseif self.battery > 0 then
            self.light.Enabled = true
        end
    end
end

function FlashlightComponent:update(dt)
    if self.light and self.light.Enabled then
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
end

return FlashlightComponent

