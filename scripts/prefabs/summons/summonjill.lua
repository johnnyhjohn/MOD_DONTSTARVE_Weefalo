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

local assets =
{
    Asset("ANIM", "anim/beefalo_basic.zip"),
    Asset("ANIM", "anim/beefalo_actions.zip"),
    Asset("ANIM", "anim/beefalo_actions_domestic.zip"),
    Asset("ANIM", "anim/beefalo_actions_quirky.zip"),
    Asset("ANIM", "anim/beefalo_build.zip"),
    Asset("ANIM", "anim/beefalo_shaved_build.zip"),
    Asset("ANIM", "anim/beefalo_baby_build.zip"),
    ------------------------------------------
    Asset("ANIM", "anim/beefalo_domesticated.zip"),
    Asset("ANIM", "anim/beefalo_personality_docile.zip"),
    Asset("ANIM", "anim/beefalo_personality_ornery.zip"),
    Asset("ANIM", "anim/beefalo_personality_pudgy.zip"),
    ------------------------------------------
    Asset("ANIM", "anim/beefalo_fx.zip"),
    ------------------------------------------
    Asset("SOUND", "sound/beefalo.fsb"),
    ------------------------------------------
    Asset("ATLAS", "images/map_icons/summons/jill.xml"),
    Asset("ATLAS", "images/map_icons/summons/jill.xml"),
    
}

------------------------------------------
-- Prefabs Necessarios
------------------------------------------
local prefabs =
{
    "jao",
    "meat",
    "poop",
    "beefalowool",
    "horn",
}

------------------------------------------
-- Definicao do Cerebro
------------------------------------------
local brain = require "brains/mybeefalobrain"

------------------------------------------
-- O Que Pode Dropar
------------------------------------------
SetSharedLootTable( 'beefalo', {{'meat', 0.01},})

------------------------------------------
-- Sons
------------------------------------------
local sounds = 
{
    walk = "dontstarve/beefalo/walk",
    grunt = "dontstarve/beefalo/grunt",
    yell = "dontstarve/beefalo/yell",
    swish = "dontstarve/beefalo/tail_swish",
    curious = "dontstarve/beefalo/curious",
    angry = "dontstarve/beefalo/angry",
    sleep = "dontstarve/beefalo/sleep",
}

------------------------------------------
local SPEECH = TUNING.JAO.SPEECH

------------------------------------------
-- Definicao de Tendencias
------------------------------------------
local tendencies =
{
    DEFAULT =
    {
    },

    ORNERY =
    {
        build = "beefalo_personality_ornery",
    },

    RIDER =
    {
        build = "beefalo_personality_docile",
    },

    PUDGY =
    {
        build = "beefalo_personality_pudgy",
        customactivatefn = function(inst)
            inst:AddComponent("sanityaura")
            inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY
        end,
        customdeactivatefn = function(inst)
            inst:RemoveComponent("sanityaura")
        end,
    },
}

------------------------------------------
-- Limpar Sobrepoiscao de Animacoes
------------------------------------------
local function ClearBuildOverrides(inst, animstate)
    if animstate ~= inst.AnimState then
        animstate:ClearOverrideBuild("beefalo_build")
    end
    animstate:ClearOverrideBuild("beefalo_personality_docile")
end

------------------------------------------
-- Fazer Sobreposicao de Animacoes
------------------------------------------
local function ApplyBuildOverrides(inst, animstate)
    local herd = inst.components.herdmember and inst.components.herdmember:GetHerd()
    local basebuild = (inst:HasTag("baby") and "beefalo_baby_build")
            or (inst.components.beard.bits == 0 and "beefalo_shaved_build")
            or (inst.components.domesticatable:IsDomesticated() and "beefalo_domesticated")
            or "beefalo_build"
    if animstate ~= nil and animstate ~= inst.AnimState then
        animstate:AddOverrideBuild(basebuild)
    else
        animstate:SetBuild(basebuild)
    end
    ------------------------------------------
    if (herd and herd.components.mood and herd.components.mood:IsInMood())
        or (inst.components.mood and inst.components.mood:IsInMood()) then
        animstate:Show("HEAT")
    else
        animstate:Hide("HEAT")
    end
    ------------------------------------------
    if tendencies[inst.tendency].build ~= nil then
        animstate:AddOverrideBuild(tendencies[inst.tendency].build)
    elseif animstate == inst.AnimState then
        -- this presumes that all the face builds have the same symbols
        animstate:ClearOverrideBuild("beefalo_personality_docile")
    end
