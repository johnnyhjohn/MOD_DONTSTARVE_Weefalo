require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/follow"
require "behaviours/attackwall"
--require "behaviours/runaway"
--require "behaviours/doaction"

local BrainCommon = require("brains/braincommon")

-- states
local GREETING = "greeting"
local LOITERING = "loitering"
local WANDERING = "wandering"

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5
local WANDER_DIST_DAY = 20
local WANDER_DIST_NIGHT = 5
local START_FACE_DIST = 4
local KEEP_FACE_DIST = 6

local MAX_CHASE_TIME = 6

local MIN_FOLLOW_DIST = 1
local TARGET_FOLLOW_DIST = 3
local MAX_FOLLOW_DIST = 5
local MIN_FOLLOW = 1
local TARGET_FOLLOW = 2
local MAX_FOLLOW = 3
local MIN_FOLLOW_CLOSE = 1
local MAX_FOLLOW_CLOSE = 3
local TARGET_FOLLOW_CLOSE = 2

local GREET_SEARCH_RADIUS = 15
local GREET_DURATION = 3

local MIN_GREET_DIST = 1
local TARGET_GREET_DIST = 3
local MAX_GREET_DIST = 5

local LOITER_SEARCH_RADIUS = 30
local TARGET_LOITER_DIST = 10
local LOITER_DURATION = TUNING.SEG_TIME * 4

local LOITER_ANCHOR_RESET_DIST = 20
local LOITER_ANCHOR_HERD_DIST = 40

local MAX_WANDER_DIST = 0


local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GetWanderDistFn(inst)
    return TheWorld.state.isday and WANDER_DIST_DAY or WANDER_DIST_NIGHT
end

local function GetLoiterTarget(inst)
    return FindClosestPlayerToInst(inst, LOITER_SEARCH_RADIUS, true)
end

local function GetGreetTarget(inst)
    return FindClosestPlayerToInst(inst, GREET_SEARCH_RADIUS, true)
end

local function GetGreetTargetPosition(inst)
    local greetTarget = GetGreetTarget(inst)
    return greetTarget ~= nil and greetTarget:GetPosition() or inst:GetPosition()
end

local function GetLoiterAnchor(inst)
    if inst.components.knownlocations:GetLocation("loiteranchor") == nil then
        inst.components.knownlocations:RememberLocation("loiteranchor", inst:GetPosition())

    elseif inst.components.knownlocations:GetLocation("herd") ~= nil and inst:GetDistanceSqToPoint(inst.components.knownlocations:GetLocation("herd")) < LOITER_ANCHOR_HERD_DIST*LOITER_ANCHOR_HERD_DIST then
        inst.components.knownlocations:RememberLocation("loiteranchor", inst.components.knownlocations:GetLocation("herd"))

    elseif inst:GetDistanceSqToPoint(inst.components.knownlocations:GetLocation("loiteranchor")) > LOITER_ANCHOR_RESET_DIST*LOITER_ANCHOR_RESET_DIST then
        inst.components.knownlocations:RememberLocation("loiteranchor", inst:GetPosition())
    end

    return inst.components.knownlocations:GetLocation("loiteranchor")
end

local function TryBeginLoiterState(inst)
    local herd = inst.components.herdmember and inst.components.herdmember:GetHerd()
    if (herd and herd.components.mood and herd.components.mood:IsInMood())
        or (inst.components.mood and inst.components.mood:IsInMood()) then
        return false
    end

    if GetTime() - inst._startgreettime < GREET_DURATION then
        inst._startgreettime = GetTime() - GREET_DURATION
        return true
    end
    return false
end

local function TryBeginGreetingState(inst)
    local herd = inst.components.herdmember and inst.components.herdmember:GetHerd()
    if (herd and herd.components.mood and herd.components.mood:IsInMood())
        or (inst.components.mood and inst.components.mood:IsInMood()) then
        return false
    end

    if inst.components.domesticatable ~= nil
        and inst.components.domesticatable:GetDomestication() > 0.0
        and GetGreetTarget(inst) ~= nil then

        inst._startgreettime = GetTime()
        return true
    end
    return false
end

