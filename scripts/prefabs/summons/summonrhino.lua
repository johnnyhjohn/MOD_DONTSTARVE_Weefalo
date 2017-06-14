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
local brain = require "brains/summonrhinobrain"

------------------------------------------
-- Imagens e animacoes a importar
------------------------------------------
local assets = {
    Asset("ATLAS", "images/map_icons/summons/rhino.xml"),
    Asset("ATLAS", "images/map_icons/summons/rhino.xml"),
    ------------------------------------------
    Asset("ANIM", "anim/rook_rhino.zip"),
    ------------------------------------------
    Asset("SOUND", "sound/chess.fsb"),
}

------------------------------------------
-- Scripts necessarios
------------------------------------------
local prefabs = {
    "jao",
    "sourceofmagic",
}

------------------------------------------
local SPEECH = TUNING.JAO.SPEECH

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
        inst.sg:GoToState("idle")
        inst.components.eater:Eat(item)
    end
end

------------------------------------------
-- Fazer pet recusar item do mestre
------------------------------------------
local function OnRefuseItem(inst, item)
    inst.sg:GoToState("taunt")
    inst.components.talker:Say(SPEECH.RHINO.REFUSE)
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
    builder.rhinoInvocado = true
    ------------------------------------------
    builder.components.talker:Say(SPEECH.JAO.SUMMON.RHINO)
    ------------------------------------------
    builder.components.sanity:DoDelta(-35)
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
        inst.components.talker:Say(SPEECH.RHINO.ATTACK)
        inst.components.combat:ShareTarget(target, 30, function(dude)
            return dude:HasTag("summonedbyplayer") and 
                dude.components.follower.leader == inst.components.follower.leader
            end, 5)  
    end
end

------------------------------------------
-- Ao Comer
------------------------------------------
local function OnEat( inst, food )
    local health = inst.components.health:GetPercent()
    local currentHealth = inst.components.health.currenthealth
    if health >= 1 then
        inst.components.talker:Say(SPEECH.RHINO.EAT.FULL)
    else
        inst.components.health:DoDelta(40)
        inst.components.talker:Say(SPEECH.RHINO.EAT.EMPTY)    
    end
end

------------------------------------------
-- Ao Bater nas Coisas
------------------------------------------
local function onsmashother(inst, other)
    if not other:IsValid() then
        return
    elseif other.components.health ~= nil and not other.components.health:IsDead() then
        if other:HasTag("smashable") then
            other.components.health:Kill()
        else
            SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
            inst.SoundEmitter:PlaySound("dontstarve/creatures/rook/explo")
            inst.components.combat:DoAttack(other)
        end
    elseif other.components.workable ~= nil and other.components.workable:CanBeWorked() then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)
    end
    if (not other:HasTag("smallcreature")) and (not other.prefab == "seeds") and (not other.prefab == "seeds_cooked") and
       (not other.prefab == "flower") and (not other.prefab == "flower_evil") and (not other.prefab == "depleted_grass") and 
       (not other.prefab == "grass") and (not other.prefab == "summonedbyplayer") and (not other.prefab == "player") then 
        inst.components.locomotor:Stop()
    end    
end

------------------------------------------
-- Criar colisao
------------------------------------------
local function oncollide(inst, other)
    if other == nil or not other:IsValid() or other:HasTag("player") or
        Vector3(inst.Physics:GetVelocity()):LengthSq() < 42 then
            return
    end
    ShakeAllCameras(CAMERASHAKE.SIDE, .5, .05, .1, inst, 40)
    inst:DoTaskInTime(2 * FRAMES, onsmashother, other)
end


