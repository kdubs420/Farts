local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MapVoteService = {}
MapVoteService.__index = MapVoteService

local maps = {
    "SteelhideDepot",
    "BlackpineReserve",
    "StVerityWing",
    "HarborlineDistrict",
}

local function find(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            return i
        end
    end
    return nil
end

function MapVoteService.new()
    local self = setmetatable({}, MapVoteService)
    self.votes = {}
    self.maps = maps

    local folder = ReplicatedStorage:FindFirstChild("MapVoteRemotes")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "MapVoteRemotes"
        folder.Parent = ReplicatedStorage
    end

    self.voteEvent = folder:FindFirstChild("VoteMap")
    if not self.voteEvent then
        self.voteEvent = Instance.new("RemoteEvent")
        self.voteEvent.Name = "VoteMap"
        self.voteEvent.Parent = folder
    end

    self.resultEvent = folder:FindFirstChild("MapVoteResult")
    if not self.resultEvent then
        self.resultEvent = Instance.new("RemoteEvent")
        self.resultEvent.Name = "MapVoteResult"
        self.resultEvent.Parent = folder
    end

    self.voteEvent.OnServerEvent:Connect(function(player, map)
        if find(self.maps, map) then
            self.votes[player] = map
        end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        self.votes[plr] = nil
    end)

    return self
end

function MapVoteService:Start(duration, callback)
    self.votes = {}
    self.voteEvent:FireAllClients(self.maps, duration)
    task.delay(duration, function()
        local counts = {}
        for _, map in ipairs(self.maps) do
            counts[map] = 0
        end
        for _, map in pairs(self.votes) do
            counts[map] = counts[map] + 1
        end
        local winner = self.maps[1]
        for map, count in pairs(counts) do
            if count > counts[winner] then
                winner = map
            end
        end
        self.resultEvent:FireAllClients(winner, counts)
        if callback then
            callback(winner, counts)
        end
    end)
end

return MapVoteService
