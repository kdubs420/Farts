local Players = game:GetService("Players")

local CosmeticsManager = {}
CosmeticsManager.__index = CosmeticsManager

local function contains(t, v)
    for _, item in ipairs(t) do
        if item == v then
            return true
        end
    end
    return false
end

function CosmeticsManager.new()
    local self = setmetatable({}, CosmeticsManager)
    self.data = {}
    Players.PlayerRemoving:Connect(function(plr)
        self.data[plr] = nil
    end)
    return self
end

function CosmeticsManager:_get(plr)
    local data = self.data[plr]
    if not data then
        data = {
            Owned = {Survivor = {}, Shadow = {}},
            Equipped = {Survivor = nil, Shadow = nil}
        }
        self.data[plr] = data
    end
    return data
end

function CosmeticsManager:Unlock(plr, role, cosmetic)
    local data = self:_get(plr)
    local list = data.Owned[role]
    if not contains(list, cosmetic) then
        table.insert(list, cosmetic)
    end
end

function CosmeticsManager:Equip(plr, role, cosmetic)
    local data = self:_get(plr)
    local list = data.Owned[role]
    if contains(list, cosmetic) then
        data.Equipped[role] = cosmetic
        plr:SetAttribute(role.."Cosmetic", cosmetic)
    end
end

function CosmeticsManager:GetOwned(plr, role)
    local data = self:_get(plr)
    return data.Owned[role]
end

function CosmeticsManager:GetEquipped(plr, role)
    local data = self:_get(plr)
    return data.Equipped[role]
end

return CosmeticsManager

