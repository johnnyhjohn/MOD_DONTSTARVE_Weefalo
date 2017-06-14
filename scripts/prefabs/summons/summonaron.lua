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
    ------------------------------------------
    Asset("SOUND", "sound/pig.fsb"),
    ------------------------------------------
    Asset("ANIM", "anim/manrabbit_basic.zip"),
    Asset("ANIM", "anim/manrabbit_actions.zip"),
    Asset("ANIM", "anim/manrabbit_attacks.zip"),
    Asset("ANIM", "anim/manrabbit_build.zip"),
    ------------------------------------------
    Asset("SOUND", "sound/bunnyman.fsb"),
    ------------------------------------------
    Asset("ANIM", "anim/manrabbit_beard_build.zip"),
    Asset("ANIM", "anim/manrabbit_beard_basic.zip"),
    Asset("ANIM", "anim/manrabbit_beard_actions.zip"),    
}

local prefabs = {}

------------------------------------------
local SPEECH = TUNING.JAO.SPEECH

local normalbrain = require "brains/summonaronbrain"
local werearonbrain = require "brains/summonaronbrain"

------------------------------------------
-- Definir o que fazer ao falar
------------------------------------------
local function ontalk(inst, script)
    inst.SoundEmitter:PlaySound("dontstarve/pig/grunt")
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
    builder.aronInvocado = true
    ------------------------------------------
    builder.components.sanity:DoDelta(-25)
    ------------------------------------------
    --- Emitir sons e animacoes
    if builder.components.combat.hurtsound ~= nil and builder.SoundEmitter ~= nil then
        builder.SoundEmitter:PlaySound(builder.components.combat.hurtsound)
    end
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
-- Fazer pet aceitar item do mestre
------------------------------------------
local function ShouldAcceptItem(inst, item)
    return inst.components.eater:CanEat(item)
end

------------------------------------------
-- Fazer pet receber o item do mestre
------------------------------------------
local function OnGetItemFromPlayer(inst, giver, item)
    if inst.components.eater:CanEat(item) then
        inst.components.eater:Eat(item)
        inst.sg:GoToState("idle_tendrils")
        inst.SoundEmitter:PlaySound("dontstarve/creatures/rocklobster/foley") 
    end
end 

------------------------------------------
-- Fazer pet recusar item do mestre
------------------------------------------
local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
    inst.components.talker:Say(SPEECH.ARON.REFUSE)
end

------------------------------------------
-- Localizar alvo para o Aron transformado
------------------------------------------
local function WerearonRetargetFn(inst)
    return FindEntity(
        inst,
        SpringCombatMod(TUNING.PIG_TARGET_DIST),
        function(guy)
            return inst.components.combat:CanTarget(guy) and (not guy:HasTag("wall")) and (not guy:HasTag("summonedbyplayer")) and (not guy:HasTag("jaobuilder"))
               and not (guy.sg ~= nil and guy.sg:HasStateTag("transform"))
        end,
        { "_combat" }, { "werepig", "alwaysblock", "beaver" }
    )
end

------------------------------------------
-- Localizar alvo para o Aron normal
------------------------------------------
local function NormalRetargetFn(inst)
    if inst:HasTag("werearon") then
        return FindEntity(inst, TUNING.PIG_TARGET_DIST, function(guy)
            return guy:HasTag("monster") and not guy:HasTag("summonedbyplayer") and 
                guy.components.health and not guy.components.health:IsDead()
                and inst.components.combat:CanTarget(guy)
        end, nil, { "character" }, nil)
    end
    return nil
end

------------------------------------------
-- Definir quanto de vida recuperar ao comer
------------------------------------------
local function OnEat( inst, food )
    local health = inst.components.health:GetPercent()
    local currentHealth = inst.components.health.currenthealth
    if health >= 1 then
        inst.components.talker:Say(SPEECH.WEREARON.EAT.FULL)
    else
        inst.components.health:DoDelta(50)
        inst.components.talker:Say(SPEECH.WEREARON.EAT.EMPTY)
        inst.sg:GoToState("eat")    
    end
end

------------------------------------------
-- Definir congelamento ao acertar outro
------------------------------------------
local function OnHitOther(inst, data)
    local other = data.target
    local random = math.random(0,6)
    if other and other.components.freezable and random == 1 and inst.area then
        other.components.freezable:AddColdness(2)
        other.components.freezable:SpawnShatterFX()
    end
end

------------------------------------------
--  Criacao do Aron padrao
------------------------------------------
local function SetNormalAron(inst)
    inst.AnimState:SetBuild("rabbit_winter_build")
    inst.AnimState:SetBank("rabbit")
    inst.AnimState:Hide("hat")
    ------------------------------------------
    inst:SetBrain(normalbrain)
    inst:SetStateGraph("SGsummonaronbasic")
    ------------------------------------------
    inst:RemoveTag("werearon")
    ------------------------------------------
    inst.components.health:SetMaxHealth(350)
    ------------------------------------------    
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    ------------------------------------------    
    inst.components.locomotor.runspeed = 12
    inst.components.locomotor.walkspeed = 8
    ------------------------------------------
    inst.components.scaler:SetScale((TUNING.ROCKY_MIN_SCALE)+0.5)
    ------------------------------------------
    inst.components.werebeast:SetOnNormalFn(SetNormalAron)
    ------------------------------------------  
end

