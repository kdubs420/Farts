local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ShadowHUD = {}
ShadowHUD.__index = ShadowHUD

function ShadowHUD.new(dash, surge, darkness)
    local self = setmetatable({}, ShadowHUD)

    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "ShadowHUD"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local dashLabel = Instance.new("TextLabel")
    dashLabel.Name = "DashCooldown"
    dashLabel.Size = UDim2.fromOffset(140, 24)
    dashLabel.Position = UDim2.new(0, 10, 1, -58)
    dashLabel.BackgroundTransparency = 0.5
    dashLabel.TextXAlignment = Enum.TextXAlignment.Left
    dashLabel.Parent = gui

    local surgeLabel = Instance.new("TextLabel")
    surgeLabel.Name = "SurgeCooldown"
    surgeLabel.Size = UDim2.fromOffset(140, 24)
    surgeLabel.Position = UDim2.new(0, 10, 1, -30)
    surgeLabel.BackgroundTransparency = 0.5
    surgeLabel.TextXAlignment = Enum.TextXAlignment.Left
    surgeLabel.Parent = gui

    local meterBg = Instance.new("Frame")
    meterBg.Name = "DarknessMeter"
    meterBg.Size = UDim2.fromOffset(200, 20)
    meterBg.Position = UDim2.new(0.5, -100, 0, 10)
    meterBg.BackgroundTransparency = 0.5
    meterBg.Parent = gui

    local meterFill = Instance.new("Frame")
    meterFill.Name = "Fill"
    meterFill.Size = UDim2.fromScale(0, 1)
    meterFill.BackgroundColor3 = Color3.new(0, 0, 0)
    meterFill.Parent = meterBg

    local meterText = Instance.new("TextLabel")
    meterText.Name = "Label"
    meterText.Size = UDim2.fromScale(1, 1)
    meterText.BackgroundTransparency = 1
    meterText.Text = "Darkness 0%"
    meterText.Parent = meterBg

    local survivorLabel = Instance.new("TextLabel")
    survivorLabel.Name = "SurvivorCount"
    survivorLabel.Size = UDim2.fromOffset(150, 24)
    survivorLabel.Position = UDim2.new(1, -160, 0, 10)
    survivorLabel.BackgroundTransparency = 0.5
    survivorLabel.TextXAlignment = Enum.TextXAlignment.Right
    survivorLabel.Parent = gui

    self.gui = gui
    self.dashLabel = dashLabel
    self.surgeLabel = surgeLabel
    self.meterFill = meterFill
    self.meterText = meterText
    self.survivorLabel = survivorLabel
    self.dash = dash
    self.surge = surge
    self.darkness = darkness

    self._conn = RunService.Heartbeat:Connect(function()
        self:_update()
    end)

    return self
end

function ShadowHUD:_update()
    if self.dash then
        local remaining = math.max(0, (self.dash.COOLDOWN or 0) - (os.clock() - (self.dash.lastUsed or 0)))
        self.dashLabel.Text = string.format("Dash: %.1fs", remaining)
    end
    if self.surge then
        local remaining = math.max(0, (self.surge.COOLDOWN or 0) - (os.clock() - (self.surge.lastUsed or 0)))
        self.surgeLabel.Text = string.format("Surge: %.1fs", remaining)
    end
    if self.darkness and self.darkness.zones and self.darkness.MAX_RADIUS then
        local radius = 0
        if self.darkness.zones[1] then
            radius = self.darkness.zones[1].radius or 0
        end
        local ratio = math.clamp(radius / self.darkness.MAX_RADIUS, 0, 1)
        self.meterFill.Size = UDim2.fromScale(ratio, 1)
        self.meterText.Text = string.format("Darkness %d%%", math.floor(ratio * 100 + 0.5))
    end
    local survivors = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr:GetAttribute("Role") == "Survivor" then
            survivors = survivors + 1
        end
    end
    self.survivorLabel.Text = "Survivors: " .. survivors
end

function ShadowHUD:Destroy()
    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
    end
end

return ShadowHUD

