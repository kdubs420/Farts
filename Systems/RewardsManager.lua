local RewardsManager = {}
RewardsManager.__index = RewardsManager

local REWARDS = {
    SurvivePerMin = 6,
    EscapeBonus = 40,
    Assist = 6,
    Tag = 10,
    MultiTag = 6,
    AmbushTag = 8,
    Wipe = 40,
}

local ESSENCE_CHANCE = 0.06
local random = Random.new()

function RewardsManager.new()
    local self = setmetatable({}, RewardsManager)
    self.startTime = 0
    self.playerStats = {}
    return self
end

function RewardsManager:BeginMatch(roles)
    self.startTime = os.clock()
    self.playerStats = {}
    for plr, role in pairs(roles) do
        self.playerStats[plr] = {
            role = role,
            assists = 0,
            tags = 0,
            multi = 0,
            ambush = 0,
            escaped = false,
            eliminatedAt = nil,
            wipe = false,
        }
    end
end

function RewardsManager:RecordAssist(plr)
    local stats = self.playerStats[plr]
    if stats then
        stats.assists = stats.assists + 1
    end
end

function RewardsManager:RecordTag(plr, isMulti, isAmbush)
    local stats = self.playerStats[plr]
    if stats then
        stats.tags = stats.tags + 1
        if isMulti then
            stats.multi = stats.multi + 1
        end
        if isAmbush then
            stats.ambush = stats.ambush + 1
        end
    end
end

function RewardsManager:RecordEscape(plr)
    local stats = self.playerStats[plr]
    if stats then
        stats.escaped = true
        stats.eliminatedAt = os.clock()
    end
end

function RewardsManager:RecordElimination(plr)
    local stats = self.playerStats[plr]
    if stats and not stats.eliminatedAt then
        stats.eliminatedAt = os.clock()
    end
end

function RewardsManager:RecordWipe(plr)
    local stats = self.playerStats[plr]
    if stats then
        stats.wipe = true
    end
end

function RewardsManager:_award(plr, coins, essence)
    local currentCoins = plr:GetAttribute("Coins") or 0
    plr:SetAttribute("Coins", currentCoins + coins)
    local currentEssence = plr:GetAttribute("Essence") or 0
    plr:SetAttribute("Essence", currentEssence + essence)
end

function RewardsManager:Distribute(winningTeam)
    for plr, stats in pairs(self.playerStats) do
        local coins = 0
        if stats.role == "Survivor" then
            local endTime = stats.eliminatedAt or os.clock()
            local minutes = math.floor((endTime - self.startTime) / 60)
            coins = coins + minutes * REWARDS.SurvivePerMin
            if stats.escaped then
                coins = coins + REWARDS.EscapeBonus
            end
            coins = coins + stats.assists * REWARDS.Assist
        else
            coins = coins + stats.tags * REWARDS.Tag
            coins = coins + stats.multi * REWARDS.MultiTag
            coins = coins + stats.ambush * REWARDS.AmbushTag
            if stats.wipe or winningTeam == "Shadows" then
                coins = coins + REWARDS.Wipe
            end
        end
        local essence = random:NextNumber() < ESSENCE_CHANCE and 1 or 0
        self:_award(plr, coins, essence)
    end
end

return RewardsManager

