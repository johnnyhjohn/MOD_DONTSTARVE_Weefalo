-----------------------------------------------------------------------------------
-- This file has been developed exclusively for the mod "Jão the Great Summoner" --
--(http://steamcommunity.com/sharedfiles/filedetails/?id=572470943).             --
-- Any unauthorized use will be reported to the DMCA.                            --
-- To use any file or sprite ask my permission.                                  --
--                                                                               --   
-- Author: Paulo Victor de Oliveira Leal                                         --
-- Contact: ciclopiano@gmail.com                                                 --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

------------------------------------------
-- Animacoes e imagens necessarias
------------------------------------------
local assets=
{
    Asset("ANIM", "anim/jaostaff.zip"),
    Asset("ANIM", "anim/swap_jaostaff.zip"),
    ------------------------------------------
    Asset("SOUND", "sound/common.fsb"),
    ------------------------------------------
    Asset("ATLAS", "images/inventoryimages/jaostaff.xml"),
    Asset("IMAGE", "images/inventoryimages/jaostaff.tex"),
}

------------------------------------------
-- Scripts necessarios
------------------------------------------
local prefabs = {"torchfire",}

------------------------------------------
-- Variaveis Globais
------------------------------------------
local teste = false
local SPAWN_DIST = 0

------------------------------------------
-- Gerar Aleatoriamente a Distancia de Spawn
------------------------------------------
local function gerar_sd( )
    local val = math.random(15,35)
    return val
end

------------------------------------------
-- Motar o Ponto de Spawn
------------------------------------------
local function GetSpawnPoint(pt)
    local theta = math.random() * 2 * PI
    SPAWN_DIST = gerar_sd( )
    local radius = SPAWN_DIST
    local offset = FindWalkableOffset(pt, theta, radius, 12, true)
    return offset ~= nil and (pt + offset) or nil
end

------------------------------------------
-- Spawnar as runas
------------------------------------------
local function SpawnItem(inst, pos)
    -- Pegar o local do cajado
    local pt = inst:GetPosition()
    -- Pegar o Ponto de Spawn
    local spawn_pt = GetSpawnPoint(pt)
    -- Array de Runas
    local summonstoneteste = {SpawnPrefab("runes/summonstone"), SpawnPrefab("runes/summonstonerhino"), SpawnPrefab("runes/summonstonechop"), SpawnPrefab("runes/summonstonejill"), SpawnPrefab("runes/summonstonearon")}
    local i = 0
    if spawn_pt ~= nil then
        local summonstone = summonstoneteste[pos]
        if summonstone ~= nil then
            summonstone.Physics:Teleport(spawn_pt:Get())
            summonstone:FacePoint(pt:Get())
            return summonstone
        end       
    end
end

------------------------------------------
-- Mesmo no Inventario Verificar se as Runas Estao Instanciadas
------------------------------------------ 
local function OnPutInInventory(inst)
    if inst.fixtask == nil then
        inst.fixtask = inst:DoTaskInTime(1, FixSummonStone)
    end
end

------------------------------------------
-- Variavel de Respawn
------------------------------------------
local StartRespawn

------------------------------------------
-- Desativar o Respawn
------------------------------------------
local function StopRespawn(inst)
    if inst.respawntask ~= nil then
        inst.respawntask:Cancel()
        inst.respawntask = nil
        inst.respawntime = nil
    end
end

------------------------------------------
-- Re-pegar as Runas
------------------------------------------
-- DEVE SER MELHORADO
    -- Fazer a summonstone encontrar no mundo as Runas
    -- Respawnar somente se não encontrar em lugar nenhum
local function RebindSummonStone(inst, summonstone)
    summonstone = summonstone
    if summonstone ~= nil then
        inst:ListenForEvent("death", function() StartRespawn(inst, TUNING.CHESTER_RESPAWN_TIME) end, summonstone)
        return true
    end
end 

------------------------------------------
-- Spawnar Devidamente
------------------------------------------
local function RespawnSummonStone(inst)
    StopRespawn(inst)
    --RebindSummonStone(inst, SpawnItem(inst, 1)) -- Skip -- Ja comeca no invetario do Jao
    RebindSummonStone(inst, SpawnItem(inst, 2)) -- Rhino
    RebindSummonStone(inst, SpawnItem(inst, 3)) -- Chop
    RebindSummonStone(inst, SpawnItem(inst, 4)) -- Jill
    RebindSummonStone(inst, SpawnItem(inst, 5)) -- Aron
end

------------------------------------------
-- Verifica O Tempo de Respawn
------------------------------------------
StartRespawn = function(inst, time)
    StopRespawn(inst)
    ------------------------------------------
    time = time or 0
    inst.respawntask = inst:DoTaskInTime(time, RespawnSummonStone)
    inst.respawntime = GetTime() + time
end

------------------------------------------
-- Ajustar O Spawn
------------------------------------------
local function FixSummonStone(inst)
    inst.fixtask = nil
    if not RebindSummonStone(inst) then
        if inst.components.inventoryitem.owner ~= nil then
            local time_remaining = 0
            local time = GetTime()
            if inst.respawntime and inst.respawntime > time then
                time_remaining = inst.respawntime - time    
            end
            StartRespawn(inst, time_remaining)
        end
    end
end

------------------------------------------
-- Salvar O Tempo De Spawn
------------------------------------------
local function OnSave(inst, data)
    if inst.respawntime ~= nil then
        local time = GetTime()
        if inst.respawntime > time then
            data.respawntimeremaining = inst.respawntime - time
        end
    end
end

------------------------------------------
-- Carregar o Ultimo Tempo de Spawn
------------------------------------------
local function OnLoad(inst, data)
    if data == nil then
        return
    end
    ------------------------------------------
    if data.respawntimeremaining ~= nil then
        inst.respawntime = data.respawntimeremaining + GetTime()
    end
end

------------------------------------------
-- Pegar Estado da Tarefa de Respawn
------------------------------------------
local function GetStatus(inst)
    if inst.respawntask ~= nil then
        return "WAITING"
    end
end

------------------------------------------
-- Consumir 1 de fome por ataque
------------------------------------------
local function onattack_jaostaff(inst, attacker, target)
    if attacker and attacker.components.sanity then
        attacker.components.sanity:DoDelta(-1)
    end
end

------------------------------------------
-- Funcao Principal
------------------------------------------
local function fn()
    ------------------------------------------
    -- Instanciar o cajado
    ------------------------------------------
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    ------------------------------------------
    -- Gerar estrutura
    ------------------------------------------
    MakeInventoryPhysics(inst)
    ------------------------------------------
    -- Ligar animacoes ao cajado
    ------------------------------------------
    inst.AnimState:SetBank("jaostaff")
    inst.AnimState:SetBuild("jaostaff")
    inst.AnimState:PlayAnimation("idle")
    ------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    ------------------------------------------
    -- Tags
    ------------------------------------------
    inst:AddTag("shadow")
    ------------------------------------------
    -- Fazer troca de animacoes do cajado ao equipar
    local function OnEquip(inst, owner)
        inst.components.burnable:Ignite()
        owner.AnimState:OverrideSymbol("swap_object", "swap_jaostaff", "swap_orbstaff")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
        inst.SoundEmitter:SetParameter("torch", "intensity", 1)
        ------------------------------------------
        if inst.fire == nil then
            inst.fire = SpawnPrefab("torchfire")
            local follower = inst.fire.entity:AddFollower()
            follower:FollowSymbol(owner.GUID, "swap_object", 0, -220, 1)
        end
    end
    ------------------------------------------
    -- Fazer troca de animacoes do cajado ao desequipar
    ------------------------------------------
    local function OnUnequip(inst, owner)
        inst.components.burnable:Extinguish()
        owner.AnimState:OverrideSymbol("swap_object", "swap_jaostaff", "swap_orbstaff")
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
        ------------------------------------------
        if inst.fire ~= nil then
            inst.fire:Remove()
            inst.fire = nil
        end
        ------------------------------------------
        inst.SoundEmitter:KillSound("torch")
        inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
        ------------------------------------------
        owner.components.combat.damage = owner.components.combat.defaultdamage 
    end
    ------------------------------------------
    -- Ao guardar
    ------------------------------------------
    local function onpocket(inst, owner)
        inst.components.burnable:Extinguish()
    end
    ------------------------------------------
    -- Pegar local do mouse para teleportar
    ------------------------------------------
    local function blinkstaff_reticuletargetfn()
        local player = ThePlayer
        local rotation = player.Transform:GetRotation() * DEGREES
        local pos = player:GetPosition()
        for r = 13, 1, -1 do
            local numtries = 2 * PI * r
            local pt = FindWalkableOffset(pos, rotation, r, numtries)
            if pt ~= nil then
                return pt + pos
            end
        end
    end
    ------------------------------------------
    -- Teleportar
    ------------------------------------------
    local function onblink(staff, pos, caster)
        if caster.components.sanity ~= nil then
            caster.components.sanity:DoDelta(-1)
        end
    end 
    ------------------------------------------
    inst.entity:SetPristine()
    ------------------------------------------
    -- Lista de componentes:
    ------------------------------------------
    inst:AddComponent("lighter")
    ------------------------------------------
    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil
    ------------------------------------------
    inst:AddComponent("blinkstaff")
    inst.components.blinkstaff.onblinkfn = onblink
    ------------------------------------------
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "jaostaff"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/jaostaff.xml"
    ------------------------------------------
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
    inst.components.inventoryitem.keepondeath = true
    ------------------------------------------
    inst:AddComponent("inspectable")
    ------------------------------------------
    inst:AddComponent("weapon")
    inst.components.weapon:SetOnAttack(onattack_jaostaff)
    inst.components.weapon:SetDamage(25)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetProjectile("fire_projectile")
    ------------------------------------------
    -- Ao Salvar e Carregar
    ------------------------------------------
    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    ------------------------------------------
    -- Tarefas Periodicas 
    ------------------------------------------
    inst.fixtask = inst:DoTaskInTime(1, FixSummonStone)
    ------------------------------------------
    return inst 
end

return  Prefab("common/inventory/jaostaff", fn, assets)