------------------------------------------
-- Criacao do Aron Padrao
------------------------------------------
local function SetWereAron(inst)
    inst.AnimState:SetBuild("manrabbit_build")
    inst.AnimState:SetBank("manrabbit")
    ------------------------------------------
    inst:SetBrain(werearonbrain)
    inst:SetStateGraph("SGsummonaron")
    ------------------------------------------
    inst:AddTag("werearon")
    ------------------------------------------
    inst.components.locomotor.runspeed = 9
    inst.components.locomotor.walkspeed = 6
    ------------------------------------------
    inst.components.scaler:SetScale((TUNING.ROCKY_MAX_SCALE)+0.5)
    ------------------------------------------
    if inst.hunterMode then
        inst.components.combat:SetRetargetFunction(3, WerearonRetargetFn)
    else
        inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)    
    end            
end

------------------------------------------
-- Funcao para efetuar as trocas de formas
------------------------------------------
local function change_form( inst )
    local fx = SpawnPrefab("statue_transition_2")
    fx.Transform:SetScale(3, 3, 3)
    fx.Transform:SetPosition(inst:GetPosition():Get())
    inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
    if inst.transformed then
        inst.components.talker:Say(SPEECH.ARON.ACTION.DESTRANSFORMA)
        SetNormalAron(inst)
    else
        inst.components.talker:Say(SPEECH.ARON.ACTION.TRANSFORMA)
        SetWereAron(inst)
    end
    inst.transformed = not inst.transformed
end

------------------------------------------
-- Manter alvo
------------------------------------------
local function WerearonKeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
           and not target:HasTag("summonedbyplayer")
           and not target:HasTag("player")
           and not target:HasTag("jaobuilder")
           and not (target.sg ~= nil and target.sg:HasStateTag("transform"))
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
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 5)
    for k,v in pairs(ents) do
        if v:HasTag("wall") or v:HasTag("structure") or v:HasTag("player") then
            inst.components.combat:SetAreaDamage(0, TUNING.DEERCLOPS_AOE_SCALE)
            inst.area = false
        else
            inst.components.combat:SetAreaDamage(4, TUNING.DEERCLOPS_AOE_SCALE)
            inst.area = true
        end  
    end        
end

------------------------------------------
-- Criacao de Padrao Para As Duas Formas
------------------------------------------
local function common()
    local inst = CreateEntity()
    ------------------------------------------
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLightWatcher()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    ------------------------------------------
    MakeCharacterPhysics(inst, 50, .5)
    ------------------------------------------
    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()
    ------------------------------------------    
    inst.AnimState:SetBank("rabbit")
    inst.AnimState:Hide("hat")
    ------------------------------------------
    inst:AddTag("character")
    inst:AddTag("summonaron")
    inst:AddTag("scarytoprey")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("trader")
    inst:AddComponent("talker")
    ------------------------------------------
    inst.entity:SetPristine()
    ------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    ------------------------------------------
    --inst:AddComponent("talker")
    inst.components.talker.ontalk = ontalk
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    ------------------------------------------
    inst:AddComponent("locomotor") 
    inst.components.locomotor.runspeed = 8 
    inst.components.locomotor.walkspeed = 5 
    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetCanEatRaw()
    inst.components.eater.strongstomach = true 
    inst.components.eater:SetOnEatFn(OnEat)
    ------------------------------------------
    inst:AddComponent("scaler")
    ------------------------------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(350)
    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(45)
    inst.components.combat:SetAttackPeriod(1)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    inst.components.combat:SetKeepTargetFunction(WerearonKeepTargetFn)
    ------------------------------------------
    local self = inst.components.combat
    local old = self.GetAttacked
    ------------------------------------------
    function self:GetAttacked(attacker, damage, weapon, stimuli)
        if attacker and ((attacker:HasTag("player") and not attacker:HasTag("jaobuilder")) or  attacker:HasTag("summonedbyplayer")) then
            return true
        end
        return old(self, attacker, damage, weapon, stimuli)
    end
    ------------------------------------------
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.sleeptestfn = DefaultSleepTest
    inst.components.sleeper.wakeuptestfn = DefaultWakeTest
    ------------------------------------------
    inst:AddComponent("werebeast")
    inst.components.werebeast:SetOnWereFn(SetWereAron)
    inst.components.werebeast:SetTriggerLimit(4)
    ------------------------------------------
    inst:AddComponent("followersitcommand")
    ------------------------------------------
    inst:AddComponent("follower")
    ------------------------------------------
    inst:AddComponent("inventory")
    ------------------------------------------
    inst:AddComponent("lootdropper")
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
    inst.components.trader.deleteitemonaccept = false
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader:Enable()
    ------------------------------------------
    inst:AddComponent("inspectable")
    ------------------------------------------
    inst:AddComponent("perishable")
    inst.components.perishable.onperishreplacement = "sourceofmagic"
    ------------------------------------------
    MakeMediumFreezableCharacter(inst, "pig_torso")
    MakeMediumBurnableCharacter(inst, "pig_torso")
    ------------------------------------------
    --- Setar icone no mapa
    ------------------------------------------
    inst.MiniMapEntity:SetIcon("aron.tex")
    inst.MiniMapEntity:SetPriority(4)    
    ------------------------------------------
    inst.setWP = SetWereAron
    inst.setNP = SetNormalAron
    inst.transformed = false
    inst.morph = change_form
    inst.hunterMode = false
    inst.area = true
    ------------------------------------------
    inst.OnBuilt = linkToBuilder
    ------------------------------------------
    inst:ListenForEvent("onhitother", OnHitOther)
    inst:ListenForEvent("attacked", OnAttacked)  
    --inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("death", function ( inst )
        inst.components.follower.leader.aronInvocado = false
    end)
    ------------------------------------------
    return inst
end

------------------------------------------
-- Funcao para criacao inicial
------------------------------------------
local function normal()
    local inst = common()
    ------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    ------------------------------------------
    SetNormalAron(inst)
    ------------------------------------------
    return inst
end

return Prefab("summon/summonaron", normal, assets, prefabs)