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
local brain = require "brains/summonchopbrain"

------------------------------------------
-- Imagens e animacoes a importar
------------------------------------------
local assets = {
    ------------------------------------------
    Asset("ATLAS", "images/map_icons/summons/chop.xml"),
    Asset("ATLAS", "images/map_icons/summons/chop.xml"),
    ------------------------------------------
    Asset("ANIM", "anim/leif_walking.zip"),
    Asset("ANIM", "anim/leif_actions.zip"),
    Asset("ANIM", "anim/leif_attacks.zip"),
    Asset("ANIM", "anim/leif_idles.zip"),
    Asset("ANIM", "anim/leif_build.zip"),
    Asset("ANIM", "anim/leif_lumpy_build.zip"),
    ------------------------------------------
    Asset("SOUND", "sound/leif.fsb"),
}

local prefabs = {
    "jao",
    "groundpound_fx",
    "groundpoundring_fx",
    "character_fire",
    "sourceofmagic"
}

------------------------------------------
local SPEECH = TUNING.JAO.SPEECH

------------------------------------------
-- Pegar Fogo
------------------------------------------
local function OnBurnt(inst)
    if inst.components.propagator and inst.components.health and not inst.components.health:IsDead() then
        inst.components.propagator.acceptsheat = true
    end
end

------------------------------------------
-- Ataque em area
------------------------------------------
local function SetGroundPounderSettings(inst, mode)
    if mode == "normal" then 
        inst.components.groundpounder2.damageRings = 2
        inst.components.groundpounder2.destructionRings = 2
        inst.components.groundpounder2.numRings = 3
    end
end

------------------------------------------
-- Ao salvar
------------------------------------------
local function OnSave(inst, data)
    data.cangroundpound = inst.cangroundpound
end

------------------------------------------
-- Ao carregar
------------------------------------------
local function OnLoad(inst, data)
    if data ~= nil then
        inst.cangroundpound = data.cangroundpound
    end
end

------------------------------------------
-- Pronto para atacar em area
------------------------------------------
local function ontimerdone(inst, data)
    if data.name == "GroundPound" then
        inst.cangroundpound = true
    end
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
        inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/foley") 
    end
end 

------------------------------------------
-- Fazer pet recusar item do mestre
------------------------------------------
local function OnRefuseItem(inst, item)
    inst.sg:GoToState("panic")
    inst.components.talker:Say(SPEECH.CHOP.REFUSE)
end

------------------------------------------
-- Definir quanto de vida recuperar ao comer
------------------------------------------
local function OnEat( inst, food )
    local health = inst.components.health:GetPercent()
    local currentHealth = inst.components.health.currenthealth
    if health >= 1 then
        inst.components.talker:Say(SPEECH.CHOP.EAT.FULL)
    else
        inst.components.health:DoDelta(40)
        inst.components.talker:Say(SPEECH.CHOP.EAT.EMPTY)
        inst.sg:GoToState("spawn")    
    end
end

