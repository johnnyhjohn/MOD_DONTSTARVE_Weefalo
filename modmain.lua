------------------------------------------
-- Esta funcao de biblioteca nos permite usar um arquivo em um local especificado. 
-- Permite usar para chamar variaveis globais de ambiente sem inicializa-los em nossos arquivos.
------------------------------------------
modimport("libs/env.lua")
modimport("libs/engine.lua")

------------------------------------------
-- Scripts a carregar
------------------------------------------
Load "chatinputscreen"
Load "consolescreen"
Load "textedit"

------------------------------------------
-- Acao de inicializacao.
------------------------------------------
use "data/actions/init"

------------------------------------------
-- Componente de inicializacao.
------------------------------------------
use "data/components/init"

------------------------------------------
-- Scripts necessarios
------------------------------------------
PrefabFiles = 
{
    "jao", 
    "jaostaff",        
    "sourceofmagic",
    "summons/summonjill",
    'summonhorn'
}

------------------------------------------
-- Arquivos de importacao de imagens e animacao
------------------------------------------
Assets = 
{
    Asset( "IMAGE", "images/saveslot_portraits/jao.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/jao.xml" ),
    ------------------------------------------
    Asset( "IMAGE", "images/selectscreen_portraits/jao.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/jao.xml" ),
    ------------------------------------------
    Asset( "IMAGE", "images/selectscreen_portraits/jao_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/jao_silho.xml" ),
    ------------------------------------------
    Asset( "IMAGE", "bigportraits/jao.tex" ),
    Asset( "ATLAS", "bigportraits/jao.xml" ),
    ------------------------------------------
    Asset( "IMAGE", "images/map_icons/jao.tex" ),
    Asset( "ATLAS", "images/map_icons/jao.xml" ),
    ------------------------------------------
    Asset( "IMAGE", "images/avatars/avatar_jao.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_jao.xml" ),
    ------------------------------------------
    Asset( "IMAGE", "images/avatars/avatar_ghost_jao.tex" ),
    Asset( "ATLAS", "images/avatars/avatar_ghost_jao.xml" ),
    ------------------------------------------
    Asset("ATLAS", "images/hud/magictab.xml"),
    Asset("IMAGE", "images/hud/magictab.tex"),
    ------------------------------------------
    Asset( "IMAGE", "images/inventoryimages/summons/summonjill.tex" ),
    Asset( "ATLAS", "images/inventoryimages/summons/summonjill.xml" ),
    ------------------------------------------
}

------------------------------------------
-- Variaveis globais
------------------------------------------
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
------------------------------------------
local SITCOMMAND = GLOBAL.Action(4, true, true, 10,	false, false, nil)
local SITCOMMAND_CANCEL = GLOBAL.Action(4, true, true, 10, false, false, nil)
------------------------------------------
local MARCAR = GLOBAL.Action(4, true, true, 10,	false, false, nil)
local HUNT = GLOBAL.Action(4, true, true, 10,	false, false, nil)
------------------------------------------
local petSpeech = require "speech_pets"
local SPEECHBR = petSpeech.SPEECH_PETS.PORTUGUES
local SPEECHEN = petSpeech.SPEECH_PETS.ENGLISH

------------------------------------------
-- Variaveis Recebidas do ModInfo
------------------------------------------
GLOBAL.TUNING.JAO = {}
GLOBAL.TUNING.JAO.LANG  = GetModConfigData("lang")
GLOBAL.TUNING.JAO.KEYF1 = 282
GLOBAL.TUNING.JAO.KEYF2 = 283
GLOBAL.TUNING.JAO.KEYF3 = 284
GLOBAL.TUNING.JAO.KEYF4 = 285
GLOBAL.TUNING.JAO.KEYF5 = 286
GLOBAL.TUNING.JAO.KEYZ  = 122
GLOBAL.TUNING.JAO.KEYX  = 120
GLOBAL.TUNING.JAO.KEYC  = 99
GLOBAL.TUNING.JAO.KEYV  = 118
GLOBAL.TUNING.JAO.KEYB  = 98
 
 GLOBAL.TUNING.JAO.GROUNDTEST1 = GLOBAL.GROUND.IMPASSABLE
 GLOBAL.TUNING.JAO.GROUNDTEST2 = GLOBAL.GROUND.INVALID;
 

