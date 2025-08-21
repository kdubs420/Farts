local SoundService = game:GetService("SoundService")

local AudioService = {}
AudioService.__index = AudioService

local SOUND_IDS = {
    UIClick = "rbxasset://sounds/ui_click.wav",
    UIHover = "rbxasset://sounds/ui_hover.wav",
    Countdown = "rbxasset://sounds/countdown_beep.wav",
    Stingers = {
        lobby = "rbxasset://sounds/stinger_lobby.wav",
        prep = "rbxasset://sounds/stinger_prep.wav",
        hunt = "rbxasset://sounds/stinger_hunt.wav",
        endgame = "rbxasset://sounds/stinger_endgame.wav",
        results = "rbxasset://sounds/stinger_results.wav",
    },
    Portal = "rbxasset://sounds/portal_spawn.wav",
    Fanfare = "rbxasset://sounds/match_end_fanfare.wav",
}

local function play(id)
    local snd = Instance.new("Sound")
    snd.SoundId = id
    snd.Parent = SoundService
    snd:Play()
    snd.Ended:Connect(function()
        snd:Destroy()
    end)
    return snd
end

function AudioService:PlayClick()
    play(SOUND_IDS.UIClick)
end

function AudioService:PlayHover()
    play(SOUND_IDS.UIHover)
end

function AudioService:PlayCountdown(count)
    count = count or 3
    for i = 0, count - 1 do
        task.delay(i, function()
            play(SOUND_IDS.Countdown)
        end)
    end
end

function AudioService:PlayStinger(phase)
    local id = SOUND_IDS.Stingers[phase]
    if id then
        play(id)
    end
end

function AudioService:PlayPortalFanfare()
    play(SOUND_IDS.Portal)
end

function AudioService:PlayMatchEndFanfare()
    play(SOUND_IDS.Fanfare)
end

return setmetatable({}, AudioService)
