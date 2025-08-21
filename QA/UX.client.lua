local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")

local insets = GuiService:GetSafeAreaInsets()
local camera = workspace.CurrentCamera
local viewport = camera.ViewportSize

local function checkGui(gui)
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("GuiObject") then
            local pos = obj.AbsolutePosition
            local size = obj.AbsoluteSize
            assert(pos.X >= insets.X, obj.Name .. " left unsafe")
            assert(pos.Y >= insets.Y, obj.Name .. " top unsafe")
            assert(pos.X + size.X <= viewport.X - insets.Z, obj.Name .. " right unsafe")
            assert(pos.Y + size.Y <= viewport.Y - insets.W, obj.Name .. " bottom unsafe")
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                assert(obj.TextScaled or obj.TextSize >= 14, obj.Name .. " font too small")
            end
        end
    end
end

for _, screenGui in ipairs(StarterGui:GetChildren()) do
    if screenGui:IsA("ScreenGui") then
        checkGui(screenGui)
    end
end

print("[UX] passed")
