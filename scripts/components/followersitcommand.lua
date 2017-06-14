local function onstay(self, stay)
    if self.inst.replica.followersitcommand then
        self.inst.replica.followersitcommand._staying:set(stay)
    end
end

local FollowerSitCommand = Class(function(self, inst)
    self.inst = inst
    self.stay = false
    self.locations = {}
end,
nil, {
    stay = onstay
})

function FollowerSitCommand:IsCurrentlyStaying()
    return self.inst.replica.followersitcommand and self.inst.replica.followersitcommand._staying:value()
end

function FollowerSitCommand:SetStaying(stay)
    self.stay = stay
end

function FollowerSitCommand:RememberSitPos(name, pos)
    self.locations[name] = pos
end

function FollowerSitCommand:OnSave()
    if self:IsCurrentlyStaying() then
        local data = 
        { 
            stay = self.stay,
            varx = self.locations.currentstaylocation["x"], 
            vary = self.locations.currentstaylocation["y"], 
            varz = self.locations.currentstaylocation["z"]
        }
        return data
    end
end  

function FollowerSitCommand:OnLoad(data)
    if data then 
        self.stay = data.stay
        self.locations.currentstaylocation = {}
        self.locations.currentstaylocation["x"] = data.varx
        self.locations.currentstaylocation["y"] = data.vary
        self.locations.currentstaylocation["z"] = data.varz
    end
end

return FollowerSitCommand
