local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SurvivorHUD = {}
SurvivorHUD.__index = SurvivorHUD

local PING_DURATION = 4
local LOW_BATTERY_THRESHOLD = 15 -- seconds remaining

local function formatTime(t)
    local m = math.floor(t / 60)
    local s = math.floor(t % 60)
    return string.format("%d:%02d", m, s)
end

function SurvivorHUD.new(sprint, flashlight, matchTime)
    local self = setmetatable({}, SurvivorHUD)
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "SurvivorHUD"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    -- stamina bar
    local staminaFrame = Instance.new("Frame")
    staminaFrame.Name = "Stamina"
    staminaFrame.Size = UDim2.new(0, 200, 0, 20)
    staminaFrame.Position = UDim2.new(0, 10, 1, -30)
    staminaFrame.BackgroundTransparency = 0.5
    staminaFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    staminaFrame.Parent = gui
    local staminaBar = Instance.new("Frame")
    staminaBar.Name = "Bar"
    staminaBar.Size = UDim2.new(1, 0, 1, 0)
    staminaBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    staminaBar.Parent = staminaFrame

    -- battery bar
    local batteryFrame = Instance.new("Frame")
    batteryFrame.Name = "Battery"
    batteryFrame.Size = UDim2.new(0, 200, 0, 20)
    batteryFrame.Position = UDim2.new(0, 10, 1, -60)
    batteryFrame.BackgroundTransparency = 0.5
    batteryFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    batteryFrame.Parent = gui
    local batteryBar = Instance.new("Frame")
    batteryBar.Name = "Bar"
    batteryBar.Size = UDim2.new(1, 0, 1, 0)
    batteryBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    batteryBar.Parent = batteryFrame

    -- low battery alert
    local lowLabel = Instance.new("TextLabel")
    lowLabel.Name = "LowBattery"
    lowLabel.Size = UDim2.new(1, 0, 0, 30)
    lowLabel.Position = UDim2.new(0, 0, 0.5, -15)
    lowLabel.BackgroundTransparency = 1
    lowLabel.Text = "LOW BATTERY"
    lowLabel.TextColor3 = Color3.new(1, 0, 0)
    lowLabel.TextScaled = true
    lowLabel.Visible = false
    lowLabel.Parent = gui
    local lowSound = Instance.new("Sound")
    lowSound.SoundId = "rbxassetid://0"
    lowSound.Volume = 0.8
    lowSound.Parent = lowLabel

    -- match timer
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "MatchTimer"
    timerLabel.Size = UDim2.new(0, 120, 0, 30)
    timerLabel.Position = UDim2.new(0.5, -60, 0, 10)
    timerLabel.BackgroundTransparency = 0.5
    timerLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    timerLabel.TextColor3 = Color3.new(1, 1, 1)
    timerLabel.TextScaled = true
    timerLabel.Parent = gui

    -- compass container
    local compass = Instance.new("Frame")
    compass.Name = "Compass"
    compass.Size = UDim2.new(0, 300, 0, 20)
    compass.Position = UDim2.new(0.5, -150, 0, 50)
    compass.BackgroundTransparency = 1
    compass.Parent = gui

    self.gui = gui
    self.staminaBar = staminaBar
    self.batteryBar = batteryBar
    self.lowLabel = lowLabel
    self.lowSound = lowSound
    self.timerLabel = timerLabel
    self.compass = compass
    self.sprint = sprint
    self.flashlight = flashlight
    self.matchTime = matchTime
    self.lowTriggered = false
    self.pings = {}

    local pingEvent = ReplicatedStorage:FindFirstChild("TeammatePing")
    if pingEvent and pingEvent:IsA("RemoteEvent") then
        pingEvent.OnClientEvent:Connect(function(pos)
            self:addPing(pos)
        end)
    end

    self._conn = RunService.RenderStepped:Connect(function(dt)
        self:update(dt)
    end)

    return self
end

function SurvivorHUD:addPing(pos)
    local ping = Instance.new("ImageLabel")
    ping.Image = "rbxassetid://0"
    ping.Size = UDim2.fromOffset(16, 16)
    ping.BackgroundTransparency = 1
    ping.Parent = self.compass
    table.insert(self.pings, {gui = ping, pos = pos, age = 0})
end

function SurvivorHUD:update(dt)
    if self.sprint then
        local ratio = self.sprint.stamina / self.sprint.MAX_STAMINA
        self.staminaBar.Size = UDim2.new(ratio, 0, 1, 0)
    end
    if self.flashlight then
        local ratio = self.flashlight.battery / self.flashlight.MAX_BATTERY
        self.batteryBar.Size = UDim2.new(ratio, 0, 1, 0)
        if self.flashlight.battery <= LOW_BATTERY_THRESHOLD then
            if not self.lowTriggered then
                self.lowLabel.Visible = true
                self.lowSound:Play()
                self.lowTriggered = true
            end
        else
            self.lowLabel.Visible = false
            self.lowTriggered = false
        end
    end
    if self.matchTime then
        self.matchTime = math.max(0, self.matchTime - dt)
        self.timerLabel.Text = formatTime(self.matchTime)
    end

    local camera = workspace.CurrentCamera
    if camera then
        local lookAngle = math.atan2(camera.CFrame.LookVector.X, camera.CFrame.LookVector.Z)
        for i = #self.pings, 1, -1 do
            local p = self.pings[i]
            p.age = p.age + dt
            if p.age > PING_DURATION then
                p.gui:Destroy()
                table.remove(self.pings, i)
            else
                local dir = p.pos - camera.CFrame.Position
                local angle = math.atan2(dir.X, dir.Z) - lookAngle
                angle = (angle + math.pi) % (2 * math.pi) - math.pi
                p.gui.Position = UDim2.new(0.5 + angle / (2 * math.pi), -8, 0, 0)
            end
        end
    end
end

function SurvivorHUD:Destroy()
    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end
    for _, p in ipairs(self.pings) do
        p.gui:Destroy()
    end
    self.pings = {}
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
    end
end

return SurvivorHUD

