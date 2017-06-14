-----------------------------------------------------------------------------------
-- This file has been developed exclusively for the mod "Jão the Great Summoner" --
--(http://steamcommunity.com/sharedfiles/filedetails/?id=572470943). 			 --
-- Any unauthorized use will be reported to the DMCA. 							 --
-- To use any file or sprite ask my permission.									 --
--																				 --
-- Author: Paulo Victor de Oliveira Leal										 --
-- Contact: ciclopiano@gmail.com												 --
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

------------------------------------------
-- Animacoes e imagens necessarias
------------------------------------------
local assets =
{
    Asset("ANIM",  "anim/summonstonerhino.zip"),
    ------------------------------------------
    Asset("ATLAS", "images/map_icons/runes/summonstonerhino_map.xml"),
    Asset("IMAGE", "images/map_icons/runes/summonstonerhino_map.tex"),
    ------------------------------------------
    Asset("ATLAS", "images/inventoryimages/runes/summonstonerhino.xml"),
    Asset("IMAGE", "images/inventoryimages/runes/summonstonerhino.tex"),
}

------------------------------------------
-- Scripts necessarios
------------------------------------------
local prefabs = {}

------------------------------------------
-- Principal
------------------------------------------
local function fn(Sim)
    ------------------------------------------
    -- Instanciar a Runa
    ------------------------------------------
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    ------------------------------------------
    MakeInventoryPhysics(inst)
    ------------------------------------------
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    ------------------------------------------
    inst:AddTag("summonstonerhino")
    inst:AddTag("Summonstone")
    ------------------------------------------
    inst.MiniMapEntity:SetIcon("summonstonerhino_map.tex")
    inst.MiniMapEntity:SetPriority(5)
    ------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    ------------------------------------------
    inst.entity:SetPristine() 
    ------------------------------------------
    -- Ligar animacoes da Runa
    ------------------------------------------
    inst.AnimState:SetBank("grail")
    inst.AnimState:SetBuild("summonstonerhino")
    inst.AnimState:PlayAnimation("idle", false)
    ------------------------------------------
    MakeHauntableLaunch(inst)
    ------------------------------------------
    inst:AddComponent("inspectable")
    ------------------------------------------
    if not inst.components.characterspecific then
        inst:AddComponent("characterspecific")
    end
    ------------------------------------------
    inst.components.characterspecific:SetOwner("jao")
    inst.components.characterspecific:SetStorable(true) 
    inst.components.characterspecific:SetComment("I need my power!...") 
    ------------------------------------------
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.imagename = "summonstonerhino"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/runes/summonstonerhino.xml"
    ------------------------------------------
    return inst
end 

return Prefab( "common/inventory/summonstonerhino", fn, assets) 