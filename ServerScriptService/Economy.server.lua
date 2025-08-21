local RewardsManager = require(game:GetService("ServerScriptService").Parent.Systems.RewardsManager)

local Economy = {}
Economy.__index = Economy

function Economy.new()
    local self = setmetatable({}, Economy)
    self.manager = RewardsManager.new()
    return self
end

function Economy:BeginMatch(roles)
    self.manager:BeginMatch(roles)
end

function Economy:RecordTag(plr, isMulti, isAmbush)
    self.manager:RecordTag(plr, isMulti, isAmbush)
end

function Economy:RecordAssist(plr)
    self.manager:RecordAssist(plr)
end

function Economy:RecordEscape(plr)
    self.manager:RecordEscape(plr)
end

function Economy:RecordElimination(plr)
    self.manager:RecordElimination(plr)
end

function Economy:RecordWipe(plr)
    self.manager:RecordWipe(plr)
end

function Economy:Distribute(winningTeam)
    self.manager:Distribute(winningTeam)
end

return Economy
