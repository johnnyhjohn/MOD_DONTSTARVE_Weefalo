ACTIONS.TAKEITEM._fn = ACTIONS.TAKEITEM.fn
ACTIONS.TAKEITEM.fn = function(act)
    local targ = act.target or act.invobject
 
    if targ.components.characterspecific and not targ.components.characterspecific:CanPickUp(act.doer) then
        return false, "CHARACTERSPECIFIC"
    end
 
    return ACTIONS.TAKEITEM._fn(act)
end 