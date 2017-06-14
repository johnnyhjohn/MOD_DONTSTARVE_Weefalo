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

------------------------------------------
-- Instanciar o cerebro
------------------------------------------
local brain = require "brains/summonskipbrain"

------------------------------------------
-- Imagens e animacoes a importar
------------------------------------------
local assets = {
    Asset("ATLAS", "images/map_icons/summons/rocky.xml"),
    Asset("ATLAS", "images/map_icons/summons/rocky.xml"),
    ------------------------------------------
    Asset("ANIM",  "anim/rocky.zip"),
    ------------------------------------------
    Asset("SOUND", "sound/rocklobster.fsb"),
}

------------------------------------------
-- Scripts necessarios
------------------------------------------
local prefabs = {
    "jao",
    "sourceofmagic"
}

------------------------------------------
local SPEECH = TUNING.JAO.SPEECH

------------------------------------------
-- Aura de Sanidade
------------------------------------------
local function CalcSanityAura(inst, observer)
    return inst.components.combat.target ~= nil 
    and (TUNING.SANITYAURA_LARGE)+10
    or 1
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
        inst.sg:GoToState("idle_tendril")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/foley") 
    else
        inst.components.inventory:DropItem(item)        
    end
end 

------------------------------------------
-- Fazer pet recusar item do mestre
------------------------------------------
local function OnRefuseItem(inst, item)
    inst.sg:GoToState("taunt")
    inst.components.talker:Say(SPEECH.SKIP.REFUSE)
    inst.components.inventory:DropItem(item)
end

------------------------------------------
-- Localizar alvo
------------------------------------------
local function NormalRetargetFn(inst)
    return FindEntity(inst, TUNING.PIG_TARGET_DIST, function(guy)
        return guy:HasTag("monster") and not guy:HasTag("summonedbyplayer") and guy.components.health and not guy.components.health:IsDead() and (not guy:HasTag("summonedbyplayer")) and (not guy:HasTag("jaobuilder"))
        and inst.components.combat:CanTarget(guy)
    end, nil, { "character" }, nil)
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
    builder.skipInvocado = true
    ------------------------------------------
    builder.components.sanity:DoDelta(-30)
    ------------------------------------------
    builder.components.talker:Say(SPEECH.JAO.SUMMON.SKIP)
    ------------------------------------------
    if builder.components.combat.hurtsound ~= nil and builder.SoundEmitter ~= nil then
        builder.SoundEmitter:PlaySound(builder.components.combat.hurtsound)
    end
    ------------------------------------------
    builder:PushEvent("damaged", {})
    ------------------------------------------
    local x, y, z =  builder.Transform:GetWorldPosition()
    ------------------------------------------
    local tile = GetWorld().Map:GetTileAtPoint(x+5, y, z+5)
    local point = Point (x+5, y, z+5)
    local canspawn = tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID
    if not canspawn then point = Point(x, y, z) end
    inst.Transform:SetPosition( (point):Get() )
    ------------------------------------------
    local fx = SpawnPrefab("statue_transition")
    fx.Transform:SetScale(1, 1, 1)
    fx.Transform:SetPosition(builder:GetPosition():Get())
    inst.SoundEmitter:PlaySound("dontstarve/sanity/creature2/taunt")
    ------------------------------------------
    local xf = SpawnPrefab("statue_transition_2")
    xf.Transform:SetScale(3, 3, 3)
    xf.Transform:SetPosition(inst:GetPosition():Get())
    inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
    ------------------------------------------
end

------------------------------------------
-- Reacao ao ser atacado
------------------------------------------
local function OnAttacked(inst, data)
    local attacker = data.attacker  
    if not attacker:HasTag("summonedbyplayer") and not attacker:HasTag("jaobuilder") and not attacker:HasTag("player") then
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, 30, function(dude)
            return dude:HasTag("summonedbyplayer") and 
                dude.components.follower.leader == inst.components.follower.leader 
            end, 5)
    end
end

------------------------------------------
-- Intrucao para atacar outro
------------------------------------------
local function OnAttackOther(inst, data)
    local target = data.target
    if not target:HasTag("summonedbyplayer") and not target:HasTag("jaobuilder") and not target:HasTag("player") then
        inst.components.talker:Say(SPEECH.SKIP.ATTACK)
        inst.components.combat:ShareTarget(target, 30, function(dude)
            return dude:HasTag("summonedbyplayer") and 
                dude.components.follower.leader == inst.components.follower.leader
            end, 5)  
    end
