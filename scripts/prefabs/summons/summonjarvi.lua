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
local brain = require "brains/summonjarvibrain"

------------------------------------------
-- Imagens e animacoes a importar
------------------------------------------
local assets = {
    ------------------------------------------
    --Asset("ANIM", "anim/shadow_skittish.zip"),
    Asset("ANIM", "anim/shadow_insanity2_basic.zip"),
    ------------------------------------------
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
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 25, {"summonedbyplayer"})
    local n = 0
    for k,aron in pairs(ents) do
        n = k
    end
    if n == 1 or n == 0 then
        return TUNING.SANITYAURA_HUGE
    elseif n == 2 then
        return TUNING.SANITYAURA_LARGE
    elseif n == 3 then
        return TUNING.SANITYAURA_MED
    elseif n == 4 then
        return TUNING.SANITYAURA_SMALL
    elseif n > 5 then
        return TUNING.SANITYAURA_TINY
    else
        return 1                    
    end    
    
end

------------------------------------------
-- Localizar alvo
------------------------------------------
local function NormalRetargetFn(inst)
    return FindEntity(inst, TUNING.PIG_TARGET_DIST, function(guy)
        return guy:HasTag("monster") or guy:HasTag("shadowcreature") and guy.components.health and not guy.components.health:IsDead()
        and inst.components.combat:CanTarget(guy)
    end, nil, { "character" }, nil)
end

------------------------------------------
-- Ligar ao mestre
------------------------------------------
local function linkToBuilder(inst, builder)
    builder.components.leader:AddFollower(inst, true)
    ------------------------------------------
    builder.jarviInvocado = true
    ------------------------------------------
    --builder.components.sanity:DoDelta(-30)
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
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, 30, function(dude)
        return dude:HasTag("summonedbyplayer") and dude.components.follower.leader == inst.components.follower.leader
    end, 5)
end

------------------------------------------
-- Intrucao para atacar outro
------------------------------------------
local function OnAttackOther(inst, data)
    local target = data.target
    inst.components.combat:ShareTarget(target, 30, function(dude)
        return dude:HasTag("summonedbyplayer") and dude.components.follower.leader == inst.components.follower.leader
    end, 5)
end

local function getPetStatus(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local pets = TheSim:FindEntities(x,y,z, 25, {"summonedbyplayer"})
    for k,v in pairs(pets) do
        local vida = v.components.health:GetPercent()
        if v:HasTag("summonskip") then
            if vida < .3 then
                inst.components.talker:Say(SPEECH.JARVI.SKIP)
            end
        elseif v:HasTag("summonrhino") then
            if vida < .3 then
                inst.components.talker:Say(SPEECH.JARVI.RHINO)
            end
        elseif v:HasTag("summonchop") then
            if vida < .3 then
                inst.components.talker:Say(SPEECH.JARVI.CHOP)
            end
        elseif v:HasTag("summonjill") then
            if vida < .3 then
                inst.components.talker:Say(SPEECH.JARVI.JILL)
            end
        elseif v:HasTag("summonaron") then
            if vida < .3 then
                inst.components.talker:Say(SPEECH.JARVI.ARON)
            end        
        end
    end
end

local function getMasterStatus( inst )
    local mestre = inst.components.follower.leader
    if mestre ~= nil then
        if mestre.components.health:GetPercent() < 0.5 then
            inst.components.talker:Say(SPEECH.JARVI.JAO.HEALTH)
        end
        
        if mestre.components.sanity:GetPercent() < 0.5 then
            inst.components.talker:Say(SPEECH.JARVI.JAO.SANITY)
        end
        
        if mestre.components.hunger:GetPercent() < 0.5 then
            inst.components.talker:Say(SPEECH.JARVI.JAO.HUNGER)
        end
    end
end

local function prepareEnemies( inst )
    local mestre = inst.components.follower.leader
    if mestre ~= nil then
        local numMons = 0
        local x,y,z = mestre.Transform:GetWorldPosition()
        local monsters = TheSim:FindEntities(x,y,z, 10)
        for n,v in pairs(monsters) do
            if v:HasTag("epic") then
                inst.components.talker:Say(SPEECH.JARVI.ENEMIES.GIANT)
                numMons = numMons + 1
            elseif v:HasTag("monster") or v:HasTag("hostile") or v:HasTag("spider") or v:HasTag("tentacle") then
                numMons = numMons + 1   
            end
        end
        if numMons < 4 and numMons > 0 then
            inst.components.talker:Say(SPEECH.JARVI.ENEMIES.SMALL)
        elseif numMons > 3 and numMons < 8 then
            inst.components.talker:Say(SPEECH.JARVI.ENEMIES.HUGE)
        end
    end
end

------------------------------------------
-- Principal
------------------------------------------
local function fn()

    local sounds =
    {
        attack = "dontstarve/sanity/creature2/attack",
        attack_grunt = "dontstarve/sanity/creature2/attack_grunt",
        death = "dontstarve/sanity/creature2/die",
        idle = "dontstarve/sanity/creature2/idle",
        taunt = "dontstarve/sanity/creature2/taunt",
        appear = "dontstarve/sanity/creature2/appear",
        disappear = "dontstarve/sanity/creature2/dissappear",
    }

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
    local sound = inst.entity:AddSoundEmitter()
    ------------------------------------------
    -- Gerar estrutura
    ------------------------------------------
    MakeCharacterPhysics(inst, 30, .3)
    ------------------------------------------
    -- Construcao da sombra e outros
    ------------------------------------------
    inst.DynamicShadow:SetSize(2, 1.5)
    inst.entity:SetPristine()
    inst.Transform:SetFourFaced()
    ------------------------------------------
    -- Ligar animacoes ao character
    ------------------------------------------
    inst.AnimState:SetBank("shadowcreature2")
    inst.AnimState:SetBuild("shadow_insanity2_basic")
    inst.AnimState:PlayAnimation("idle_loop", true)
    ------------------------------------------
    -- Tags de controle
    ------------------------------------------
    inst:AddTag("summonjarvi")
    inst:AddTag("sheltercarrier")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("scarytoprey")
    ------------------------------------------
    inst:AddComponent("talker")
    ------------------------------------------
    if not TheWorld.ismastersim then
        return inst
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
    inst.components.health:SetInvincible(true)
    ------------------------------------------
    inst:AddComponent("inspectable")
    ------------------------------------------
    inst:AddComponent("inventory")
    ------------------------------------------
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 40
    inst.components.locomotor.walkspeed = 40
    ------------------------------------------
    inst:AddComponent("scaler")
    inst.components.scaler:SetScale((TUNING.ROCKY_MIN_SCALE)/3)
    ------------------------------------------
    inst:AddComponent("lootdropper")
    ------------------------------------------
    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("nightmarefuel")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()
        inst.sounds = sounds
    --inst:AddComponent("combat")
    ------------------------------------------
    inst:DoPeriodicTask(3, function() 
        getPetStatus(inst) 
    end)
    ------------------------------------------
    inst:DoPeriodicTask(7, function() 
        getMasterStatus(inst) 
    end)
    ------------------------------------------
    inst:DoPeriodicTask(2, function() 
        prepareEnemies(inst) 
    end)
    ------------------------------------------    
    inst:SetBrain(brain)
    inst:SetStateGraph("SGshadowcreature")
    ------------------------------------------
    inst.OnLoad = linkToBuilder
    ------------------------------------------
    return inst
end

return Prefab("common/summons/summonjarvi", fn, assets, prefabs)