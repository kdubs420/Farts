local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

local DarknessManager = {}
DarknessManager.__index = DarknessManager

DarknessManager.EXPANSION_INTERVAL = 120
DarknessManager.EXPANSION_AMOUNT = 15
DarknessManager.MAX_RADIUS = 200
DarknessManager.SHADOW_SPEED_BUFF = 1.15
DarknessManager.SURVIVOR_VIS_TRANSPARENCY = 0.4
DarknessManager.SHADOW_LIGHT_TRANSPARENCY = 0.55
DarknessManager.SHADOW_DARK_TRANSPARENCY = 0
DarknessManager.VIGNETTE_DARK_ALPHA = 0.4
DarknessManager.SIMPLE_SHADOWS = UserInputService.TouchEnabled

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
        local oldRadius = zone.radius
        zone.radius = math.min(zone.radius + DarknessManager.EXPANSION_AMOUNT, DarknessManager.MAX_RADIUS)
        self:_emitExpansionParticles(zone.center, oldRadius, zone.radius)
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
    if not DarknessManager.SIMPLE_SHADOWS then
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

    local plr = Players:GetPlayerFromCharacter(char)
    if plr then
        local gui = plr:FindFirstChildOfClass("PlayerGui")
        if gui then
            local overlay = gui:FindFirstChild("DarknessVignette")
            if not overlay then
                overlay = Instance.new("ScreenGui")
                overlay.Name = "DarknessVignette"
                overlay.IgnoreGuiInset = true
                local img = Instance.new("ImageLabel")
                img.Name = "Vignette"
                img.BackgroundTransparency = 1
                img.Image = "rbxassetid://0"
                img.ImageColor3 = Color3.new(0,0,0)
                img.Size = UDim2.fromScale(1,1)
                img.ImageTransparency = 1
                img.Parent = overlay
                overlay.Parent = gui
            end
            local img = overlay:FindFirstChild("Vignette")
            if img then
                img.ImageTransparency = inDark and DarknessManager.VIGNETTE_DARK_ALPHA or 1
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
    if not DarknessManager.SIMPLE_SHADOWS then
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
end

function DarknessManager:_emitExpansionParticles(position, fromRadius, toRadius)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.CFrame = CFrame.new(position)
    part.Parent = workspace

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://0"
    emitter.Color = ColorSequence.new(Color3.new(0,0,0))
    emitter.Lifetime = NumberRange.new(1)
    emitter.Rate = 0
    emitter.Speed = NumberRange.new(0)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, fromRadius),
        NumberSequenceKeypoint.new(1, toRadius)
    })
    emitter.Parent = part
    emitter:Emit(80)

    Debris:AddItem(part, 2)
end

function DarknessManager:Destroy()
    if self._heartbeat then
        self._heartbeat:Disconnect()
        self._heartbeat = nil
    end
    self.running = false
end

return DarknessManager

