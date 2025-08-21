local CollectionService = game:GetService("CollectionService")

local Interact = {}
Interact.__index = Interact

function Interact.new()
    local self = setmetatable({}, Interact)
    self:_initTagged()
    return self
end

function Interact:_hookPrompt(inst, handler)
    local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt")
    if prompt then
        prompt.Triggered:Connect(function(plr)
            handler(self, plr, inst)
        end)
    end
end

function Interact:_initTagged()
    for _, station in ipairs(CollectionService:GetTagged("RechargeStation")) do
        self:_hookPrompt(station, self._recharge)
    end
    for _, door in ipairs(CollectionService:GetTagged("Door")) do
        self:_hookPrompt(door, self._openDoor)
    end
end

function Interact:_recharge(plr, station)
    local char = plr.Character
    if not char then return end
    local tool = char:FindFirstChild("Flashlight")
    if tool then
        tool:SetAttribute("Battery", 100)
    end
end

function Interact:_openDoor(plr, door)
    if door:GetAttribute("Open") then return end
    door:SetAttribute("Open", true)
    local hinge = door:FindFirstChild("Hinge")
    if hinge then
        hinge.C0 = hinge.C0 * CFrame.Angles(0, math.rad(90), 0)
    else
        door:PivotTo(door.CFrame * CFrame.Angles(0, math.rad(90), 0))
    end
end

return Interact
