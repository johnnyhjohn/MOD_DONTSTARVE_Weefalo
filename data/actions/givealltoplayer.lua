ACTIONS.GIVEALLTOPLAYER._fn = ACTIONS.GIVEALLTOPLAYER.fn
ACTIONS.GIVEALLTOPLAYER.fn = function(act)
	if act.invobject.components.characterspecific and not act.invobject.components.characterspecific:CanPickUp(act.target) then
        return false, "CHARACTERSPECIFIC"
    end

    return ACTIONS.GIVEALLTOPLAYER._fn(act)
end