------------------------------------------
-- Localizar alvo
------------------------------------------
local function NormalRetargetFn(inst)
    return FindEntity(inst, TUNING.PIG_TARGET_DIST, function(guy)
        return guy:HasTag("monster") and not guy:HasTag("summonedbyplayer") and 
               guy.components.health and not guy.components.health:IsDead()
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
    builder.components.talker:Say(SPEECH.JAO.SUMMON.CHOP)
    ------------------------------------------
    builder.components.sanity:DoDelta(-40)
    ------------------------------------------
    if builder.components.combat.hurtsound ~= nil and builder.SoundEmitter ~= nil then
        builder.SoundEmitter:PlaySound(builder.components.combat.hurtsound)
    end
    ------------------------------------------
    builder.chopInvocado = true
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
    inst.components.talker:Say(SPEECH.CHOP.ATTACK)
    if not target:HasTag("summonedbyplayer") and not target:HasTag("jaobuilder") and not target:HasTag("player") then
        inst.components.combat:ShareTarget(target, 30, function(dude)
            return dude:HasTag("summonedbyplayer") and 
                dude.components.follower.leader == inst.components.follower.leader
            end, 5)  
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
    MakeCharacterPhysics(inst, 1000, .5)
    ------------------------------------------
    -- Construcao da sombra e outros
    ------------------------------------------
    inst.DynamicShadow:SetSize(4, 1.5)
    --inst.entity:SetPristine()
    inst.Transform:SetFourFaced()
    ------------------------------------------
    -- Ligar animacoes ao character
    inst.AnimState:SetBank("leif")
    inst.AnimState:SetBuild("leif_build")
    inst.AnimState:PlayAnimation("idle_loop")
    ------------------------------------------
    -- Setar icone no mapa
    ------------------------------------------
    inst.MiniMapEntity:SetIcon("chop.tex")
    inst.MiniMapEntity:SetPriority(4)
    ------------------------------------------
    -- Tags
    ------------------------------------------
    inst:AddTag("summonchop")
    inst:AddTag("tree")
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
    -- Lista de componentes:
    ------------------------------------------
    inst:AddComponent("tibbercracker")
    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(75)
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
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
    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("pinecone")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()
    ------------------------------------------
    inst:AddComponent("follower")
    ------------------------------------------
    inst:AddComponent("followersitcommand")
    ------------------------------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(600)
    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({FOODTYPE.VEGGIE, FOODTYPE.ROUGHAGE})
    inst.components.eater:SetOnEatFn(OnEat)
    ------------------------------------------
    inst:AddComponent("inspectable")
    ------------------------------------------
    inst:AddComponent("groundpounder2")
    inst.components.groundpounder2.destroyer = true
    SetGroundPounderSettings(inst, "normal")
    ------------------------------------------
    inst:AddComponent("timer")
    ------------------------------------------
    inst:AddComponent("inventory")
    ------------------------------------------
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3.5
    ------------------------------------------
    inst:AddComponent("scaler")
    inst.components.scaler:SetScale(TUNING.ROCKY_MAX_SCALE)
    ------------------------------------------
    inst:AddComponent("lootdropper")
    ------------------------------------------
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.deleteitemonaccept = false
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader:Enable()
    ------------------------------------------
    inst:AddComponent("perishable")    
    ------------------------------------------    
    MakeHugeFreezableCharacter(inst, "marker")
    ------------------------------------------
    MakeLargeBurnableCharacter(inst, "marker")
    ------------------------------------------
    -- Funcoes globais
    inst.cangroundpound = false
    ------------------------------------------
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    ------------------------------------------
    inst.protegendo = false
    ------------------------------------------
    inst:SetBrain(brain)
    inst:SetStateGraph("SGsummonchop")
    ------------------------------------------   
    inst.OnBuilt = linkToBuilder
    ------------------------------------------    
    inst:ListenForEvent("attacked", OnAttacked)  
    --inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("timerdone", ontimerdone)
    inst:ListenForEvent("death", function ( inst )
        inst.components.follower.leader.chopInvocado = false
        ------------------------------------------
        local x1,y1,z1 = inst.Transform:GetWorldPosition()
        local chopinhos = TheSim:FindEntities(x1,y1,z1, 40, {"summonminichop"})
        for n,minichop in pairs(chopinhos) do
            minichop.components.health:Kill()
        end
        ------------------------------------------
    end)
    ------------------------------------------    
    inst:WatchWorldState("isnight", function ( inst )
        local vagalumes1 = SpawnPrefab("fireflies")
        local x, y, z =  inst.Transform:GetWorldPosition()
        vagalumes1.Transform:SetPosition( (Point(x+10, y, z)):Get() )
        ------------------------------------------        
        local vagalumes2 = SpawnPrefab("fireflies")
        vagalumes2.Transform:SetPosition( (Point(x, y, z+10)):Get() )
        ------------------------------------------
        local vagalumes3 = SpawnPrefab("fireflies")
        vagalumes3.Transform:SetPosition( (Point(x-10, y, z)):Get() )
        ------------------------------------------
        local vagalumes4 = SpawnPrefab("fireflies")
        vagalumes4.Transform:SetPosition( (Point(x, y, z-10)):Get() )
        ------------------------------------------
        local vagalumes5 = SpawnPrefab("fireflies")
        vagalumes5.Transform:SetPosition( (Point(x, y, z)):Get() )
    end)
    
    return inst
end

return Prefab("common/summons/summonchop", fn, assets, prefabs)