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
local brain = require "brains/summonminichopbrain"

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

------------------------------------------
-- Scripts necessarios
------------------------------------------
local prefabs = {
    "jao",
    "character_fire",
    "sourceofmagic"
}

------------------------------------------
-- Pegar Fogo
------------------------------------------
local function OnBurnt(inst)
    if inst.components.propagator and inst.components.health and not inst.components.health:IsDead() then
        inst.components.propagator.acceptsheat = true
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
    end
end 

------------------------------------------
-- Fazer pet recusar item do mestre
------------------------------------------
local function OnRefuseItem(inst, item)
    inst.components.talker:Say("I do not need this master...")
end

------------------------------------------
-- Localizar alvo
------------------------------------------
local function NormalRetargetFn(inst)
    return FindEntity(inst, TUNING.PIG_TARGET_DIST, function(guy)
        return (guy:HasTag("mole") or guy:HasTag("frog") or guy:HasTag("monster")) and not guy:HasTag("summonedbyplayer") and guy.components.health and not guy.components.health:IsDead() and (not guy:HasTag("summonedbyplayer")) and (not guy:HasTag("jaobuilder"))
        and inst.components.combat:CanTarget(guy)
    end, nil, { "character" }, nil)
end


------------------------------------------
-- Reacao ao ser atacado
------------------------------------------
local function OnAttacked(inst, data)
    local attacker = data.attacker
    if not attacker:HasTag("summonedbyplayer") and not attacker:HasTag("jaobuilder") and not attacker:HasTag("player") then
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, 30, function(dude)
            return dude:HasTag("summonedbyplayer") and dude.components.follower.leader == inst.components.follower.leader
        end, 5)
    end
end

------------------------------------------
-- Intrucao para atacar outro
------------------------------------------
local function OnAttackOther(inst, data)
    local target = data.target
    if not target:HasTag("summonedbyplayer") and not target:HasTag("jaobuilder") and not target:HasTag("player") then
        inst.components.combat:ShareTarget(target, 30, function(dude)
            return dude:HasTag("summonedbyplayer") and dude.components.follower.leader == inst.components.follower.leader
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
    inst.entity:SetPristine()
    inst.Transform:SetFourFaced()
    ------------------------------------------
    -- Ligar animacoes ao character
    ------------------------------------------
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
    inst:AddTag("summonminichop")
    inst:AddTag("tree")
    inst:AddTag("sheltercarrier")
    inst:AddTag("summonedbyplayer")
    inst:AddTag("scarytoprey")
    ------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    ------------------------------------------
    -- Lista de componentes:
    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(35)
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    ------------------------------------------
    local self = inst.components.combat
    local old = self.GetAttacked
    ------------------------------------------
    function self:GetAttacked(attacker, damage, weapon, stimuli)
        if attacker and (attacker:HasTag("player") or attacker:HasTag("summonedbyplayer")) then
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
    inst.components.health:SetMaxHealth(200)
    ------------------------------------------   
    inst:AddComponent("inspectable")
    ------------------------------------------
    inst:AddComponent("perishable")
    ------------------------------------------
    inst:AddComponent("inventory")
    ------------------------------------------
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 5
    ------------------------------------------
    inst:AddComponent("scaler")
    inst.components.scaler:SetScale((TUNING.ROCKY_MIN_SCALE)-0.1)
    ------------------------------------------
    inst:AddComponent("lootdropper")
    ------------------------------------------
    inst:AddComponent("talker")
    ------------------------------------------
    inst:AddComponent("knownlocations")    
    ------------------------------------------
    MakeMediumFreezableCharacter(inst, "pig_torso")
    ------------------------------------------
    MakeMediumBurnableCharacter(inst, "pig_torso")
    ------------------------------------------    
    inst:SetBrain(brain)
    inst:SetStateGraph("SGsummonminichop")    
    ------------------------------------------
    inst:ListenForEvent("attacked", OnAttacked)  
    --inst:ListenForEvent("onattackother", OnAttackOther)
    ------------------------------------------
    return inst
end

return Prefab("common/summons/summonminichop", fn, assets, prefabs)