------------------------------------------
-- Definir Linguagem Padrao
------------------------------------------
local SPEECH = SPEECHBR
GLOBAL.TUNING.JAO.SPEECH  = SPEECH


------------------------------------------
-- Respostas Jill
------------------------------------------
local function sayJillInfo( inst )
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 25, {"summonjill"})
    for k,jill in pairs(ents) do
        if jill ~= nil and jill ~= 0 then
            local health = jill.components.health:GetPercent()
            if health == 1 then
                jill.components.talker:Say(SPEECH.JILL.STATUS.FULL)
            elseif health > 0.5  then
                jill.components.talker:Say(SPEECH.JILL.STATUS.HALF)    
            else
                aron.components.talker:Say(SPEECH.JILL.STATUS.EMPTY)       
            end
            print("JILL VIDA".. health)
        end
    end              
end

------------------------------------------
-- Esperando pelo clique de F4
------------------------------------------
AddModRPCHandler("jao", "infoJill", sayJillInfo )

------------------------------------------
-- RECEITAS ------------------------------
------------------------------------------

------------------------------------------
-- Codigo da aba de receitas
------------------------------------------
local recipe_tab = AddRecipeTab("Invocations and Spells", 999, "images/hud/magictab.xml", "magictab.tex", "jaobuilder" )
------------------------------------------
-- Receitas do Café
------------------------------------------
local recipe_coffee = AddRecipe("seeds", {Ingredient("seeds", 2), Ingredient("poop", 1)}, recipe_tab, TECH.NONE)						
recipe_coffee.builder_tag = "jaobuilder"
------------------------------------------
-- Receita para invoca o Jill
------------------------------------------
local summonjill_recipe = AddRecipe("summonjill", {GLOBAL.Ingredient("summonstonejill", 1, "images/inventoryimages/runes/summonstonejill.xml")}, recipe_tab, TECH.NONE, nil, nil, nil, nil, nil,
"images/inventoryimages/summons/summonjill.xml", "summonjill.tex")
summonjill_recipe.tagneeded = false
summonjill_recipe.builder_tag ="jaobuilder"
summonjill_recipe.atlas = resolvefilepath("images/inventoryimages/summons/summonjill.xml")

------------------------------------------
-- Dados do persongem
------------------------------------------
STRINGS.CHARACTER_TITLES.jao = "The Beefalo's King"
STRINGS.CHARACTER_NAMES.jao = "Weefalo"
STRINGS.CHARACTER_DESCRIPTIONS.jao = "*A King\n*Has Mount\n*Beefalo's King"
STRINGS.CHARACTER_QUOTES.jao = "\"I think I need a Coffee!\""

------------------------------------------
-- Dados do cajado
------------------------------------------
GLOBAL.STRINGS.NAMES.JAOSTAFF = "Jao's Staff"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.JAOSTAFF = "Teleportation source, light and fire Jão"

------------------------------------------
-- Dados do cajado
------------------------------------------
GLOBAL.STRINGS.NAMES.SUMMONHORN = "Summon Horn"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SUMMONHORN = "On Play that horn, Weefalo can Summon others Beefalo's"

------------------------------------------
-- Dados do item
------------------------------------------
GLOBAL.STRINGS.NAMES.SOURCEOFMAGIC = "The Source of Magic"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SOURCEOFMAGIC = "Grants power of invocation of John!"

