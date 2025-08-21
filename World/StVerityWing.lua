local Map = {}
Map.__index = Map

Map.MAX_PARTS = 200

function Map.new(parent)
    local self = setmetatable({}, Map)
    self.model = Instance.new("Model")
    self.model.Name = "StVerityWing"
    self.model.Parent = parent or workspace
    self.partCount = 0
    return self
end

function Map:_addPart(part)
    part.Parent = self.model
    self.partCount = self.partCount + 1
end

function Map:_createFloor(cframe, size)
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Anchored = true
    floor.Size = size
    floor.CFrame = cframe
    floor.Material = Enum.Material.Concrete
    self:_addPart(floor)
end

function Map:_createWall(cframe, size)
    local wall = Instance.new("Part")
    wall.Name = "Wall"
    wall.Anchored = true
    wall.Size = size
    wall.CFrame = cframe
    wall.Material = Enum.Material.Metal
    self:_addPart(wall)
end

function Map:_createStairs(cframe, size)
    local stairs = Instance.new("Part")
    stairs.Name = "Stairs"
    stairs.Anchored = true
    stairs.Size = size
    stairs.CFrame = cframe * CFrame.Angles(math.rad(-30), 0, 0)
    stairs.Material = Enum.Material.Metal
    self:_addPart(stairs)
end

function Map:_createWingLights(positions, switchPos)
    local lights = {}
    for _, pos in ipairs(positions) do
        local holder = Instance.new("Part")
        holder.Name = "Light"
        holder.Anchored = true
        holder.CanCollide = false
        holder.Transparency = 1
        holder.Size = Vector3.new(1,1,1)
        holder.CFrame = CFrame.new(pos)
        self:_addPart(holder)

        local light = Instance.new("PointLight")
        light.Brightness = 2
        light.Range = 20
        light.Enabled = false
        light.Parent = holder
        table.insert(lights, light)
    end

    local switch = Instance.new("Part")
    switch.Name = "LightSwitch"
    switch.Anchored = true
    switch.Size = Vector3.new(2,3,1)
    switch.CFrame = CFrame.new(switchPos)
    switch.Material = Enum.Material.Metal
    switch:SetAttribute("UseType", "Switch")
    self:_addPart(switch)

    local event = Instance.new("BindableEvent")
    event.Parent = switch
    local on = false
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxasset://sounds/switch_click.wav"
    sound.Parent = switch
    event.Event:Connect(function()
        on = not on
        for _, l in ipairs(lights) do
            l.Enabled = on
        end
        sound:Play()
    end)
end

function Map:_createKey(position, keyId)
    local key = Instance.new("Part")
    key.Name = keyId .. "Key"
    key.Anchored = true
    key.Size = Vector3.new(1,1,1)
    key.CFrame = CFrame.new(position)
    key.Color = Color3.new(1,1,0)
    key:SetAttribute("UseType", "Key")
    key:SetAttribute("KeyId", keyId)
    self:_addPart(key)
end

function Map:_createLockedDoor(cframe, size, keyId)
    local anchor = Instance.new("Part")
    anchor.Name = "DoorAnchor"
    anchor.Anchored = true
    anchor.Transparency = 1
    anchor.Size = Vector3.new(1, size.Y, 1)
    anchor.CFrame = cframe * CFrame.new(-size.X/2,0,0)
    self:_addPart(anchor)

    local door = Instance.new("Part")
    door.Name = "Door"
    door.Size = size
    door.Anchored = false
    door.CFrame = cframe
    door.Material = Enum.Material.Metal
    door:SetAttribute("UseType", "Door")
    if keyId then
        door:SetAttribute("KeyRequired", keyId)
    end
    self:_addPart(door)

    local hinge = Instance.new("HingeConstraint")
    hinge.Part0 = anchor
    hinge.Part1 = door
    hinge.TargetAngle = 0
    hinge.AngularSpeed = 2
    hinge.Parent = door

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxasset://sounds/door_creak.wav"
    sound.Parent = door
end

function Map:_createAudioZone(position, soundId, volume)
    local part = Instance.new("Part")
    part.Name = "AudioEmitter"
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Size = Vector3.new(1,1,1)
    part.CFrame = CFrame.new(position)
    self:_addPart(part)

    local sound = Instance.new("Sound")
    sound.SoundId = soundId or "rbxassetid://0"
    sound.Looped = true
    sound.Volume = volume or 0.3
    sound.Playing = true
    sound.Parent = part
end

function Map:Build()
    -- floors
    self:_createFloor(CFrame.new(0,0,0), Vector3.new(100,1,60))
    self:_createFloor(CFrame.new(0,10,0), Vector3.new(100,1,60))

    -- outer walls
    local height, w, d, t = 20, 100, 60, 2
    local walls = {
        {CFrame.new(0, height/2, -d/2 + t/2), Vector3.new(w, height, t)},
        {CFrame.new(0, height/2,  d/2 - t/2), Vector3.new(w, height, t)},
        {CFrame.new(-w/2 + t/2, height/2, 0), Vector3.new(t, height, d)},
        {CFrame.new( w/2 - t/2, height/2, 0), Vector3.new(t, height, d)},
    }
    for _, data in ipairs(walls) do
        self:_createWall(data[1], data[2])
    end

    -- stairs to second floor
    self:_createStairs(CFrame.new(-40,2.5,-25), Vector3.new(10,5,30))

    -- wing lights
    self:_createWingLights({Vector3.new(-30,15,-20), Vector3.new(-30,15,20)}, Vector3.new(-45,5,0))
    self:_createWingLights({Vector3.new(30,15,-20), Vector3.new(30,15,20)}, Vector3.new(45,5,0))

    -- key and locked door
    self:_createKey(Vector3.new(-40,1,20), "Main")
    self:_createLockedDoor(CFrame.new(0,5,30), Vector3.new(6,10,1), "Main")

    -- audio zones
    self:_createAudioZone(Vector3.new(0,5,0), "rbxasset://sounds/asylum_hum_loop.wav", 0.2)
    self:_createAudioZone(Vector3.new(0,15,0), "rbxasset://sounds/asylum_hum_loop.wav", 0.3)

    assert(self.partCount <= Map.MAX_PARTS, string.format("part budget exceeded (%d > %d)", self.partCount, Map.MAX_PARTS))
    return self.model
end

return Map

