ACTIONS.EQUIP._fn = ACTIONS.EQUIP.fn
ACTIONS.EQUIP.fn = function(act)
    if act.invobject.components.characterspecific and not act.invobject.components.characterspecific:CanPickUp(act.doer) then
       return false, "CHARACTERSPECIFIC"
    end
    
    return ACTIONS.EQUIP._fn(act)
end