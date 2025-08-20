local Players = game:GetService("Players")

local CosmeticLoadout = {}
CosmeticLoadout.__index = CosmeticLoadout

function CosmeticLoadout.new(manager, role)
    local self = setmetatable({}, CosmeticLoadout)
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "CosmeticLoadout"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Name = "CosmeticFrame"
    frame.Size = UDim2.fromOffset(200, 200)
    frame.Position = UDim2.new(1, -210, 0, 10)
    frame.BackgroundTransparency = 0.5
    frame.Parent = gui

    self.gui = gui
    self.frame = frame
    self.player = player
    self.manager = manager
    self.role = role

    self:Refresh()
    return self
end

function CosmeticLoadout:Refresh()
    self.frame:ClearAllChildren()
    local cosmetics = self.manager:GetOwned(self.player, self.role)
    for i, name in ipairs(cosmetics) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.fromOffset(180, 24)
        button.Position = UDim2.new(0, 10, 0, (i - 1) * 26)
        button.Text = name
        button.Parent = self.frame
        button.MouseButton1Click:Connect(function()
            self.manager:Equip(self.player, self.role, name)
        end)
    end
end

function CosmeticLoadout:Destroy()
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
    end
end

return CosmeticLoadout

