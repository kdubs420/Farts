local Map = {}
Map.__index = Map

Map.MAX_PARTS = 200
Map.MAX_LIGHTS = 20

function Map.new(parent)
    local self = setmetatable({}, Map)
    self.model = Instance.new("Model")
    self.model.Name = "HarborlineDistrict"
    self.model.Parent = parent or workspace
    self.partCount = 0
    self.lightCount = 0
    return self
end

function Map:_addPart(part)
    part.Parent = self.model
    self.partCount = self.partCount + 1
end

function Map:_addLight(light)
    light.Parent = light.Parent or self.model
    self.lightCount = self.lightCount + 1
end

-- basic geometry
function Map:_createGround()
    local ground = Instance.new("Part")
    ground.Name = "Ground"
    ground.Anchored = true
    ground.Size = Vector3.new(300,1,300)
    ground.Material = Enum.Material.Asphalt
    ground.Color = Color3.fromRGB(30,30,32)
    ground.CFrame = CFrame.new(0,0,0)
    self:_addPart(ground)
end

function Map:_createBuilding(cframe, size)
    local building = Instance.new("Part")
    building.Name = "Building"
    building.Anchored = true
    building.Size = size
    building.CFrame = cframe
    building.Material = Enum.Material.Concrete
    building.Color = Color3.fromRGB(40,40,42)
    self:_addPart(building)
    return building
end

function Map:_createStreetLamp(position)
    local post = Instance.new("Part")
    post.Name = "StreetLamp"
    post.Anchored = true
    post.Size = Vector3.new(1,12,1)
    post.CFrame = CFrame.new(position)
    post.Material = Enum.Material.Metal
    self:_addPart(post)

    local light = Instance.new("PointLight")
    light.Brightness = 1.5
    light.Range = 25
    light.Parent = post
    self.lightCount = self.lightCount + 1
end

function Map:_createRechargeKiosk(position)
    local kiosk = Instance.new("Part")
    kiosk.Name = "RechargeKiosk"
    kiosk.Anchored = true
    kiosk.Size = Vector3.new(4,3,4)
    kiosk.CFrame = CFrame.new(position)
    kiosk.Material = Enum.Material.Metal
    self:_addPart(kiosk)

    local light = Instance.new("PointLight")
    light.Color = Color3.new(0.8,0.9,1)
    light.Brightness = 1.5
    light.Range = 15
    light.Parent = kiosk
    self.lightCount = self.lightCount + 1

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Recharge"
    prompt.HoldDuration = 1
    prompt.Parent = kiosk
    prompt.Triggered:Connect(function(player)
        local backpack = player and player:FindFirstChildOfClass("Backpack")
        if backpack then
            local flashlight = backpack:FindFirstChild("Flashlight")
            if flashlight then
                flashlight:SetAttribute("Battery", 90)
            end
        end
    end)
end

function Map:_createNeonLane(signCFrame, laneDirection)
    local sign = Instance.new("Part")
    sign.Name = "NeonSign"
    sign.Anchored = true
    sign.Size = Vector3.new(6,3,0.5)
    sign.CFrame = signCFrame
    sign.Material = Enum.Material.Neon
    sign.Color = Color3.fromRGB(255,0,150)
    self:_addPart(sign)

    local surfaceLight = Instance.new("SurfaceLight")
    surfaceLight.Face = Enum.NormalId.Front
    surfaceLight.Brightness = 0
    surfaceLight.Range = 30
    surfaceLight.Angle = 90
    surfaceLight.Parent = sign
    self.lightCount = self.lightCount + 1

    local laneLights = {}
    for i=1,3 do
        local marker = Instance.new("Part")
        marker.Name = "NeonLaneLight"
        marker.Anchored = true
        marker.CanCollide = false
        marker.Transparency = 1
        marker.Size = Vector3.new(1,1,1)
        marker.CFrame = signCFrame * CFrame.new(laneDirection * (i*10))
        self:_addPart(marker)

        local l = Instance.new("PointLight")
        l.Brightness = 0
        l.Range = 18
        l.Parent = marker
        table.insert(laneLights, l)
    end
    self.lightCount = self.lightCount + #laneLights

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Hack"
    prompt.HoldDuration = 1
    prompt.Parent = sign
    prompt.Triggered:Connect(function()
        surfaceLight.Brightness = 4
        for _,l in ipairs(laneLights) do
            l.Brightness = 3
        end
        task.delay(10, function()
            surfaceLight.Brightness = 0
            for _,l in ipairs(laneLights) do
                l.Brightness = 0
            end
        end)
    end)
