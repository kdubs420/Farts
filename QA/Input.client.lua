local ContextActionService = game:GetService("ContextActionService")

local mappings = {
    Sprint = {Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL2, Enum.UserInputType.Touch},
    Push = {Enum.KeyCode.E, Enum.KeyCode.ButtonX, Enum.UserInputType.Touch},
    Ping = {Enum.KeyCode.Q, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1},
}

for action, inputs in pairs(mappings) do
    ContextActionService:BindAction(action, function() end, false, table.unpack(inputs))
    for _, input in ipairs(inputs) do
        local bound = ContextActionService:GetBoundActionName(input)
        assert(bound == action, action .. " not bound for " .. tostring(input))
    end
    ContextActionService:UnbindAction(action)
end

print("[INPUT] passed")
