-----------------------------------------------------------------------------------
-- This file has been developed exclusively for the mod "Jão the Great Summoner" --
--(http://steamcommunity.com/sharedfiles/filedetails/?id=572470943). 		     --
-- Any unauthorized use will be reported to the DMCA. 				             --
-- To use any file or sprite ask my permission.					                 --
--										                                         --
-- Author: Paulo Victor de Oliveira Leal					                     --
-- Contact: ciclopiano@gmail.com						                         --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

require("stategraphs/commonstates")

local attacks_til_groundpound = 4

local function GetScalePercent(inst)
    return (inst.components.scaler.scale - TUNING.ROCKY_MIN_SCALE) / (TUNING.ROCKY_MAX_SCALE - TUNING.ROCKY_MIN_SCALE)
end

local function PlayLobSound(inst, sound)
    inst.SoundEmitter:PlaySoundWithParams(sound, {size=GetScalePercent(inst)})
end

local actionhandlers =
{
    ActionHandler(ACTIONS.TAKEITEM, "rocklick"),
    ActionHandler(ACTIONS.PICKUP, "rocklick"),
    ActionHandler(ACTIONS.EAT, "eat"),
}

local function onattackfn(inst)
    if inst.components.health ~= nil and
        not inst.components.health:IsDead() and
        (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then        
        if (attacks_til_groundpound - 1) <= 0 then            
            inst.cangroundpound = true            
        else
            attacks_til_groundpound = attacks_til_groundpound - 1
        end
        if inst.cangroundpound then
            inst.sg:GoToState("pound")
        else
            inst.sg:GoToState("attack")
        end
    end
end

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
        EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not
            inst.sg:HasStateTag("attack") and not
            inst.sg:HasStateTag("waking") and not
            inst.sg:HasStateTag("sleeping") and 
            (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("frozen")) then
            inst.sg:GoToState("hit") 
        end
    end),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnSleep(),
    EventHandler("doattack", onattackfn),
    EventHandler("gotosleep", function(inst) inst.sg:GoToState("sleep") end),
    EventHandler("entershield", function(inst) inst.sg:GoToState("shield_start") end),
    EventHandler("exitshield", function(inst) inst.sg:GoToState("shield_end") end),
}

local function ShakeIfClose(inst)
    for i, v in ipairs(AllPlayers) do
        v:ShakeCamera(CAMERASHAKE.FULL, .7, .02, .3, inst, 40)
    end
    end
    
    local function pickrandomstate(inst, choiceA, choiceB, chance)
        if math.random() >= chance then
            inst.sg:GoToState(choiceA) 
        else
            inst.sg:GoToState(choiceB)
        end
    end
    
    
    local states =
    {
        State{
            name = "death",
            tags = {"busy"},
            
            onenter = function(inst)
                --inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
                inst.AnimState:PlayAnimation("death")
                inst.Physics:Stop()
                RemovePhysicsColliders(inst)            
                inst.SoundEmitter:PlaySound("dontstarve/forest/treeFall")
                inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
            end,
            
        },
        
        State{
            name = "tree",
            onenter = function(inst)
                inst.AnimState:PlayAnimation("tree_idle", true)
            end,
        },   
        
        State{
            name = "panic",
            tags = {"busy"},
            onenter = function(inst)
                inst.AnimState:PlayAnimation("panic_pre")
                inst.AnimState:PushAnimation("panic_loop", true)
            end,
            onexit = function(inst)
            end,
            
            onupdate = function(inst)
                if inst.components.burnable and not inst.components.burnable:IsBurning() and inst.sg.timeinstate > .3 then
                    inst.sg:GoToState("idle", "panic_post")
                end
            end,
        },   
        
        State{
            name = "attack",
            tags = {"attack", "busy"},
            
            onenter = function(inst, target)
                inst.Physics:Stop()
                inst.components.combat:StartAttack()
                inst.AnimState:PlayAnimation("atk")
                inst.sg.statemem.target = target
            end,
            
            timeline=
            {
                TimeEvent(25*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
                TimeEvent(26*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
                
                TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
                TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/attack_VO") end),
                TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/swipe") end),
                TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
            },
            
            events=
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
            },
        },  
        
        State{
            name = "hit",
            tags = {"hit", "busy"},
            
            onenter = function(inst, cb)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("hit")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/hurt_VO")
                
            end,
            
            events=
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
            },
            
            timeline=
            {
                TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
            },
            
        },      
        State{
		name = "pound",
		tags = {"attack", "busy"},

		onenter = function(inst)
			--if GoToStandState(inst, "bi") then
			inst.components.inventory:Unequip( EQUIPSLOTS.HANDS )
				if inst.components.locomotor then
					inst.components.locomotor:StopMoving()
				end
				--inst.AnimState:PlayAnimation("ground_pound")
			inst:DoTaskInTime(1, function (inst) inst.components.inventory:Equip( inst.sword ) end )
			--end
		end,

		timeline=
		{
			TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			TimeEvent(20*FRAMES, function(inst)
				ShakeIfClose(inst)
				inst.components.groundpounder2:GroundPound()
				inst.cangroundpound = false
				attacks_til_groundpound = 4
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
			end),
		},

		events=
		{
			EventHandler("animover", function(inst)
				inst.AnimState:PlayAnimation("idle")
				inst.sg:GoToState("idle")
			end),
		},
	},
        State{
            name = "spawn",
            tags = {"waking", "busy"},
            
            onenter = function(inst, start_anim)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("transform_ent")
                inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/transform_VO")
            end,
            
            events=
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
            },
            
            timeline=
            {
                TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
                TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
                TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
            },
            
        },
    }
    
    CommonStates.AddWalkStates(states,
    {
        starttimeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end),
            TimeEvent(11*FRAMES, function(inst) inst.components.locomotor:WalkForward() end),
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
            TimeEvent(17*FRAMES, function(inst) inst.Physics:Stop() end),
        },
        walktimeline = 
        { 
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/walk_vo") end),
            TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
            TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/footstep") end),
            TimeEvent(52*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
            TimeEvent(53*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/footstep") end),
        },
        endtimeline=
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") end),
        },
    })
    
    CommonStates.AddIdle(states)
    CommonStates.AddFrozenStates(states)
    
    return StateGraph("chop", states, events, "idle", actionhandlers)
    