local Players = game:GetService("Players")
local RewardsManager = require(script.Parent.Parent.Systems.RewardsManager)
local CosmeticsManager = require(script.Parent.Parent.Systems.CosmeticsManager)
local MapVoteService = require(script.Parent.Parent.Systems.MapVoteService)
local AudioService = require(script.Parent.Parent.Systems.AudioService)

local MatchController = {}
MatchController.__index = MatchController

local function round(n)
    return n >= 0 and math.floor(n + 0.5) or math.ceil(n - 0.5)
end

local MIN_PLAYERS = 6
local LOBBY_DURATION = 15
local PREPARATION_DURATION = 20
local HUNT_MIN_DURATION = 360
local ENDGAME_DURATION = 60
local RESULTS_DURATION = 10

local SHADOW_PER_SURVIVOR_MIN = 1/6
local SHADOW_PER_SURVIVOR_MAX = 1/4

local LobbyPhase = {}
function LobbyPhase:enter(controller)
    AudioService:PlayStinger("lobby")
    local function waitForPlayers()
        local playerList = Players:GetPlayers()
        if #playerList >= MIN_PLAYERS then
            controller:startMapVote()
            controller:schedule(LOBBY_DURATION - 3, function()
                AudioService:PlayCountdown(3)
            end)
            controller:schedule(LOBBY_DURATION, function()
                controller:assignRoles()
                controller:transitionTo(PreparationPhase)
            end)
        else
            controller:schedule(1, waitForPlayers)
        end
    end
    waitForPlayers()
end

local PreparationPhase = {}
function PreparationPhase:enter(controller)
    AudioService:PlayStinger("prep")
    controller:schedule(PREPARATION_DURATION - 3, function()
        AudioService:PlayCountdown(3)
    end)
    controller:schedule(PREPARATION_DURATION, function()
        controller:transitionTo(HuntPhase)
    end)
end

local HuntPhase = {}
function HuntPhase:enter(controller)
    AudioService:PlayStinger("hunt")
    controller.RewardsManager:BeginMatch(controller.roles)
    controller:triggerDarkness()
    controller:schedule(HUNT_MIN_DURATION - 3, function()
        AudioService:PlayCountdown(3)
    end)
    controller:schedule(HUNT_MIN_DURATION, function()
        controller:transitionTo(EndgamePhase)
    end)
end

local EndgamePhase = {}
function EndgamePhase:enter(controller)
    AudioService:PlayStinger("endgame")
    controller:spawnPortal()
    controller:schedule(ENDGAME_DURATION - 3, function()
        AudioService:PlayCountdown(3)
    end)
    controller:schedule(ENDGAME_DURATION, function()
        controller:transitionTo(ResultsPhase)
    end)
end

local ResultsPhase = {}
function ResultsPhase:enter(controller)
    AudioService:PlayStinger("results")
    controller:calculateResults()
    AudioService:PlayMatchEndFanfare()
    controller.RewardsManager:Distribute(controller.winningTeam)
    controller:schedule(RESULTS_DURATION, function()
        controller:transitionTo(LobbyPhase)
    end)
end

function MatchController.new()
    local self = setmetatable({}, MatchController)
    self.phase = nil
    self.roles = {}
    self.RewardsManager = RewardsManager.new()
    self.CosmeticsManager = CosmeticsManager.new()
    self.MapVoteService = MapVoteService.new()
    return self
end

function MatchController:start()
    self:transitionTo(LobbyPhase)
end

function MatchController:transitionTo(phase)
    self.phase = phase
    phase:enter(self)
end

function MatchController:schedule(duration, callback)
    task.delay(duration, callback)
end

function MatchController:startMapVote()
    if self.MapVoteService then
        self.MapVoteService:Start(LOBBY_DURATION, function(winner)
            self.selectedMap = winner
        end)
    end
end

function MatchController:rollShadows(players, target)
    local pool = {}
    for i, plr in ipairs(players) do
        pool[i] = plr
    end
    for i = #pool, 2, -1 do
        local j = math.random(i)
        pool[i], pool[j] = pool[j], pool[i]
    end
    local shadows = {}
    for i = 1, target do
        shadows[pool[i]] = true
    end
    return shadows
end

function MatchController:assignRoles()
    local players = Players:GetPlayers()
    local total = #players
    local minShadows = math.max(1, round(total * SHADOW_PER_SURVIVOR_MIN))
    local maxShadows = math.max(minShadows, round(total * SHADOW_PER_SURVIVOR_MAX))
    local targetShadows = math.clamp(round(total / 5), minShadows, maxShadows)

    local shadowMap = self:rollShadows(players, targetShadows)

    self.roles = {}
    for _, plr in ipairs(players) do
        local role = shadowMap[plr] and "Shadow" or "Survivor"
        self.roles[plr] = role
        if plr.SetAttribute then
            plr:SetAttribute("Role", role)
        end
    end
end

function MatchController:triggerDarkness()
    self.darknessActive = true
    if self.DarknessService then
        self.DarknessService:BeginExpansion()
    end
end

function MatchController:spawnPortal()
    self.portalSpawned = true
    AudioService:PlayPortalFanfare()
    if self.PortalService then
        self.PortalService:Spawn()
    end
end

function MatchController:calculateResults()
    local survivors = 0
    for _, role in pairs(self.roles) do
        if role == "Survivor" then
            survivors = survivors + 1
        end
    end
    self.winningTeam = survivors > 0 and "Survivors" or "Shadows"
    if self.ResultsService then
        self.ResultsService:Announce(self.winningTeam)
    end
end

return MatchController