end

function Map:_createShadowNode(position)
    local node = Instance.new("Part")
    node.Name = "ShadowNode"
    node.Anchored = true
    node.CanCollide = false
    node.Transparency = 1
    node.Size = Vector3.new(2,1,2)
    node.CFrame = CFrame.new(position)
    self:_addPart(node)
end

function Map:_createSpawnPoint(position, role)
    local spawn = Instance.new("Part")
    spawn.Name = role .. "Spawn"
    spawn.Anchored = true
    spawn.CanCollide = false
    spawn.Transparency = 1
    spawn.Size = Vector3.new(2,1,2)
    spawn.CFrame = CFrame.new(position)
    self:_addPart(spawn)
end

function Map:_createRain(position, size)
    local part = Instance.new("Part")
    part.Name = "Rain"
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1,1,1)
    part.CFrame = CFrame.new(position)
    self:_addPart(part)

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://0"
    emitter.Lifetime = NumberRange.new(1,1.5)
    emitter.Rate = 400
    emitter.Speed = NumberRange.new(-50,-40)
    emitter.VelocitySpread = 10
    emitter.Size = NumberSequence.new(size)
    emitter.Parent = part
end

function Map:Build()
    self:_createGround()

    -- simple buildings
    self:_createBuilding(CFrame.new(-80,10,60), Vector3.new(40,20,40))
    self:_createBuilding(CFrame.new(80,10,40), Vector3.new(50,20,30))
    self:_createBuilding(CFrame.new(0,10,-80), Vector3.new(60,20,40))

    -- pier
    self:_createBuilding(CFrame.new(0,5,140), Vector3.new(60,10,40))

    -- street lamps
    local lampPositions = {
        Vector3.new(-100,6,0), Vector3.new(-50,6,0), Vector3.new(0,6,0),
        Vector3.new(50,6,0), Vector3.new(100,6,0), Vector3.new(0,6,100)
    }
    for _,pos in ipairs(lampPositions) do
        self:_createStreetLamp(pos)
    end

    -- recharge kiosks
    local kioskPositions = {
        Vector3.new(-90,2,-40), Vector3.new(90,2,-20), Vector3.new(0,2,120)
    }
    for _,pos in ipairs(kioskPositions) do
        self:_createRechargeKiosk(pos)
    end

    -- neon hack lanes
    self:_createNeonLane(CFrame.new(-120,10,20), Vector3.new(1,0,0))
    self:_createNeonLane(CFrame.new(120,10,-20), Vector3.new(-1,0,0))

    -- shadow nodes
    local nodePositions = {
        Vector3.new(-110,2,-60), Vector3.new(110,2,60), Vector3.new(0,2,60),
        Vector3.new(-60,2,120), Vector3.new(60,2,-120), Vector3.new(0,2,-40)
    }
    for _,pos in ipairs(nodePositions) do
        self:_createShadowNode(pos)
    end

    -- spawn points
    local survivorSpawns = {
        Vector3.new(-120,2,-40), Vector3.new(-100,2,-20), Vector3.new(-80,2,0), Vector3.new(-60,2,20),
        Vector3.new(-40,2,40), Vector3.new(-20,2,60), Vector3.new(0,2,-40), Vector3.new(20,2,-20),
        Vector3.new(40,2,0), Vector3.new(60,2,20), Vector3.new(80,2,40), Vector3.new(100,2,60),
        Vector3.new(-40,2,-80), Vector3.new(40,2,-80), Vector3.new(-80,2,80), Vector3.new(80,2,80),
        Vector3.new(-20,2,100), Vector3.new(20,2,100)
    }
    for _,pos in ipairs(survivorSpawns) do
        self:_createSpawnPoint(pos, "Survivor")
    end

    self:_createSpawnPoint(Vector3.new(-10,2,-150), "Shadow")
    self:_createSpawnPoint(Vector3.new(10,2,150), "Shadow")

    -- rain effect
    self:_createRain(Vector3.new(0,50,0), 40)

    assert(self.partCount <= Map.MAX_PARTS, string.format("part budget exceeded (%d > %d)", self.partCount, Map.MAX_PARTS))
    assert(self.lightCount <= Map.MAX_LIGHTS, string.format("light budget exceeded (%d > %d)", self.lightCount, Map.MAX_LIGHTS))
    return self.model
end

return Map