-- Dados do item
------------------------------------------
GLOBAL.STRINGS.NAMES.SOURCEOFMAGIC = "The Source of Magic"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SOURCEOFMAGIC = "Grants power of invocation of Jao!"
-- Dados do Jill
------------------------------------------
GLOBAL.STRINGS.NAMES.SUMMONJILL = "Jill"
GLOBAL.STRINGS.RECIPE_DESC.SUMMONJILL = "High speed riding."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SUMMONJILL = "Their hair is beautifull today, Jill..."
------------------------------------------
-- Icones do mapa de cada objeto/summon/jao
------------------------------------------
AddMinimapAtlas("images/map_icons/jao.xml")
------------------------------------------
AddMinimapAtlas("images/map_icons/summons/jill.xml")
------------------------------------------
AddMinimapAtlas("images/map_icons/sourceofmagic_atlas.xml")
------------------------------------------
-- Funcoes de comando dos pets
------------------------------------------
AddReplicableComponent("followersitcommand")

------------------------------------------
-- Esperar
------------------------------------------
SITCOMMAND.id = "SITCOMMAND"
SITCOMMAND.str = "Wait"
SITCOMMAND.fn = function(act)
    local targ = act.target
    if targ and targ.components.followersitcommand and act.doer:HasTag("jaobuilder") then
        act.doer.components.locomotor:Stop()
        if targ:HasTag("summonjill") then
            act.doer.components.talker:Say(SPEECH.JAO.WAIT.JILL)       
        end
        targ.components.followersitcommand:SetStaying(true)
        targ.components.followersitcommand:RememberSitPos("currentstaylocation", GLOBAL.Point(targ.Transform:GetWorldPosition())) 
        return true
    end
end
AddAction(SITCOMMAND)

------------------------------------------
-- Chamar
------------------------------------------
SITCOMMAND_CANCEL.id = "SITCOMMAND_CANCEL"
SITCOMMAND_CANCEL.str = "Call"
SITCOMMAND_CANCEL.fn = function(act)
    local targ = act.target
    if targ and targ.components.followersitcommand and act.doer:HasTag("jaobuilder") then
        act.doer.components.locomotor:Stop()
        if targ:HasTag("summonjill") then
            act.doer.components.talker:Say(SPEECH.JAO.CALL.JILL)      
        end
        targ.components.followersitcommand:SetStaying(false)
        return true
    end    
end
AddAction(SITCOMMAND_CANCEL)

------------------------------------------
-- Comando de Esperar/Seguir
------------------------------------------
AddComponentAction("SCENE", "followersitcommand", function(inst, doer, actions, rightclick)      
    if rightclick and inst.replica.followersitcommand then  
        if not inst.replica.followersitcommand:IsCurrentlyStaying() and doer:HasTag("jaobuilder") then
            table.insert(actions, GLOBAL.ACTIONS.SITCOMMAND)
        elseif inst.replica.followersitcommand:IsCurrentlyStaying() and doer:HasTag("jaobuilder") then
            table.insert(actions, GLOBAL.ACTIONS.SITCOMMAND_CANCEL)
        end
    end
end)

------------------------------------------
-- Arquivo de falas do personagem
------------------------------------------
STRINGS.CHARACTERS.JAO = require "speech_jao"

------------------------------------------
-- Nome no jogo
------------------------------------------
STRINGS.NAMES.JAO = "Weefalo"

------------------------------------------
-- Falas genericas
------------------------------------------
STRINGS.CHARACTERS.GENERIC.DESCRIBE.JAO = 
{
    GENERIC = "It's Weefalo!",
    ATTACKER = "This King seems wise....",
    MURDERER = "Murderer!",
    REVIVER = "Weefalo, friend of lost souls.",
    GHOST = "Weefalo could use a heart.",
}

------------------------------------------
-- Genero do personagem (male, female, or robot)
------------------------------------------
table.insert(GLOBAL.CHARACTER_GENDERS.MALE, "jao")

------------------------------------------
-- Inicio
------------------------------------------
AddModCharacter("jao")