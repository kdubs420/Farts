local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local Save = {}
Save.__index = Save

local STORE = DataStoreService:GetDataStore("ShadowTagPlayerData")
local RETRIES = 5

local function retry(promise)
    local lastErr
    for i = 1, RETRIES do
        local ok, result = pcall(promise)
        if ok then
            return result
        end
        lastErr = result
        task.wait(2 ^ i)
    end
    warn("DataStore failure: " .. tostring(lastErr))
    return nil
end

function Save.load(plr)
    local key = "p_" .. plr.UserId
    local data = retry(function()
        return STORE:GetAsync(key)
    end) or {}
    plr:SetAttribute("Coins", data.Coins or 0)
    plr:SetAttribute("Essence", data.Essence or 0)
    plr:SetAttribute("Cosmetics", data.Cosmetics or {})
end

function Save.save(plr)
    local key = "p_" .. plr.UserId
    local data = {
        Coins = plr:GetAttribute("Coins"),
        Essence = plr:GetAttribute("Essence"),
        Cosmetics = plr:GetAttribute("Cosmetics"),
    }
    retry(function()
        STORE:SetAsync(key, data)
    end)
end

function Save.init()
    Players.PlayerAdded:Connect(Save.load)
    Players.PlayerRemoving:Connect(Save.save)
    game:BindToClose(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            Save.save(plr)
        end
    end)
end

return Save