local function ShouldWaitForHeavyLifter(inst, target)
    if target ~= nil and
        target.components.inventory:IsHeavyLifting() and
        inst.components.rideable.canride then
        --Check if target is heavy lifting towards me
        --(dot product between target's facing and target to me > 0)
        local x, y, z = target.Transform:GetWorldPosition()
        local x1, y1, z1 = inst.Transform:GetWorldPosition()
        local dx = x1 - x
        local dz = z1 - z
        if dx * dx + dz * dz < MAX_FOLLOW_DIST * MAX_FOLLOW_DIST then
            local theta = -target.Transform:GetRotation() * DEGREES
            --local dx1 = math.cos(theta)
            --local dz1 = math.sin(theta)
            return dx * math.cos(theta) + dz * math.sin(theta) > 0
        end
    end
    return false
end

local function StayHere(inst)
    return inst.components.followersitcommand:IsCurrentlyStaying()
end

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
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

local function GetWanderPosition(inst)
    if inst.components.follower and inst.components.follower.leader then
        return Point(inst.components.follower.leader.Transform:GetWorldPosition())
    else
        CryForQt(inst)
    end
    -- return inst.components.followersitcommand.currentstaylocation
end

local function GetWaitForHeavyLifter(inst)
    local target = GetGreetTarget(inst)
    return ShouldWaitForHeavyLifter(inst, target) and target or nil
end

local function InState(inst, state)
    if inst._startgreettime == nil then
        inst._startgreettime = -1000000
    end
    local timedelta = GetTime() - inst._startgreettime
    if timedelta < GREET_DURATION then
        return state == GREETING
    elseif timedelta < LOITER_DURATION then
        return state == LOITERING
    else
        return state == WANDERING
    end
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

local BeefaloBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function BeefaloBrain:OnStart()
    local root = PriorityNode(
    {
        -- StandStill(self.inst, StayHere, StayHere),
        WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
            Panic(self.inst)),
        IfNode(function() return self.inst.components.combat.target ~= nil end, "hastarget",
            AttackWall(self.inst)),
        ChaseAndAttack(self.inst, MAX_CHASE_TIME),
        Follow(self.inst, function() return self.inst.components.follower ~= nil and self.inst.components.follower.leader or nil end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, false),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),

        -- hanging around herd
        ConditionNode(function() return InState(self.inst, WANDERING) and TryBeginGreetingState(self.inst) end, "Wandering"),

        -- wants to greet feeder
        WhileNode(function() return InState(self.inst, GREETING) end, "Greeting", PriorityNode{
            Follow(self.inst, GetGreetTarget, MIN_GREET_DIST, TARGET_GREET_DIST, MAX_GREET_DIST, true),
            ActionNode(function() TryBeginLoiterState(self.inst) end, "Finish greeting")
        }),

        -- anchor to nearest saltlick
        BrainCommon.AnchorToSaltlick(self.inst),

        -- waiting for feeder
        WhileNode(function() return InState(self.inst, LOITERING) end, "Loitering", PriorityNode{
            WhileNode(function() return GetLoiterTarget(self.inst) ~= nil end, "Anyone nearby?", PriorityNode{
                FailIfSuccessDecorator(ActionNode(function() TryBeginLoiterState(self.inst) end, "Reset Loiter Time")),
                FaceEntity(self.inst, GetWaitForHeavyLifter, ShouldWaitForHeavyLifter),
                Follow(self.inst, GetGreetTarget, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, false),
                Wander(self.inst, function() return GetGreetTargetPosition(self.inst) end, TARGET_LOITER_DIST)
            }),
            Wander(self.inst, function() return GetLoiterAnchor(self.inst) end, GetWanderDistFn),
        }),

        IfNode(function() return CheckForClosely(self.inst) end, "Follow Closely",
        Follow(self.inst, GetLeader, MIN_FOLLOW_CLOSE, TARGET_FOLLOW_CLOSE, MAX_FOLLOW_CLOSE, true)),
        IfNode(function() return not CheckForClosely(self.inst) end, "Follow from Distance",
        Follow(self.inst, GetLeader, MIN_FOLLOW, TARGET_FOLLOW, MAX_FOLLOW, true)),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, GetWanderPosition, MAX_WANDER_DIST)

        --Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("herd") end, GetWanderDistFn)

    }, .25)

    self.bt = BT(self.inst, root)
end

return BeefaloBrain