end

------------------------------------------
-- Ao Entrar Em Um Novo Humor
------------------------------------------
local function OnEnterMood(inst)
    inst:AddTag("scarytoprey")
    inst:ApplyBuildOverrides(inst.AnimState)
    if inst.components.rideable and inst.components.rideable:GetRider() ~= nil then
        inst:ApplyBuildOverrides(inst.components.rideable:GetRider().AnimState)
    end
end

------------------------------------------
-- Ao Mudar De Humor
------------------------------------------
local function OnLeaveMood(inst)
    inst:RemoveTag("scarytoprey")
    inst:ApplyBuildOverrides(inst.AnimState)
    if inst.components.rideable ~= nil and inst.components.rideable:GetRider() ~= nil then
        inst:ApplyBuildOverrides(inst.components.rideable:GetRider().AnimState)
    end
end

------------------------------------------
-- Re-Localizar Alvo
------------------------------------------
local function Retarget(inst)
    local herd = inst.components.herdmember ~= nil and inst.components.herdmember:GetHerd() or nil
    return herd ~= nil
        and herd.components.mood ~= nil
        and herd.components.mood:IsInMood()
        and FindEntity(
                inst,
                TUNING.BEEFALO_TARGET_DIST,
                function(guy)
                    return inst.components.combat:CanTarget(guy) and (not guy:HasTag("summonedbyplayer")) and (not guy:HasTag("jaobuilder"))
                end,
                { "_combat" }, --See entityreplica.lua (re: "_combat" tag)
                { "beefalo", "wall", "INLIMBO" }
            )
        or nil
end

------------------------------------------
-- Manter Alvo
------------------------------------------
local function KeepTarget(inst, target)
    local herd = inst.components.herdmember ~= nil and inst.components.herdmember:GetHerd() or nil
    return herd == nil
        or herd.components.mood == nil
        or not herd.components.mood:IsInMood()
        or inst:IsNear(herd, TUNING.BEEFALO_CHASE_DIST)
end

------------------------------------------
-- Procurar Um Novo Alvo
------------------------------------------
local function OnNewTarget(inst, data)
    if data ~= nil and data.target ~= nil and inst.components.follower ~= nil and data.target == inst.components.follower.leader then
        inst.components.follower:SetLeader(nil)
    end
end

------------------------------------------
-- Compartilhar Alvo com Player
------------------------------------------
local function CanShareTarget(dude)
    return dude:HasTag("beefalo")
        and not dude:IsInLimbo()
        and not (dude.components.health:IsDead() or dude:HasTag("player"))
end

------------------------------------------
-- Reacao Ao Ser Atacado
------------------------------------------
local function OnAttacked(inst, data)
        inst.components.combat:SetTarget(data.attacker)
        inst.components.combat:ShareTarget(data.attacker, 30, CanShareTarget, 5)
end

------------------------------------------
-- Pegar Status
------------------------------------------
local function GetStatus(inst)
    return (inst.components.follower.leader ~= nil and "FOLLOWER")
        or (inst.components.beard ~= nil and inst.components.beard.bits == 0 and "NAKED")
        or (inst.components.domesticatable ~= nil and
            inst.components.domesticatable:IsDomesticated() and
            (inst.tendency == TENDENCY.DEFAULT and "DOMESTICATED" or inst.tendency))
        or nil
end

------------------------------------------
-- Resetar Pelo
------------------------------------------
local function OnResetBeard(inst)
    inst.sg:GoToState("shaved")
    inst.components.brushable:SetBrushable(false)
    inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_SHAVED_OBEDIENCE)
end

------------------------------------------
-- Teste se Pode Ser Barbeado
------------------------------------------
local function CanShaveTest(inst)
    if inst.components.sleeper:IsAsleep() then
        return true
    else
        return false, "AWAKEBEEFALO"
    end
end

------------------------------------------
-- Troca de Animacao Ao Barbear 
------------------------------------------
local function OnShaved(inst)
    inst:ApplyBuildOverrides(inst.AnimState)
end

