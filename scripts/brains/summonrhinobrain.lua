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

require "behaviours/standstill"
require "behaviours/chattynode"
require "behaviours/chaseandattack"
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/wander"
require "behaviours/chaseandram"
require "behaviours/runaway"
require "behaviours/doaction"

local RUN_AWAY_DIST = 25
local STOP_RUN_AWAY_DIST = 15
local MAX_CHASE_TIME = 25
local MIN_FOLLOW_CLOSE = 2
local TARGET_FOLLOW_CLOSE = 5
local MAX_FOLLOW_CLOSE = 10
local MIN_FOLLOW = 2
local TARGET_FOLLOW = 10
local MAX_FOLLOW = 10
local MAX_WANDER_DIST = 25
local GIVE_UP_DIST = 25
local MAX_CHARGE_DIST = 60
local CHASE_GIVEUP_DIST = 25
local GO_HOME_DIST = 40

------------------------------------------
local SPEECH = TUNING.JAO.SPEECH

local function StayHere(inst)
    return inst.components.followersitcommand:IsCurrentlyStaying()
end

local function BeeHasBeeBox(inst)
    local target = inst.components.combat.target
    if target and target:HasTag("bee") and target.components.homeseeker then
        inst.components.combat:GiveUp()
        return true
    end
end

local function GoHomeAction(inst)
    if inst.components.combat.target ~= nil then
        return
    end
    local leader = inst.components.follower.leader
    if leader ~= nil then
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, (leader.Transform:GetWorldPosition( )), nil, .2)
        or nil
    end                
end

local function ShouldGoHome(inst)
    local homePos = inst.components.follower.leader
    if homePos == nil then
        return false
    end
    local dist_sq = inst:GetDistanceSqToPoint(Point(homePos.Transform:GetWorldPosition()))
    return dist_sq > GO_HOME_DIST * GO_HOME_DIST
        or (dist_sq > CHASE_GIVEUP_DIST * CHASE_GIVEUP_DIST and
            inst.components.combat.target == nil)
end

local function IsTakingFireDamage(inst)
    return inst.components.health.takingfiredamage
end

local function ReadyForAttack(inst)
    return inst.components.combat.target and inst.components.combat:InCooldown()
end

local function CombatTarget(inst)
    return inst.components.combat.target
end

local closeitem = {
    umbrella = true,
    grass_umbrella = true,
    torch = true
}

local function CheckForClosely(inst)
    local handitem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if handitem and closeitem[handitem.prefab] then
        return true
    end
end

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function CryForQt(inst)
    inst.components.talker:Say(SPEECH.RHINO.DISTANCIA.FAR)
    for k, v in pairs(AllPlayers) do
        if v.prefab == "jao" then
            if not v.components.leader then
                v:AddComponent("leader")
            end
            v.components.leader:AddFollower(inst, true)
            inst:DoTaskInTime(2, function()
                inst.components.talker:Say(SPEECH.RHINO.DISTANCIA.CLOSE)
            end)
            break
        end
    end
end

local function GetWanderPosition(inst)
    if inst.components.follower and inst.components.follower.leader then
        return Point(inst.components.follower.leader.Transform:GetWorldPosition())
    else
        CryForQt(inst)
    end
    return inst.components.followersitcommand.currentstaylocation
end


local function FindEntityToWorkAction(inst, action, addtltags)
    local target = inst.target
    local targetEntity = inst.targetEntity
    if target and targetEntity then
       local bufferedAction =  BufferedAction(inst, targetEntity, action)
       inst.destroy = false 
       return inst.components.locomotor:GoToPoint(target, bufferedAction, true) --or nil  
    end
    
end


local SummonRhino = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SummonRhino:OnStart()
    local root = PriorityNode(
    {
        StandStill(self.inst, StayHere, StayHere),
        --WhileNode(function() 
        --return ReadyForAttack(self.inst) end, "Dodge",
        --RunAway(self.inst, function() return CombatTarget(self.inst) end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),
        
        
        IfNode(function() return self.inst.destroy end, "Is Destroying",
            LoopNode{
                 DoAction(self.inst, function() return FindEntityToWorkAction(self.inst, ACTIONS.WALKTO) end)
        }),
        
        
        
        WhileNode(function()
                return self.inst.components.combat.target ~= nil
                    and (self.inst.sg:HasStateTag("running") or
                        not self.inst.components.combat.target:IsNear(self.inst, 6))
            end,
            "RamAttack", ChaseAndRam(self.inst, MAX_CHASE_TIME, CHASE_GIVEUP_DIST, MAX_CHARGE_DIST)),
        WhileNode(function()
                return self.inst.components.combat.target ~= nil
                    and not self.inst.sg:HasStateTag("running")
                    and self.inst.components.combat.target:IsNear(self.inst, 6)
            end,
            "NormalAttack", ChaseAndAttack(self.inst, 3, 5)),
        WhileNode(function() return self.inst.components.combat.target ~= nil and self.inst.components.combat:InCooldown() end, "Rest",
            StandStill(self.inst)),
        --"Charge Behaviours", ChaseAndRam(self.inst, MAX_CHASE_TIME, GIVE_UP_DIST, MAX_CHARGE_DIST)),
        IfNode(function() return CheckForClosely(self.inst) end, "Follow Closely",
        Follow(self.inst, GetLeader, MIN_FOLLOW_CLOSE, TARGET_FOLLOW_CLOSE, MAX_FOLLOW_CLOSE, true)),
        IfNode(function() return not CheckForClosely(self.inst) end, "Follow from Distance",
        Follow(self.inst, GetLeader, MIN_FOLLOW, TARGET_FOLLOW, MAX_FOLLOW, false)),
        --WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
        --    DoAction(self.inst, GoHomeAction, "Go Home", false)),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, GetWanderPosition, MAX_WANDER_DIST)
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return SummonRhino