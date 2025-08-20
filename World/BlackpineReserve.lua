local PathfindingService = game:GetService("PathfindingService")
local Debris = game:GetService("Debris")

local Map = {}
Map.__index = Map

Map.MAX_PARTS = 200

function Map.new(parent)
    local self = setmetatable({}, Map)
    self.model = Instance.new("Model")
    self.model.Name = "BlackpineReserve"
    self.model.Parent = parent or workspace
    self.partCount = 0
    return self
end

function Map:_addPart(part)
    part.Parent = self.model
    self.partCount = self.partCount + 1
end

function Map:_createTerrain()
    local ground = Instance.new("Part")
    ground.Name = "Ground"
    ground.Anchored = true
    ground.Size = Vector3.new(400,1,400)
    ground.CFrame = CFrame.new(0,0,0)
    ground.Material = Enum.Material.Grass
    ground.Color = Color3.fromRGB(33,142,38)
    self:_addPart(ground)
end

function Map:_createTree(position)
    local trunk = Instance.new("Part")
    trunk.Name = "Trunk"
    trunk.Anchored = true
    trunk.Size = Vector3.new(2,20,2)
    trunk.CFrame = CFrame.new(position)
    trunk.Material = Enum.Material.Wood
    self:_addPart(trunk)

    local leaves = Instance.new("Part")
    leaves.Name = "Leaves"
    leaves.Shape = Enum.PartType.Ball
    leaves.Anchored = true
    leaves.Size = Vector3.new(14,14,14)
    leaves.CFrame = trunk.CFrame * CFrame.new(0,12,0)
    leaves.Material = Enum.Material.Grass
    leaves.Color = Color3.fromRGB(34,120,30)
    self:_addPart(leaves)
end

function Map:_createFogVolume(position, radius)
    local fog = Instance.new("Part")
    fog.Name = "Fog"
    fog.Anchored = true
    fog.CanCollide = false
    fog.Transparency = 1
    fog.Size = Vector3.new(1,1,1)
    fog.CFrame = CFrame.new(position)
    self:_addPart(fog)

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://0"
    emitter.Lifetime = NumberRange.new(4,6)
    emitter.Rate = 30
    emitter.Speed = NumberRange.new(0,1)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, radius),
        NumberSequenceKeypoint.new(1, radius)
    })
    emitter.Parent = fog
end

function Map:_createFireflies(position)
    local swarm = Instance.new("Part")
    swarm.Name = "FireflySwarm"
    swarm.Anchored = true
    swarm.CanCollide = false
    swarm.Transparency = 1
    swarm.Size = Vector3.new(1,1,1)
    swarm.CFrame = CFrame.new(position)
    self:_addPart(swarm)

    local light = Instance.new("PointLight")
    light.Color = Color3.new(1,1,0.5)
    light.Brightness = 0.5
    light.Range = 6
    light.Parent = swarm

    local emitter = Instance.new("ParticleEmitter")
    emitter.Texture = "rbxassetid://0"
    emitter.Color = ColorSequence.new(Color3.new(1,1,0.5))
    emitter.Lifetime = NumberRange.new(2,4)
    emitter.Size = NumberSequence.new(0.2)
    emitter.Speed = NumberRange.new(0.5,1)
    emitter.Parent = swarm

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Gather"
    prompt.HoldDuration = 0.5
    prompt.Parent = swarm
    prompt.Triggered:Connect(function(plr)
        local char = plr.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local attachment = Instance.new("Attachment")
        attachment.Parent = root

        local attachLight = light:Clone()
        attachLight.Brightness = 1.5
        attachLight.Range = 10
        attachLight.Parent = attachment

        local attachEmitter = emitter:Clone()
        attachEmitter.Parent = attachment

        task.delay(10, function()
            attachment:Destroy()
        end)
    end)
end

function Map:_createCampfire(position)
    local base = Instance.new("Part")
    base.Name = "Campfire"
    base.Anchored = true
    base.Size = Vector3.new(4,1,4)
    base.CFrame = CFrame.new(position)
    base.Material = Enum.Material.Rock
    self:_addPart(base)

    local fire = Instance.new("ParticleEmitter")
    fire.Texture = "rbxassetid://0"
    fire.Lifetime = NumberRange.new(1,1.5)
    fire.Rate = 50
    fire.Speed = NumberRange.new(2,4)
    fire.Parent = base

    local light = Instance.new("PointLight")
    light.Color = Color3.new(1,0.6,0.3)
    light.Brightness = 2
    light.Range = 20
    light.Parent = base

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://0"
    sound.Looped = true
    sound.Volume = 0.4
    sound.Playing = true
    sound.Parent = base

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Recharge"
    prompt.HoldDuration = 1
    prompt.Parent = base
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

function Map:_createWind(position)
    local part = Instance.new("Part")
    part.Name = "WindEmitter"
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1,1,1)
    part.CFrame = CFrame.new(position)
    self:_addPart(part)

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://0"
    sound.Looped = true
    sound.Volume = 0.3
    sound.Playing = true
    sound.Parent = part
end

function Map:_createPath(startPos, endPos)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(startPos, endPos)
    if path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            local node = Instance.new("Part")
            node.Shape = Enum.PartType.Ball
            node.Anchored = true
            node.CanCollide = false
            node.Size = Vector3.new(1,1,1)
            node.Color = Color3.new(1,1,0)
            node.CFrame = CFrame.new(waypoint.Position)
            self:_addPart(node)
            Debris:AddItem(node, 5)
        end
    end
end

function Map:Build()
    self:_createTerrain()

    local treePositions = {
        Vector3.new(-80,10,-60), Vector3.new(-40,10,-90), Vector3.new(30,10,-70),
        Vector3.new(80,10,-80),  Vector3.new(-90,10,40),  Vector3.new(-20,10,80),
        Vector3.new(40,10,60),   Vector3.new(90,10,20),   Vector3.new(-60,10,10),
        Vector3.new(0,10,0)
    }
    for _, pos in ipairs(treePositions) do
        self:_createTree(pos)
    end

    local fogPositions = {
        {Vector3.new(-50,2,-50), 20},
        {Vector3.new(60,2,70), 25},
        {Vector3.new(-70,2,80), 15}
    }
    for _, data in ipairs(fogPositions) do
        self:_createFogVolume(data[1], data[2])
    end

    local fireflyPositions = {
        Vector3.new(20,3,-20), Vector3.new(-30,3,40), Vector3.new(50,3,50)
    }
    for _, pos in ipairs(fireflyPositions) do
        self:_createFireflies(pos)
    end

    local campfirePositions = {
        Vector3.new(-90,1,-90), Vector3.new(90,1,-90), Vector3.new(0,1,90)
    }
    for _, pos in ipairs(campfirePositions) do
        self:_createCampfire(pos)
    end

    local windPositions = {
        Vector3.new(0,10,0), Vector3.new(100,10,100)
    }
    for _, pos in ipairs(windPositions) do
        self:_createWind(pos)
    end

    self:_createPath(Vector3.new(-150,2,-150), Vector3.new(150,2,150))

    assert(self.partCount <= Map.MAX_PARTS, string.format("part budget exceeded (%d > %d)", self.partCount, Map.MAX_PARTS))
    return self.model
end

return Map

