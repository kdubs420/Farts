local Players = game:GetService("Players")

local CosmeticLoadout = {}
CosmeticLoadout.__index = CosmeticLoadout

function CosmeticLoadout.new(manager)
    local self = setmetatable({}, CosmeticLoadout)
    local player = Players.LocalPlayer

    local gui = Instance.new("ScreenGui")
    gui.Name = "CosmeticLoadout"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local container = Instance.new("Frame")
    container.Name = "CosmeticContainer"
    container.Size = UDim2.fromOffset(420, 220)
    container.Position = UDim2.new(1, -430, 0, 10)
    container.BackgroundTransparency = 0.5
    container.Parent = gui

    self.gui = gui
    self.container = container
    self.player = player
    self.manager = manager

    self:Refresh()
    return self
end

function CosmeticLoadout:Refresh()
    self.container:ClearAllChildren()
    local roles = {"Survivor", "Shadow"}
    for rIndex, role in ipairs(roles) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.fromOffset(200, 200)
        frame.Position = UDim2.new(0, (rIndex - 1) * 210, 0, 10)
        frame.BackgroundTransparency = 0.3
        frame.Parent = self.container

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromOffset(180, 24)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = role
        label.Parent = frame

        local cosmetics = self.manager:GetOwned(self.player, role)
        for i, name in ipairs(cosmetics) do
            local button = Instance.new("TextButton")
            button.Size = UDim2.fromOffset(180, 24)
            button.Position = UDim2.new(0, 10, 0, i * 26)
            button.Text = name
            button.Parent = frame
            button.MouseButton1Click:Connect(function()
                self.manager:Equip(self.player, role, name)
            end)
        end
    end
end

function CosmeticLoadout:Destroy()
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
    end
end

return CosmeticLoadout
