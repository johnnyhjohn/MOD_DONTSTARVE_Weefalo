local assets =
{
    Asset("ANIM", "anim/horn.zip"),
}

local function FollowLeader(follower, leader)
    follower.sg:PushEvent("heardhorn", { musician = leader })
end

local function TryAddFollower(leader, follower)
    if leader.components.leader ~= nil and
        follower.components.follower ~= nil and
        follower:HasTag("beefalo") and not follower:HasTag("baby") and
        leader.components.leader:CountFollowers("beefalo") < TUNING.HORN_MAX_FOLLOWERS then
        leader.components.leader:AddFollower(follower)
        follower.components.follower:AddLoyaltyTime(TUNING.HORN_EFFECTIVE_TIME + math.random())
        if follower.components.combat ~= nil and follower.components.combat:TargetIs(leader) then
            follower.components.combat:SetTarget(nil)
        end
        follower:DoTaskInTime(math.random(), FollowLeader, leader)
    end
end

local function onUse( inst, musician, instrument )
    if(musician.daysLeft == 0) then
        local x, y, z = musician.Transform:GetWorldPosition()
        local beefaloAge = math.random(1,5)
        if musician.jillInvocado == true then
            if beefaloAge == 4 then
                local beefalo = SpawnPrefab("babybeefalo")
                beefalo.Transform:SetPosition(x, y, z)
                musician.daysLeft = 3
            else
                local beefalo = SpawnPrefab("beefalo")
                local beefaloType = math.random(1,4)

                local beefaloToGenerate = {
                    "DEFAULT",
                    "RIDER",
                    "ORNERY",
                    "PUDGY"
                }

                beefalo.components.domesticatable:DeltaTendency(tostring(beefaloToGenerate[beefaloType]), 1)
                beefalo:SetTendency()
                beefalo.components.domesticatable.domestication = 1
                beefalo.components.domesticatable:BecomeDomesticated()
                beefalo.Transform:SetPosition(x, y, z)
                musician.daysLeft = 3
            end
        else
            musician.components.leader:AddFollower(inst, true)
            ------------------------------------------
            musician.components.sanity:DoDelta(-25)
            ------------------------------------------
            musician.jillInvocado = true
            ------------------------------------------
            SpawnPrefab("summonjill").Transform:SetPosition( Point(inst.Transform:GetWorldPosition()):Get() )
            musician.daysLeft = 3
        end
    else
        musician.components.talker:Say("Tenho que esperar mais " .. (musician.daysLeft) .. " dias")
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("horn")
    inst:AddTag("summonhorn")

    inst.AnimState:SetBank("horn")
    inst.AnimState:SetBuild("horn")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    ------------------------------------------
    if not inst.components.characterspecific then
        inst:AddComponent("characterspecific")
    end
    ------------------------------------------
    inst.components.characterspecific:SetOwner("jao")

    inst:AddComponent("inspectable")
    inst:AddComponent("instrument")
    inst.components.instrument.range = TUNING.HORN_RANGE

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)
    inst.components.instrument:SetOnPlayedFn(onUse)
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath   = true
    inst.components.inventoryitem.imagename     = "horn"

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("summonhorn", fn, assets)
