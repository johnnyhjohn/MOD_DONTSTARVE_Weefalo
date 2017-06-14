ACTIONS.GIVETOPLAYER._fn = ACTIONS.GIVETOPLAYER.fn
ACTIONS.GIVETOPLAYER.fn = function(act)
	if act.invobject.components.characterspecific and not act.invobject.components.characterspecific:CanPickUp(act.target) then
        return false, "CHARACTERSPECIFIC"
    end

    return ACTIONS.GIVETOPLAYER._fn(act)
end