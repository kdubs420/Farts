local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapVote = {}
MapVote.__index = MapVote

function MapVote.new()
    local self = setmetatable({}, MapVote)
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "MapVote"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Name = "VoteFrame"
    frame.Size = UDim2.fromOffset(250, 150)
    frame.Position = UDim2.new(0.5, -125, 0.5, -75)
    frame.BackgroundTransparency = 0.5
    frame.Parent = gui

    self.gui = gui
    self.frame = frame

    local folder = ReplicatedStorage:WaitForChild("MapVoteRemotes")
    self.voteEvent = folder:WaitForChild("VoteMap")
    self.resultEvent = folder:WaitForChild("MapVoteResult")

    self.voteEvent.OnClientEvent:Connect(function(maps)
        self:ShowOptions(maps)
    end)

    self.resultEvent.OnClientEvent:Connect(function(winner, counts)
        self:ShowResults(winner, counts)
    end)

    return self
end

function MapVote:ShowOptions(maps)
    self.frame:ClearAllChildren()
    for i, map in ipairs(maps) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.fromOffset(220, 24)
        button.Position = UDim2.new(0, 15, 0, (i - 1) * 26 + 10)
        button.Text = map
        button.Parent = self.frame
        button.MouseButton1Click:Connect(function()
            self.voteEvent:FireServer(map)
        end)
    end
end

function MapVote:ShowResults(winner, counts)
    self.frame:ClearAllChildren()
    local i = 0
    for map, count in pairs(counts) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromOffset(220, 24)
        label.Position = UDim2.new(0, 15, 0, i * 26 + 10)
        label.BackgroundTransparency = 0.5
        label.Text = map .. ": " .. count
        if map == winner then
            label.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            label.BackgroundTransparency = 0
        end
        label.Parent = self.frame
        i = i + 1
    end
end

function MapVote:Destroy()
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
    end
end

return MapVote