------------------------------------------
-- Quando o Pelo Crescer
------------------------------------------
local function OnHairGrowth(inst)
    if inst.components.beard.bits == 0 then
        inst.hairGrowthPending = true
        if inst.components.rideable ~= nil then
            inst.components.rideable:Buck()
        end
    end
end

------------------------------------------
-- Ao Ser Barbado
------------------------------------------
local function OnBrushed(inst, data)
    if data.numprizes > 0 and inst.components.domesticatable ~= nil then
        inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_BRUSHED_DOMESTICATION)
        inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_BRUSHED_OBEDIENCE)
    end
end

------------------------------------------
-- Fazer pet aceitar item do mestre
------------------------------------------
local function ShouldAcceptItem(inst, item)
    return inst.components.eater:CanEat(item)
end

------------------------------------------
-- Fazer pet pegar o item do mestre
------------------------------------------
local function OnGetItemFromPlayer(inst, giver, item)
    if inst.components.eater:CanEat(item) then
        inst.components.eater:Eat(item)
        inst.sg:GoToState("pleased")
    end
end 

------------------------------------------
-- Fazer pet recusar item do mestre
------------------------------------------
local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
    inst.components.talker:Say(SPEECH.JILL.REFUSE)
end

------------------------------------------
-- Definir Tendencias
------------------------------------------
local function SetTendency(inst, changedomestication)
    if not inst.components.domesticatable:IsDomesticated() then
        local tendencysum = 0
        local maxtendency = nil
        local maxtendencyval = 0
        for k,v in pairs(inst.components.domesticatable.tendencies) do
            tendencysum = tendencysum + v
            if v > maxtendencyval then
                maxtendencyval = v
                maxtendency = k
            end 
        end
        inst.tendency = (tendencysum < 0.1 or maxtendencyval < tendencysum * 0.5) and TENDENCY.DEFAULT or maxtendency
    end
    ------------------------------------------
    if changedomestication ~= nil then
        if tendencies[inst.tendency].customactivatefn ~= nil and changedomestication == "domestication" then
            tendencies[inst.tendency].customactivatefn(inst)
   --     elseif tendencies[inst.tendency].customdeactivatefn ~= nil and changedomestication == "feral" then
     --       tendencies[inst.tendency].customdeactivatefn(inst)
        end
    end
    ------------------------------------------
    if inst.components.domesticatable:IsDomesticated() then
        inst.components.domesticatable:SetMinObedience(TUNING.BEEFALO_MIN_DOMESTICATED_OBEDIENCE[inst.tendency])
    else
        inst.components.domesticatable:SetMinObedience(0)
    end
    ------------------------------------------
    if inst.components.domesticatable:IsDomesticated() then
        inst.components.combat:SetDefaultDamage(TUNING.BEEFALO_DAMAGE.DEFAULT+2)
        inst.components.locomotor.runspeed = 10
    else
        inst.components.combat:SetDefaultDamage(TUNING.BEEFALO_DAMAGE.DEFAULT+2)
        inst.components.locomotor.runspeed = 10
    end
    ------------------------------------------
    inst:ApplyBuildOverrides(inst.AnimState)
    ------------------------------------------
    if inst.components.rideable and inst.components.rideable:GetRider() ~= nil then
        inst:ApplyBuildOverrides(inst.components.rideable:GetRider().AnimState)
    end
end

------------------------------------------
-- Padrao Beefalo
------------------------------------------
local function ShouldBeg(inst)
end

------------------------------------------
-- Desmontar Ao Morrer
------------------------------------------
local function OnDeath(inst, data)
    if inst.components.rideable:IsBeingRidden() then
        inst.components.rideable:Buck(true)
        if inst.components.health:IsDead() then
            if inst.sg.currentstate.name ~= "death" then
                inst.sg:GoToState("death")
            end
        end    
    end
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 3)
    for k,sela in pairs(ents) do
        if sela.components.saddler then
            sela:Remove()
        end
    end
end

------------------------------------------
-- Padrao de Domesticacao
------------------------------------------
local function DomesticationTriggerFn(inst)
end

