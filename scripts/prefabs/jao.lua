------------------------------------------
-- import
------------------------------------------
local MakePlayerCharacter = require "prefabs/player_common"

------------------------------------------
-- Imagens e animacoes
------------------------------------------
local assets = {
    Asset( "ANIM", "anim/jao.zip"),
    Asset( "ANIM", "anim/ghost_jao_build.zip" ),
}

------------------------------------------
-- Scripts
------------------------------------------
local prefabs = {}

------------------------------------------
-- Itens iniciais de inventario
------------------------------------------
local start_inv = { 
    "summonhorn"
}

------------------------------------------
-- Recuperar Linguagem Definida 
------------------------------------------
local SPEECH = TUNING.JAO.SPEECH

------------------------------------------
-- Perca de sanidade proximo de fogo
------------------------------------------
local function sanityfn(inst)
    local x,y,z = inst.Transform:GetWorldPosition() 
    local delta = 0
    local max_rad = 10
    local ents = TheSim:FindEntities(x,y,z, max_rad, {"fire"})
    for k,v in pairs(ents) do 
        if v.components.burnable and v.components.burnable.burning then
            local sz = -TUNING.SANITYAURA_TINY
            local rad = v.components.burnable:GetLargestLightRadius() or 5
            sz = sz * ( math.min(max_rad, rad) / max_rad )
            local distsq = inst:GetDistanceSqToInst(v)
            delta = delta + sz/math.max(1, distsq)
        end
    end
    return delta
end

------------------------------------------
-- Falas Com Jill para Comer
------------------------------------------
local function sayJillInfo( inst )
    local random = math.random(0,3)
    if inst.jillInvocado then
        if random == 1 then
            inst.components.talker:Say(SPEECH.JAO.FEED.JILL.UM)
        else
            inst.components.talker:Say(SPEECH.JAO.FEED.JILL.DOIS)    
        end
    else
        inst.components.talker:Say(SPEECH.JAO.FEED.JILL.FAIL)
    end    
end

local function OnDespawn(inst, data)
    for k,v in pairs(inst.components.leader.followers) do
        if k.prefab=="summonjill" then
            k:Remove()
        end
    end
end

local function updateDaysLeft(inst)
    if inst.daysLeft == 0 then
        inst.daysLeft = 0
    else
        inst.daysLeft = inst.daysLeft - 1
    end

    return inst.daysLeft
end

------------------------------------------
-- Inicializacao no cliente e no host
------------------------------------------
local common_postinit = function(inst) 
    ------------------------------------------
    -- Icone do minimapa
    ------------------------------------------
    inst.MiniMapEntity:SetIcon( "jao.tex" )
    ------------------------------------------
    -- Tags
    ------------------------------------------
    inst:AddTag("bookbuilder")
    inst:AddTag("jaobuilder")
    inst:AddTag("insomniac")
    ------------------------------------------
    -- Adicionar Acao para a Tecla F1
    ------------------------------------------
    inst:AddComponent("keyhandler")
    ------------------------------------------
    inst.components.keyhandler:AddActionListener("jao", TUNING.JAO.KEYF4, "infoJill")
    inst.components.keyhandler:AddActionListener("jao", TUNING.JAO.KEYF4, "infoJill2")
    AddModRPCHandler("jao", "infoJill2", sayJillInfo )
    ------------------------------------------
end

local function onpreload(inst, data)
    if data then
        if data.daysLeft then
            inst.daysLeft = data.daysLeft
        end
    end

end
local function onsave(inst, data)
    data.daysLeft = inst.daysLeft
end
------------------------------------------
-- Principal
------------------------------------------
local master_postinit = function(inst)
    ------------------------------------------
    -- Dias para executar o summonhorn
    ------------------------------------------
    inst.daysLeft = 3
    ------------------------------------------
    -- Sons que o persongem ira fazer
    ------------------------------------------
    inst.soundsname = "woodie"  
    ------------------------------------------
    -- Permitir que leia livros
    ------------------------------------------
    inst:AddComponent("reader") 
    ------------------------------------------
    inst:AddComponent("leader")
    ------------------------------------------
    inst:AddComponent("knownlocations")
    ------------------------------------------
    -- Estatisticas
    ------------------------------------------
    ------------------------------------------
    -- Vida
    ------------------------------------------
    inst.components.health.fire_damage_scale = 1
    inst.components.health:SetMaxHealth(150)
    inst.components.health:StartRegen(1, 10)
    ------------------------------------------
    -- Fome
    ------------------------------------------
    inst.components.hunger:SetMax(150)
    inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE)
    ------------------------------------------
    -- Sanidade
    ------------------------------------------
    inst.components.sanity:SetMax(200)
    inst.components.sanity.custom_rate_fn = sanityfn
    ------------------------------------------
    -- Dano realizado
    ------------------------------------------
    inst.components.combat.damagemultiplier = 1.3
     ------------------------------------------
    local self = inst.components.combat
    local old = self.GetAttacked
    ------------------------------------------
    function self:GetAttacked(attacker, damage, weapon, stimuli)
        if attacker and attacker:HasTag("summonedbyplayer") then
            return true
        end
        return old(self, attacker, damage, weapon, stimuli)
    end
    ------------------------------------------
    -- Conhecimento de magia
    ------------------------------------------
    inst.components.builder.magic_bonus = 2
    ------------------------------------------
    -- Taxas de temperatura
    ------------------------------------------
    -- inst.components.temperature.mintemp = 20
    -- inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_LARGE
    -- inst.components.temperature.inherentinsulation = TUNING.INSULATION_LARGE 
    ------------------------------------------
    inst.jillInvocado  = true
    ------------------------------------------
    inst.objective = nil
    ------------------------------------------
    inst.prey = nil
    ------------------------------------------
    inst.OnDespawn = OnDespawn
    ------------------------------------------
    -- Penalidade de ressucitar
    ------------------------------------------
    inst.components.health.SetPenalty = function(self, penalty)
        self.penalty = math.clamp(penalty, 0, 0)
    end
    ------------------------------------------
    local x, y, z =  inst.Transform:GetWorldPosition()
    ------------------------------------------  
    inst:DoTaskInTime(0, function(inst) 
        SpawnPrefab("summonjill").Transform:SetPosition( Point(inst.Transform:GetWorldPosition()):Get() )
    end)
    ------------------------------------------   
    inst:ListenForEvent("death", function ( inst )
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, 25, {"summonjill"})
        for k,jill in pairs(ents) do
             jill:Remove()
        end
    end)    
    ------------------------------------------
    inst:ListenForEvent("ms_respawnedfromghost", function ( inst )
        SpawnPrefab("summonjill").Transform:SetPosition( Point(inst.Transform:GetWorldPosition()):Get() )
    end)
    ------------------------------------------
    -- Desinvocar pets
    ------------------------------------------
    inst:ListenForEvent("onattackother", function(inst, data)
        local damage_mult = 1
        if (data.target:HasTag("summonedbyplayer") or 
            data.target.prefab == "summons/summonjill") then
            inst.components.talker:Say("Go rest for a while...!")
            damage_mult = 0 
        else
            damage_mult = 1.3
        end
        inst.components.combat.damagemultiplier = damage_mult
    end)
    ------------------------------------------
    -- Função executada a cada começo de dia
    ------------------------------------------    
    inst:WatchWorldState( "startday", function() 
        updateDaysLeft(inst) 
    end )
end

return MakePlayerCharacter("jao", prefabs, assets, common_postinit, master_postinit, start_inv)