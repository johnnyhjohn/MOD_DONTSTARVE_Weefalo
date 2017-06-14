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

local RUN_AWAY_DIST = 1
local STOP_RUN_AWAY_DIST = 2
local MAX_CHASE_TIME = 6
local MIN_FOLLOW_CLOSE = 1
local TARGET_FOLLOW_CLOSE = 2
local MAX_FOLLOW_CLOSE = 3
local MIN_FOLLOW = 1
local TARGET_FOLLOW = 2
local MAX_FOLLOW = 3
local MAX_WANDER_DIST = 0
local GIVE_UP_DIST = 20
local MAX_CHARGE_DIST = 60

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
    
    for k, v in pairs(AllPlayers) do
        if v.prefab == "jao" then
            if not v.components.leader then
                v:AddComponent("leader")
            end
            v.components.leader:AddFollower(inst, true)
            inst:DoTaskInTime(2, function()
                
            end)
            break
        end
    end
end

local ValidItems = {
 "goldnugget", "rocks", "cutstone", "nitre", "flint", "thulecite", "thulecite_pieces", "marble", "redgem", "purplegem", "bluegem", "yellowgem", "greengem", "orangegem",    "log", "boards", "cutgrass","dug_berrybush","dug_berrybush2",  "dug_grass", "rope", "twigs", "dug_sapling", "gears", "spidergland", "healingsalve", "mosquitosack", "silk", "spidereggsack", "ash", "poop", "guano", "charcoal", "beefalowool", "cutreeds", "houndstooth", "ice", "stinger", "livinglog", "lightbulb", "slurper_pelt", "honeycomb", "berry_bush",
 "turf_road", "turf_rocky", "turf_forest", "turf_marsh", "turf_grass", "turf_savanna", "turf_dirt", "turf_woodfloor", "turf_carpetfloor", "turf_checkerfloor", "turf_cave", "turf_fungus", "turf_fungus_red", "turf_fungus_green", "turf_sinkhole", "turf_underrock", "turf_mud", 
  "walrus_tusk", "houndstooth", "wormlight_lesser", "wormlight", "nightmarefuel", "manrabbit_tail", "beardhair", "trinket_1", "trinket_2", "trinket_3", "trinket_4", "trinket_5", "trinket_6", "trinket_7",  "trinket_8", "trinket_9", "trinket_10", "trinket_11", "trinket_12",  "coontail", "tentaclespots", "beefalowool", "horn", "feather_robin", "feather_robin_winter", "feather_crow", "boneshard", "transistor",   "boomerang", "goose_feather", "drumstick", 
  "bearger_fur", "dragon_scales", 
  "acorn", "pinecone", "pigskin",
}

local function ItemIsInList( item, list )
    for k,v in pairs(list) do
        if v == item or k == item then
            return true
        end
    end    
end

local function Item_Valid( inst )
    local target = FindEntity(inst, 10, function(item) return (ItemIsInList( item.prefab , ValidItems)) and (not item:HasTag("no_edible")) and (not inst:HasTag("fire")) end)
    if target then end
    return target
end

local function Find_Item( inst )
    local target = Item_Valid(inst)
	if target and inst.pick == true then
        return BufferedAction(inst,target,ACTIONS.PICKUP)
		end	  end

local function GetWanderPosition(inst)
    if inst.components.follower and inst.components.follower.leader then
        return Point(inst.components.follower.leader.Transform:GetWorldPosition())
    else
        CryForQt(inst)
    end
    return inst.components.followersitcommand.currentstaylocation
end

local SummonJarvi = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SummonJarvi:OnStart()
    local root = PriorityNode({
        StandStill(self.inst, StayHere, StayHere),
        --WhileNode(function() return GetLeader(self.inst) end, "Dodge",
        --RunAway(self.inst, function() return GetLeader(self.inst) end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),
        --ChaseAndAttack(self.inst, 40),
        
        --SequenceNode{
        --    ConditionNode( function() return Pick(self.inst) and Item_Valid(self.inst) end, "collect item"),
        --    ParallelNodeAny{ WaitNode(0.25), DoAction(self.inst, function ( item ) return Find_Item(self.inst) end) ,},},
            
        --ChattyNode(self.inst, "Certo, vou ir pegar esses itens!",
        --        DoAction(self.inst, Find_Item )),            
            
        --WhileNode(function()
        --    return self.inst.CanGroundPound
        --    and self.inst.components.combat.target ~= nil
        --    --and not self.inst.components.combat.target:HasTag("beehive")
        --    and (self.inst.sg:HasStateTag("running") or
        --    not self.inst:IsNear(self.inst.components.combat.target, 10))
        --end,        
        --"Charge Behaviours", ChaseAndRam(self.inst, MAX_CHASE_TIME, GIVE_UP_DIST, MAX_CHARGE_DIST)),
        IfNode(function() return CheckForClosely(self.inst) end, "Follow Closely",
        Follow(self.inst, GetLeader, MIN_FOLLOW_CLOSE, TARGET_FOLLOW_CLOSE, MAX_FOLLOW_CLOSE, true)),
        IfNode(function() return not CheckForClosely(self.inst) end, "Follow from Distance",
        Follow(self.inst, GetLeader, MIN_FOLLOW, TARGET_FOLLOW, MAX_FOLLOW, true)),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, GetWanderPosition, MAX_WANDER_DIST)
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return SummonJarvi