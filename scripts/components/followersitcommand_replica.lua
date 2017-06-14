local FollowerSitCommand = Class(function(self, inst)
    self.inst = inst
    
    self._staying = net_bool(inst.GUID, "followersitcommand._equipslot")
end)

function FollowerSitCommand:IsCurrentlyStaying()
    return self._staying:value()
end

return FollowerSitCommand
