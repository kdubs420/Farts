local Spawns = {}
Spawns.__index = Spawns

function Spawns.new()
    local self = setmetatable({}, Spawns)
    local root = workspace:WaitForChild("Spawns")
    self.survivorFolder = root:WaitForChild("Survivor")
    self.shadowFolder = root:WaitForChild("Shadow")
    return self
end

local function choose(folder)
    local children = folder:GetChildren()
    if #children == 0 then
        return nil
    end
    return children[math.random(1, #children)]
end

function Spawns:Spawn(plr, role)
    local folder = role == "Shadow" and self.shadowFolder or self.survivorFolder
    local point = choose(folder)
    if not point then return end
    plr:LoadCharacter()
    local char = plr.Character
    if not char then return end
    local cf = point.CFrame + Vector3.new(0, 3, 0)
    char:PivotTo(cf)
    plr:SetAttribute("Role", role)
end

return Spawns
