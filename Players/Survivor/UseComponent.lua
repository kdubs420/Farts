local ContextActionService = game:GetService("ContextActionService")

local UseComponent = {}
UseComponent.__index = UseComponent

local ACTION_NAME = "SurvivorUse"
local INTERACT_RANGE = 5

function UseComponent.new(character, deps)
    local self = setmetatable({}, UseComponent)
    self.character = character
    self.hrp = character:WaitForChild("HumanoidRootPart")
    self.flashlight = deps and deps.flashlight
    ContextActionService:BindAction(ACTION_NAME, function(_, state)
        if state == Enum.UserInputState.Begin then
            self:Use()
        end
    end, true, Enum.KeyCode.E, Enum.KeyCode.ButtonX)
    return self
end

function UseComponent:Use()
    local origin = self.hrp.Position
    local look = self.hrp.CFrame.LookVector
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {self.character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, look * INTERACT_RANGE, params)
    if result and result.Instance then
        local obj = result.Instance
        local useType = obj:GetAttribute("UseType")
        if useType == "Door" then
            self:useDoor(obj)
        elseif useType == "Switch" then
            self:useSwitch(obj)
        elseif useType == "Battery" or useType == "Recharge" then
            if self.flashlight then
                self.flashlight:startRecharge(obj)
            end
        end
    end
end

function UseComponent:useDoor(part)
    local hinge = part.Parent:FindFirstChildWhichIsA("HingeConstraint", true)
    if hinge then
        local target = hinge.TargetAngle == 0 and 90 or 0
        hinge.TargetAngle = target
    end
end

function UseComponent:useSwitch(part)
    local event = part:FindFirstChildWhichIsA("BindableEvent")
    if event then
        event:Fire()
    end
end

function UseComponent:Destroy()
    ContextActionService:UnbindAction(ACTION_NAME)
end

return UseComponent

