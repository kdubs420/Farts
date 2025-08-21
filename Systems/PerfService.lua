local PerfService = {}

PerfService.MAX_PARTS = 150
PerfService.MAX_FLASHLIGHT_RAYCASTS = 10

function PerfService.ProfileMap(model)
    local count = 0
    for _, inst in ipairs(model:GetDescendants()) do
        if inst:IsA("BasePart") then
            count = count + 1
        end
    end
    if count > PerfService.MAX_PARTS then
        warn(string.format("Map part count %d exceeds budget %d", count, PerfService.MAX_PARTS))
    end
    return count
end

return PerfService