------------------------------------------
-- Definir Quanto de Vida Recuperar Ao Comer
------------------------------------------
local function OnEat( inst, food )
    local health = inst.components.health:GetPercent()
    local currentHealth = inst.components.health.currenthealth
    if health >= 1 then
        inst.components.talker:Say(SPEECH.JILL.EAT.FULL)
    else
        inst.components.health:DoDelta(20)
        inst.components.talker:Say(SPEECH.JILL.EAT.EMPTY)
        inst.sg:GoToState("eat")    
    end
end

------------------------------------------
-- Teste Se Pode Dormir
------------------------------------------
local function MountSleepTest(inst)
    return not inst.components.rideable:IsBeingRidden() and DefaultSleepTest(inst)
end

------------------------------------------
-- Ao Salvar
------------------------------------------
local function OnSave(inst, data)
    data.tendency = inst.tendency
end

------------------------------------------
-- Ao Carregar
------------------------------------------
local function OnLoad(inst, data)
    if data and data.tendency then
        inst.tendency = data.tendency
    end
end

------------------------------------------
-- Debug
------------------------------------------
local function GetDebugString(inst)
    return string.format( "tendency %s nextbuck %.2f", inst.tendency, GetTaskRemaining(inst._bucktask) )
end

------------------------------------------
-- Ligar ao mestre
------------------------------------------
local function linkToBuilder(inst, builder)
    if not builder.components.leader then
        builder:AddComponent("leader")
    end
    builder.components.leader:AddFollower(inst, true)
    ------------------------------------------
    builder.components.sanity:DoDelta(-25)
    ------------------------------------------
    builder.jillInvocado = true
    ------------------------------------------
    local x, y, z =  builder.Transform:GetWorldPosition()
    ------------------------------------------
    local tile = GetWorld().Map:GetTileAtPoint(x+5, y, z+5)
    local point = Point (x+5, y, z+5)
    local canspawn = tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID
    if not canspawn then point = Point(x, y, z) end
    inst.Transform:SetPosition( (point):Get() )
   
end

------------------------------------------
-- Definir o beefalo completamente domesticavel
------------------------------------------
local function DomesticationAndObedienceTotal(inst)
    -- Permitir colocar a sela
    inst.components.rideable:SetSaddleable(true)
    -- Trocar valores da obediencia
    inst.components.domesticatable:SetMinObedience(0.6)
    -- Trocar a obediencia
    inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_OVERFEED_OBEDIENCE)
    inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_OVERFEED_DOMESTICATION)
    inst.components.domesticatable:DeltaTendency(TENDENCY.PUDGY, TUNING.BEEFALO_PUDGY_OVERFEED)
    -- Fome
    inst.components.hunger:DoDelta(100)

end

