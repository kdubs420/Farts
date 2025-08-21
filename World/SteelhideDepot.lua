local Map = {}
Map.__index = Map

Map.MAX_PARTS = 150

function Map.new(parent)
    local self = setmetatable({}, Map)
    self.model = Instance.new("Model")
    self.model.Name = "SteelhideDepot"
    self.model.Parent = parent or workspace
    self.partCount = 0
    return self
end

function Map:_addPart(part)
    part.Parent = self.model
    self.partCount = self.partCount + 1
end

function Map:_createCorridor(cframe, size)
    local corridor = Instance.new("Part")
    corridor.Name = "Corridor"
    corridor.Anchored = true
    corridor.Material = Enum.Material.Concrete
    corridor.Color = Color3.new(0.3,0.3,0.3)
    corridor.Size = size
    corridor.CFrame = cframe
    self:_addPart(corridor)
end

function Map:_createSwitchLight(position)
    local lightPart = Instance.new("Part")
    lightPart.Name = "Light"
    lightPart.Anchored = true
    lightPart.CanCollide = false
    lightPart.Transparency = 1
    lightPart.Size = Vector3.new(1,1,1)
    lightPart.CFrame = CFrame.new(position)
    self:_addPart(lightPart)

    local light = Instance.new("PointLight")
    light.Brightness = 2
    light.Range = 25
    light.Enabled = false
    light.Parent = lightPart

    local click = Instance.new("ClickDetector")
    click.Parent = lightPart
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxasset://sounds/switch_click.wav"
    sound.Parent = lightPart
    click.MouseClick:Connect(function()
        light.Enabled = not light.Enabled
        sound:Play()
    end)
end

function Map:_createRechargeStation(position)
    local station = Instance.new("Part")
    station.Name = "RechargeStation"
    station.Anchored = true
    station.Material = Enum.Material.Metal
    station.Size = Vector3.new(4,2,4)
    station.CFrame = CFrame.new(position)
    self:_addPart(station)

    local light = Instance.new("PointLight")
    light.Color = Color3.new(0.9,0.9,1)
    light.Brightness = 1.5
    light.Range = 12
    light.Parent = station

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Recharge"
    prompt.HoldDuration = 1
    prompt.Parent = station
    prompt.Triggered:Connect(function(plr)
        local backpack = plr:FindFirstChildOfClass("Backpack")
        if backpack then
            local flashlight = backpack:FindFirstChild("Flashlight")
            if flashlight then
                flashlight:SetAttribute("Battery", 90)
            end
        end
    end)
end

function Map:_createAmbientSound(position)
    local emitter = Instance.new("Part")
    emitter.Name = "MachineryHum"
    emitter.Anchored = true
    emitter.CanCollide = false
    emitter.Transparency = 1
    emitter.Size = Vector3.new(1,1,1)
    emitter.CFrame = CFrame.new(position)
    self:_addPart(emitter)

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxasset://sounds/warehouse_machinery_loop.wav"
    sound.Looped = true
    sound.Volume = 0.4
    sound.Playing = true
    sound.Parent = emitter
end

function Map:Build()
    -- floor
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Anchored = true
    floor.Size = Vector3.new(200,1,200)
    floor.CFrame = CFrame.new(0,0,0)
    floor.Material = Enum.Material.Concrete
    self:_addPart(floor)

    -- outer walls
    local wallThickness = 2
    local height = 20
    local size = 200
    local walls = {
        {CFrame.new(0, height/2, -size/2 + wallThickness/2), Vector3.new(size, height, wallThickness)},
        {CFrame.new(0, height/2, size/2 - wallThickness/2), Vector3.new(size, height, wallThickness)},
        {CFrame.new(-size/2 + wallThickness/2, height/2, 0), Vector3.new(wallThickness, height, size)},
        {CFrame.new(size/2 - wallThickness/2, height/2, 0), Vector3.new(wallThickness, height, size)},
    }
    for _, data in ipairs(walls) do
        local wall = Instance.new("Part")
        wall.Name = "Wall"
        wall.Anchored = true
        wall.Size = data[2]
        wall.CFrame = data[1]
        wall.Material = Enum.Material.Metal
        self:_addPart(wall)
    end

    -- corridors
    self:_createCorridor(CFrame.new(-40,0.1,0), Vector3.new(20,1,160))
    self:_createCorridor(CFrame.new(40,0.1,0), Vector3.new(20,1,160))
    self:_createCorridor(CFrame.new(0,0.1,0), Vector3.new(160,1,20))

    -- crates arranged in three aisles
    local crateSize = Vector3.new(4,4,4)
    for row=0,9 do
        for aisle=0,2 do
            for stack=0,1 do
                local crate = Instance.new("Part")
                crate.Name = "Crate"
                crate.Size = crateSize
                crate.Material = Enum.Material.WoodPlanks
                local x = -60 + aisle*60
                local z = -80 + row*16
                local y = 2 + stack*4
                crate.CFrame = CFrame.new(x,y,z)
                crate.Anchored = true
                self:_addPart(crate)
            end
        end
    end

    -- switchable lights
    local lightPositions = {
        Vector3.new(-60,15,-80), Vector3.new(-60,15,0), Vector3.new(-60,15,80),
        Vector3.new(0,15,-80),   Vector3.new(0,15,0),   Vector3.new(0,15,80),
        Vector3.new(60,15,-80), Vector3.new(60,15,0), Vector3.new(60,15,80),
        Vector3.new(0,15,100)
    }
    for _, pos in ipairs(lightPositions) do
        self:_createSwitchLight(pos)
    end

    -- recharge stations
    local stationPositions = {
        Vector3.new(-80,2,-80), Vector3.new(80,2,-80),
        Vector3.new(-80,2,80),  Vector3.new(80,2,80)
    }
    for _, pos in ipairs(stationPositions) do
        self:_createRechargeStation(pos)
    end

    -- ambient machinery audio
    local audioPositions = {
        Vector3.new(-90,5,0), Vector3.new(90,5,0), Vector3.new(0,5,-90)
    }
    for _, pos in ipairs(audioPositions) do
        self:_createAmbientSound(pos)
    end

    assert(self.partCount <= Map.MAX_PARTS, string.format("part budget exceeded (%d > %d)", self.partCount, Map.MAX_PARTS))
    return self.model
end

return Map

