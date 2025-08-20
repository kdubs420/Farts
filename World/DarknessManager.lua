local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DarknessManager = {}
DarknessManager.__index = DarknessManager

DarknessManager.EXPANSION_INTERVAL = 90
DarknessManager.EXPANSION_AMOUNT = 20
DarknessManager.MAX_RADIUS = 200
DarknessManager.SHADOW_SPEED_BUFF = 1.12
DarknessManager.SURVIVOR_VIS_TRANSPARENCY = 0.4
DarknessManager.SHADOW_LIGHT_TRANSPARENCY = 0.55
DarknessManager.SHADOW_DARK_TRANSPARENCY = 0.2

function DarknessManager.new()
    local self = setmetatable({}, DarknessManager)
    self.zones = {}
    self.running = false
    self._heartbeat = nil
    return self
end

function DarknessManager:AddZone(position, radius)
    table.insert(self.zones, {center = position, radius = radius or 0})
end

function DarknessManager:IsInDarkness(position)
    for _, zone in ipairs(self.zones) do
        if (position - zone.center).Magnitude <= zone.radius then
            return true
        end
    end
    return false
end

function DarknessManager:GetLightMultiplier(position)
    return self:IsInDarkness(position) and 0.5 or 1
end

function DarknessManager:BeginExpansion()
    if self.running then
        return
    end
    self.running = true
    self:_scheduleExpansion()
    self._heartbeat = RunService.Heartbeat:Connect(function()
        self:_updatePlayers()
    end)
end

function DarknessManager:_scheduleExpansion()
    if not self.running then
        return
    end
    task.delay(DarknessManager.EXPANSION_INTERVAL, function()
        self:ExpandZones()
        self:_scheduleExpansion()
    end)
end

function DarknessManager:ExpandZones()
    for _, zone in ipairs(self.zones) do
        zone.radius = math.min(zone.radius + DarknessManager.EXPANSION_AMOUNT, DarknessManager.MAX_RADIUS)
    end
end

function DarknessManager:_updatePlayers()
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if root and hum then
                local inDark = self:IsInDarkness(root.Position)
                local role = plr:GetAttribute("Role")
                if role == "Survivor" then
                    self:_applySurvivorEffects(char, inDark)
                elseif role == "Shadow" then
                    self:_applyShadowEffects(char, hum, inDark)
                end
            end
        end
    end
end

function DarknessManager:_applySurvivorEffects(char, inDark)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local base = part:GetAttribute("BaseTransparency")
            if not base then
                part:SetAttribute("BaseTransparency", part.Transparency)
                base = part.Transparency
            end
            if inDark then
                part.Transparency = math.clamp(base + DarknessManager.SURVIVOR_VIS_TRANSPARENCY, 0, 1)
            else
                part.Transparency = base
            end
        end
    end
end

function DarknessManager:_applyShadowEffects(char, hum, inDark)
    local baseSpeed = hum:GetAttribute("BaseWalkSpeed")
    if not baseSpeed then
        hum:SetAttribute("BaseWalkSpeed", hum.WalkSpeed)
        baseSpeed = hum.WalkSpeed
    end
    if inDark then
        hum.WalkSpeed = baseSpeed * DarknessManager.SHADOW_SPEED_BUFF
    else
        hum.WalkSpeed = baseSpeed
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if inDark then
                part.Transparency = DarknessManager.SHADOW_DARK_TRANSPARENCY
            else
                part.Transparency = DarknessManager.SHADOW_LIGHT_TRANSPARENCY
            end
        end
    end
end

function DarknessManager:Destroy()
    if self._heartbeat then
        self._heartbeat:Disconnect()
        self._heartbeat = nil
    end
    self.running = false
end

return DarknessManager

