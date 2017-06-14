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

require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chattynode"

local START_FACE_DIST = 3
local KEEP_FACE_DIST = 5
local GO_HOME_DIST = 10
local MAX_WANDER_DIST = 12
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 20
local RUN_AWAY_DIST = 8
local STOP_RUN_AWAY_DIST = 11

local SPEECH = TUNING.JAO.SPEECH

local function GoHomeAction(inst)
    local homePos = inst.components.knownlocations:GetLocation("torre")
    return homePos ~= nil
        and BufferedAction(inst, nil, ACTIONS.WALKTO, nil, homePos)
end

local function AddFuelAction(inst)
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    if home ~= nil and home.components.fueled:GetCurrentSection() <= 1 then
        local fuel = inst.components.inventory:FindItem(function(item) return item.prefab == "pigtorch_fuel" end)
        if fuel == nil then
            fuel = SpawnPrefab("pigtorch_fuel")
            if fuel ~= nil then
                inst.components.inventory:GiveItem(fuel)
            end
        end
        return fuel ~= nil
            and BufferedAction(inst, home, ACTIONS.ADDFUEL, fuel)
            or nil
    end
end

local function FindFoodAction(inst)
    if inst.components.inventory ~= nil and inst.components.eater ~= nil then
        local target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        return target ~= nil
            and BufferedAction(inst, target, ACTIONS.EAT)
            or nil
    end
end

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and not target:HasTag("jaobuilder") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and not target:HasTag("jaobuilder") and inst:IsNear(target, KEEP_FACE_DIST)
end

local function ShouldGoHome(inst)
    local homePos = inst.components.knownlocations:GetLocation("torre")
    return homePos ~= nil and inst:GetDistanceSqToPoint(homePos:Get()) > GO_HOME_DIST * GO_HOME_DIST
end

local SummonMiniChop = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SummonMiniChop:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        ChattyNode(self.inst, SPEECH.MINICHOP.ACTION.FIGHT,
            WhileNode(function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
                ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST)))),
        ChattyNode(self.inst, SPEECH.MINICHOP.ACTION.FIGHT,
            WhileNode(function() return self.inst.components.combat.target ~= nil and self.inst.components.combat:InCooldown() end, "Dodge",
                RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST))),
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
        ChattyNode(self.inst, SPEECH.MINICHOP.ACTION.GOHOME,
            DoAction(self.inst, GoHomeAction, "Go Home", true))),
        --ChattyNode(self.inst, STRINGS.PIG_TALK_FIND_MEAT,
        --    DoAction(self.inst, function() return FindFoodAction(self.inst) end)),
        ChattyNode(self.inst, SPEECH.MINICHOP.ACTION.TORCH,
            DoAction(self.inst, AddFuelAction, "Add Fuel", true)),
        ChattyNode(self.inst, SPEECH.MINICHOP.ACTION.LOOKAT,
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("torre") end, MAX_WANDER_DIST)
    }, .25)

    self.bt = BT(self.inst, root)
end

return SummonMiniChop