end

------------------------------------------
-- Definir Quanto de Vida Recuperar Ao Comer
------------------------------------------
local function OnEat( inst, food )
    local health = inst.components.health:GetPercent()
    local currentHealth = inst.components.health.currenthealth
    if health >= 1 then
        inst.components.talker:Say(SPEECH.SKIP.EAT.FULL)
    else
        inst.components.health:DoDelta(50)
        inst.components.talker:Say(SPEECH.SKIP.EAT.EMPTY)
        inst.sg:GoToState("eat")    
    end
end

------------------------------------------
-- Principal
------------------------------------------
local function fn()
    ------------------------------------------
    -- Instanciar pet
    ------------------------------------------
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    ------------------------------------------
    -- Gerar estrutura
    ------------------------------------------
    MakeCharacterPhysics(inst, 30, .3)
    ------------------------------------------
    -- Construcao da sombra e outros
    ------------------------------------------
    inst.DynamicShadow:SetSize(2, 1.5)
    
    inst.Transform:SetFourFaced()
    ------------------------------------------
    -- Ligar animacoes ao character
    ------------------------------------------
    inst.AnimState:SetBank("rocky")
    inst.AnimState:SetBuild("rocky")
    inst.AnimState:PlayAnimation("idle_loop")
    ------------------------------------------
    -- Setar icone no mapa
    ------------------------------------------
    inst.MiniMapEntity:SetIcon("rocky.tex")
    inst.MiniMapEntity:SetPriority(4)
    ------------------------------------------
    -- Tags de controle
    ------------------------------------------
    inst:AddTag("summonskip")
    inst:AddTag("sheltercarrier")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("scarytoprey")
    ------------------------------------------
    inst:AddComponent("talker")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(5)
    inst.components.combat:SetAttackPeriod(5) -- 2
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    ------------------------------------------
    local self = inst.components.combat
    local old = self.GetAttacked
    ------------------------------------------
    function self:GetAttacked(attacker, damage, weapon, stimuli)
                if attacker and ((attacker:HasTag("player") and not attacker:HasTag("jaobuilder"))  or  attacker:HasTag("summonedbyplayer")) then
            return true
        end
        return old(self, attacker, damage, weapon, stimuli)
    end
    ------------------------------------------
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura
    ------------------------------------------
    inst:AddComponent("follower")
    ------------------------------------------
    inst:AddComponent("followersitcommand")
    ------------------------------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(800)
    inst.components.health.fire_damage_scale = 0
    ------------------------------------------
    inst:AddComponent("inspectable")
    ------------------------------------------
    inst:AddComponent("inventory")
    ------------------------------------------
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 9
    inst.components.locomotor.walkspeed = 6
    ------------------------------------------
    inst:AddComponent("scaler")
    inst.components.scaler:SetScale(TUNING.ROCKY_MAX_SCALE)
    ------------------------------------------
    inst:AddComponent("lootdropper")
    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.ELEMENTAL }, { FOODTYPE.ELEMENTAL })
    inst.components.eater:SetOnEatFn(OnEat)
    ------------------------------------------
    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()
    ------------------------------------------
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader:Enable()
    ------------------------------------------
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.sleeptestfn = DefaultSleepTest
    inst.components.sleeper.wakeuptestfn = DefaultWakeTest
    ------------------------------------------    
    inst:AddComponent("perishable")
    inst.components.perishable.onperishreplacement = "sourceofmagic"
    ------------------------------------------    
    inst:SetBrain(brain)
    inst:SetStateGraph("SGsummonskip")
    ------------------------------------------
    inst.pick = false
    ------------------------------------------
    inst.OnBuilt = linkToBuilder
    ------------------------------------------
    inst:ListenForEvent("attacked", OnAttacked)  
    --inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("death", function ( inst )
        inst.components.follower.leader.skipInvocado = false
    end)
    ------------------------------------------
    return inst
end

return Prefab("common/summons/summonskip", fn, assets, prefabs)