-- Principal
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
    MakeCharacterPhysics(inst, 100, 2.2)
    ------------------------------------------
    inst.Physics:SetCylinder(2.2, 4)
    inst.Physics:SetCollisionCallback(oncollide)
    ------------------------------------------
    -- Construcao da sombra e outros
    ------------------------------------------
    inst.DynamicShadow:SetSize(5, 3)
    inst.Transform:SetFourFaced()
    inst.Transform:SetScale(4, 2, 4)
    --inst.entity:SetPristine()
    ------------------------------------------
    -- Ligar animacoes ao character
    ------------------------------------------
    inst.AnimState:SetBank("rook")
    inst.AnimState:SetBuild("rook_rhino")
    ------------------------------------------
    -- Definicao de Sons
    ------------------------------------------
    inst.kind = ""
    inst.soundpath = "dontstarve/creatures/rook/"
    inst.effortsound = "dontstarve/creatures/rook/steam"
    ------------------------------------------
    -- Setar icone no mapa
    ------------------------------------------
    inst.MiniMapEntity:SetIcon("rhino.tex")
    inst.MiniMapEntity:SetPriority(4)
    ------------------------------------------
    -- Tags de controle
    ------------------------------------------
    inst:AddTag("summonrhino")
    inst:AddTag("sheltercarrier")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("scarytoprey")
    ------------------------------------------
    inst:AddComponent("locomotor")
    inst:AddComponent("talker")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    ------------------------------------------
    -- Queimavel
    ------------------------------------------
    MakeMediumBurnableCharacter(inst, "pig_torso")
    ------------------------------------------
    -- Lista de componentes
    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "spring"
    inst.components.combat:SetAttackPeriod(TUNING.MINOTAUR_ATTACK_PERIOD)
    inst.components.combat:SetDefaultDamage(40)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    inst.components.combat:SetRange(3, 4)
    ------------------------------------------
    local self = inst.components.combat
    local old = self.GetAttacked
    function self:GetAttacked(attacker, damage, weapon, stimuli)
        if attacker and ((attacker:HasTag("player") and not attacker:HasTag("jaobuilder")) or  attacker:HasTag("summonedbyplayer")) then
            return true
        end
        return old(self, attacker, damage, weapon, stimuli)
    end
    ------------------------------------------
    inst:AddComponent("follower")
    ------------------------------------------
    inst:AddComponent("followersitcommand")
    ------------------------------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(500)
    inst.components.health.fire_damage_scale = 0
    ------------------------------------------
    inst:AddComponent("inspectable")
    ------------------------------------------
    inst:AddComponent("inventory")
    ------------------------------------------
    inst.components.locomotor.runspeed = TUNING.MINOTAUR_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.MINOTAUR_WALK_SPEED + 3
    ------------------------------------------
    inst:RemoveTag("running")
    ------------------------------------------
    inst:AddComponent("scaler")
    inst.components.scaler:SetScale(TUNING.ROCKY_MIN_SCALE)
    ------------------------------------------
    inst:AddComponent("lootdropper")
    ------------------------------------------
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader:Enable()
    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({FOODTYPE.MEAT})
    inst.components.eater:SetOnEatFn(OnEat)
    ------------------------------------------
    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()
    ------------------------------------------
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.sleeptestfn = DefaultSleepTest
    inst.components.sleeper.wakeuptestfn = DefaultWakeTest
    ------------------------------------------
    inst:AddComponent("perishable")
    inst.components.perishable.onperishreplacement = "sourceofmagic"  
    ------------------------------------------   
    -- Instanciar Cerebro   
    ------------------------------------------
    inst:SetBrain(brain)
    ------------------------------------------
    -- Instanciar Grafico de Estados
    ------------------------------------------
    inst:SetStateGraph("SGsummonrhino")
    ------------------------------------------
    inst.destroy = false
    ------------------------------------------
    inst.target = nil
    ------------------------------------------
    inst.targetEntity = nil
    ------------------------------------------
    -- Linkar ao Mestre
    ------------------------------------------
    inst.OnBuilt = linkToBuilder
    ------------------------------------------
    -- Esperando para executar acao
    ------------------------------------------
    inst:ListenForEvent("attacked", OnAttacked)  
    --inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("death", function ( inst )
        inst.components.follower.leader.rhinoInvocado = false
    end)
    ------------------------------------------
    return inst
end

return Prefab("common/summons/summonrhino", fn, assets, prefabs)
