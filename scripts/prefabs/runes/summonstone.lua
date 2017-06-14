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
    Asset("ANIM",  "anim/summonstone.zip"),
    ------------------------------------------
    Asset("ATLAS", "images/map_icons/runes/summonstone_map.xml"),
    Asset("IMAGE", "images/map_icons/runes/summonstone_map.tex"),
    ------------------------------------------
    Asset("ATLAS", "images/inventoryimages/runes/summonstone.xml"),
    Asset("IMAGE", "images/inventoryimages/runes/summonstone.tex"),
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
    inst:AddTag("summonstone")
    inst:AddTag("summonstoneskip")
    ------------------------------------------
    inst.MiniMapEntity:SetIcon("summonstone_map.tex")
    inst.MiniMapEntity:SetPriority(5)
    ------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    ------------------------------------------
    inst.entity:SetPristine() 
    ------------------------------------------
    -- Ligar animacoes ao cajado
    inst.AnimState:SetBank("grail")
    inst.AnimState:SetBuild("summonstone")
    inst.AnimState:PlayAnimation("idle", false)
    ------------------------------------------
    MakeHauntableLaunch(inst)
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
    inst.components.inventoryitem.imagename = "summonstone"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/runes/summonstone.xml"
    ------------------------------------------
    return inst
end 

return Prefab( "common/inventory/summonstone", fn, assets) 