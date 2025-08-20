local Players = game:GetService("Players")

local CurrencyDisplay = {}
CurrencyDisplay.__index = CurrencyDisplay

function CurrencyDisplay.new()
    local self = setmetatable({}, CurrencyDisplay)
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "CurrencyDisplay"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Name = "CoinsLabel"
    coinsLabel.Size = UDim2.fromOffset(150, 24)
    coinsLabel.Position = UDim2.new(0, 10, 0, 10)
    coinsLabel.BackgroundTransparency = 0.5
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
    coinsLabel.Parent = gui

    local essenceLabel = Instance.new("TextLabel")
    essenceLabel.Name = "EssenceLabel"
    essenceLabel.Size = UDim2.fromOffset(150, 24)
    essenceLabel.Position = UDim2.new(0, 10, 0, 40)
    essenceLabel.BackgroundTransparency = 0.5
    essenceLabel.TextXAlignment = Enum.TextXAlignment.Left
    essenceLabel.Parent = gui

    self.gui = gui
    self.player = player
    self.coinsLabel = coinsLabel
    self.essenceLabel = essenceLabel

    self:_update()
    player:GetAttributeChangedSignal("Coins"):Connect(function()
        self:_update()
    end)
    player:GetAttributeChangedSignal("Essence"):Connect(function()
        self:_update()
    end)

    return self
end

function CurrencyDisplay:_update()
    local coins = self.player:GetAttribute("Coins") or 0
    local essence = self.player:GetAttribute("Essence") or 0
    self.coinsLabel.Text = "Coins: " .. coins
    self.essenceLabel.Text = "Essence: " .. essence
end

function CurrencyDisplay:Destroy()
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
    end
end

return CurrencyDisplay