local function beefalo()
    local inst = CreateEntity()
    ------------------------------------------
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    ------------------------------------------
    MakeCharacterPhysics(inst, 100, .5)
    ------------------------------------------
    inst.DynamicShadow:SetSize(6, 2)
    inst.Transform:SetSixFaced()
    ------------------------------------------
    inst.AnimState:SetBank("beefalo")
    inst.AnimState:SetBuild("beefalo_build")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:Hide("HEAT")
    ------------------------------------------
    inst:AddTag("beefalo")
    inst:AddTag("animal")
    inst:AddTag("summonjill")
    inst:AddTag("largecreature")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("bearded")
    inst:AddTag("herdmember")
    inst:AddTag("saddleable")
    inst:AddTag("rideable")
    inst:AddTag("saddled")
    inst:AddTag("companion")
    inst:AddTag("domesticatable")
    ------------------------------------------
    -- Setar icone no mapa
    ------------------------------------------
    inst.MiniMapEntity:SetIcon("jill.tex")
    inst.MiniMapEntity:SetPriority(4)
    ------------------------------------------
    inst.sounds = sounds
    ------------------------------------------
    inst:AddComponent("talker")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    ------------------------------------------
    inst:AddComponent("beard")
    inst.components.beard.bits = 3
    inst.components.beard.daysgrowth = TUNING.BEEFALO_HAIR_GROWTH_DAYS + 1
    inst.components.beard.onreset = OnResetBeard
    inst.components.beard.canshavetest = CanShaveTest
    inst.components.beard.prize = "beefalowool"
    inst.components.beard:AddCallback(0, OnShaved)
    inst.components.beard:AddCallback(TUNING.BEEFALO_HAIR_GROWTH_DAYS, OnHairGrowth)
    ------------------------------------------
    inst:AddComponent("brushable")
    inst.components.brushable.regrowthdays = 1
    inst.components.brushable.max = 1
    inst.components.brushable.prize = "beefalowool"
    inst:ListenForEvent("brushed", OnBrushed)
    ------------------------------------------
    inst:AddComponent("hunger")
    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE, FOODTYPE.ROUGHAGE }, { FOODTYPE.VEGGIE, FOODTYPE.ROUGHAGE })
    inst.components.eater:SetAbsorptionModifiers(4,1,1)
    inst.components.eater:SetOnEatFn(OnEat)
    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "beefalo_body"
    inst.components.combat:SetDefaultDamage(TUNING.BEEFALO_DAMAGE.ORNERY)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    ------------------------------------------
    local self = inst.components.combat
    local old = self.GetAttacked
    ------------------------------------------
    function self:GetAttacked(attacker, damage, weapon, stimuli)
        if attacker and ((attacker:HasTag("player") and not attacker:HasTag("jaobuilder")) or attacker:HasTag("summonedbyplayer")) then
            return true
        end
        return old(self, attacker, damage, weapon, stimuli)
    end
    ------------------------------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BEEFALO_HEALTH)
    inst.components.health.nofadeout = true
    inst.components.health:StartRegen(TUNING.BEEFALO_HEALTH_REGEN, TUNING.BEEFALO_HEALTH_REGEN_PERIOD)
    ------------------------------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('beefalo')
    ------------------------------------------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    ------------------------------------------
    inst:AddComponent("knownlocations")
    ------------------------------------------
    inst:AddComponent("leader")
    ------------------------------------------
    inst:AddComponent("follower")
    --inst.components.follower.maxfollowtime = TUNING.BEEFALO_FOLLOW_TIME
    inst.components.follower.canaccepttarget = true
    ------------------------------------------
    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()
    ------------------------------------------
    inst:AddComponent("rideable")
    inst.components.rideable:SetRequiredObedience(0)
    inst.components.rideable.canride = true
    inst.components.rideable.saddle = SpawnPrefab("saddle_basic")        
    ------------------------------------------
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false
    ------------------------------------------
    inst:AddComponent("domesticatable")
    inst.components.domesticatable:SetDomesticationTrigger(DomesticationTriggerFn)
    ------------------------------------------
    inst:AddComponent("locomotor") 
    inst.components.locomotor.walkspeed = TUNING.BEEFALO_WALK_SPEED+3
    inst.components.locomotor.runspeed = 10
    ------------------------------------------
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.sleeptestfn = MountSleepTest
    ------------------------------------------
    inst:AddComponent("herdmember")
    inst.components.herdmember:Enable(false)
    ------------------------------------------
    inst:AddComponent("mood")
    inst.components.mood:SetInMoodFn(OnEnterMood)
    inst.components.mood:SetLeaveMoodFn(OnLeaveMood)
    inst.components.mood:CheckForMoodChange()
    inst.components.mood:Enable(false)
    ------------------------------------------
    inst:AddComponent("inventory")
    DomesticationAndObedienceTotal(inst)
    ------------------------------------------
    MakeLargeBurnableCharacter(inst, "beefalo_body")
    MakeLargeFreezableCharacter(inst, "beefalo_body")
    ------------------------------------------
    inst.ApplyBuildOverrides = ApplyBuildOverrides
    inst.ClearBuildOverrides = ClearBuildOverrides
    ------------------------------------------
    inst.SetTendency = SetTendency
    inst:SetTendency()
    ------------------------------------------
    inst.ShouldBeg = ShouldBeg
    ------------------------------------------
    inst:SetBrain(brain)
    inst:SetStateGraph("SGBeefalo")
    ------------------------------------------
    inst.OnBuilt = linkToBuilder
    inst.debugstringfn = GetDebugString
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    ------------------------------------------
    inst:DoPeriodicTask(5, function() 
        DomesticationAndObedienceTotal(inst) 
    end)
    ------------------------------------------
--inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath) 
    --inst:ListenForEvent("healthdelta", OnHealthDelta)
    inst:ListenForEvent("death", function ( inst )
        inst.components.follower.leader.jillInvocado = false
    end)

    return inst
end

return Prefab("summons/summonjill", beefalo, assets, prefabs)
