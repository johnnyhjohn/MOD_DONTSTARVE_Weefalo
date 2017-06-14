local GroundPounder = Class(function(self, inst)
    self.inst = inst
    
    self.numRings = 4
    self.ringDelay = 0.2
    self.initialRadius = 1
    self.radiusStepDistance = 4
    self.pointDensity = .25
    self.damageRings = 2
    self.destructionRings = 3
    self.noTags = {"FX", "NOCLICK", "DECOR", "INLIMBO"}
    self.destroyer = false
    self.burner = false
    self.groundpoundfx = "groundpound_fx"
    self.groundpoundringfx = "groundpoundring_fx"
    self.groundpounddamagemult = 1
    self.groundpoundFn = nil
end)

function GroundPounder:GetPoints(pt)
    local points = {}
    local radius = self.initialRadius
    
    for i = 1, self.numRings do
        local theta = 0		
        local circ = 2*PI*radius
        local numPoints = circ * self.pointDensity
        for p = 1, numPoints do
            
            if not points[i] then
                points[i] = {}
            end
            
            local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
            local point = pt + offset
            
            table.insert(points[i], point)
            
            theta = theta - (2*PI/numPoints)
        end
        
        radius = radius + self.radiusStepDistance
        
    end
    return points
end

function GroundPounder:DestroyPoints(points, dodamage)
    local getEnts = dodamage
    
    for k,v in pairs(points) do
        local ents = nil
        if getEnts then
            ents = TheSim:FindEntities(v.x, v.y, v.z, 3, nil, self.noTags)
        end
        if ents and dodamage then
            for k2,v2 in pairs(ents) do
                if v2 and v2.components.health and not v2.components.health:IsDead() and 
                    self.inst.components.combat:CanTarget(v2) then
                    self.inst.components.combat:DoAttack(v2, nil, nil, nil, self.groundpounddamagemult)
                end
            end
        end
        
        if not (TheWorld.Map:GetTileAtPoint(v.x, v.y, v.z) == GROUND.IMPASSABLE) then
            SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
        end
        
    end
end

function GroundPounder:GroundPound(pt)
    local pt = pt or self.inst:GetPosition()
    SpawnPrefab(self.groundpoundringfx).Transform:SetPosition(pt:Get())
    local points = self:GetPoints(pt)
    local delay = 0
    for i = 1, self.numRings do
        
        self.inst:DoTaskInTime(delay, function() self:DestroyPoints(points[i], i <= self.destructionRings, i <= self.damageRings) end)
        delay = delay + self.ringDelay
    end
    
    if self.groundpoundFn then self.groundpoundFn(self.inst) end
end

function GroundPounder:GroundPound_Offscreen(position)
    local pt = position or self.inst:GetPosition()
    
    local dodamageRadius = self.initialRadius + (self.damageRings-1) *  self.radiusStepDistance
    
    local ents = TheSim:FindEntities(position.x, position.y, position.z, dodamageRadius, nil, {"FX", "NOCLICK", "DECOR", "INLIMBO"})
    for k,v in pairs(ents) do
        local pos = v:GetPosition()
        local dsq = distsq(position, pos) --Distance to target.
    end
end

function GroundPounder:GetDebugString()
    local str = string.format("num rings: %d, damage rings: %d, destruction rings: %d", self.numRings, self.damageRings, self.destructionRings)
    return str
end

return GroundPounder
