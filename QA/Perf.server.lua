local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local maxPlayers = 12
for i = 1, maxPlayers do
    local p = Instance.new("Player")
    p.Name = "Test" .. i
    p.Parent = Players
end

local samples = {}
local connection
connection = RunService.Heartbeat:Connect(function(dt)
    table.insert(samples, dt)
    if #samples >= 60 then
        connection:Disconnect()
    end
end)

while connection.Connected do
    RunService.Heartbeat:Wait()
end

local total = 0
for _, dt in ipairs(samples) do
    total = total + dt
end
local avg = total / #samples
assert(avg < 1/30, "server step exceeds budget")

for _, plr in ipairs(Players:GetPlayers()) do
    plr:Destroy()
end

print("[PERF] passed")
