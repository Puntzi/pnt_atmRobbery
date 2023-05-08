local QBCore = exports['qb-core']:GetCoreObject()
local moneyDrop = {}

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

function selectOption(entity)
    if not (CurrentCops >= Config.MinPolice)
        QBCore.Functions.Notify(Config.Locales["not_enough_police"], 'error', 5000)
        return
    then 

    lib.registerContext({
        id = 'select_option',
        title = Config.Locales["select_option_rob_atm"]
        options = {
            {
                title = Config.Locales['type_hack'],
                icon = 'fa-laptop-code',
                onSelect = function()
                    robMethod('hack', entity)
                end,
            },

            {
                title = Config.Locales['type_break'],
                icon = "fa-hammer"
                onSelect = function()
                    robMethod('break', entity)
                end,
            }
        }
    })
end

function addTargetToEntity(entity)
    exports['qb-target']:AddTargetEntity(entity, {
        options = {
            {
                num = 1,
                icon = 'fas fa-example',
                label = 'Coger fajo',
                action = function()
                    startPickUpAnim(entity)
                end,
            }
        }
    })
end

function startPickUpAnim(entity)
    local dict = lib.requestAnimDict('random@domestic')
    local ped = cache.ped 

    TaskPlayAnim(ped , dict, 'pickup_low', 8.0, 8.0, -1, 0, 0, false, false, false)
    exports['qb-target']:RemoveTargetEntity(entity, 'Coger fajo')
    DeleteObject(entity)
    TriggerServerEvent('pnt_atmRobbery:giveMoney', Config.bills[math.random(1, #Config.bills)])
end

function startBreaking(entity)
    SetEntityHealth(entity, 1000)
    local atmCoords = GetEntityCoords(entity)
    local doneDrop = false
    local count = 0
    CreateThread(function()
        while true do
            local atmHealth = GetEntityHealth(entity)
            local pedCoords = GetEntityCoords(cache.ped)
            local distance = #(atmCoords - pedCoords)
            local weaponEquiped = GetSelectedPedWeapon('weapon_crowbar')
            QBCore.Functions.Notify(Config.Locales["start_breaking_atm"], 'success', 5000)

            if distance > 20 then
                for i = 1, #moneyDrop do
                    DeleteObject(moneyDrop[i])
                end
                SetEntityInvicible(entity, false)
                return
            end

            if not weaponEquiped then 
                SetEntityInvicible(entity, true)
            end

            if atmHealth == 0 and not doneDrop then 
                local atmCoords = GetOffsetFromEntityInWorldCoords(entity, 0.0, -0.2, 1.0)
                local dineroObject = CreateObject(joaat('prop_anim_cash_pile_01'), atmCoords.xyz, true, true ,true)
                local fVec = GetEntityForwardVector(entity)
                SetEntityVelocity(dineroObject, fVec * -1)

                if not DoesEntityExist(dineroObject) then return end

                addTargetToEntity(dineroObject)
                moneyDrop[#moneyDrop + 1] = dineroObject

                count = count + 1
                if count == 10 then doneDrop = true end
                SetEntityInvicible(entity, false)
            end

            print("^2DEBUG PRINT^7: ATM HEALTH " + atmHealth)
            Wait(300)
        end
    end)
end

function startHacking(entity)
    local haveItem, alreadyRobbed = lib.callback.await('pnt_atmRobbery:checkItem', false, Config.itemToHack, entity)

    if not haveItem then 
        QBCore.Functions.Notify(Config.Locales["no_item_to_hack"], 'error', 5000)
        return
    end

    if alreadyRobbed then
        QBCore.Functions.Notify(Config.Locales['atm_already_robbed'], 'error', 5000)
        return 
    end

    -- PONER ALGUNA ANIMACIÓN ANTES DE HACKEAR

    -- PONER ALGUNA ANIMACIÓN ANTES DE HACKEAR

    exports['ps-ui']:Thermite(function(success)
        if not success then 
            QBCore.Functions.Notify(Config.Locales['hack_failed'], 'error', 5000)
            return
        end

        if lib.progressCircle({
            duration = Config.timeToRobHack * 1000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            anim = {
                dict = 'mp_player_intdrink', -- ANIMACIÓN AL YA HACKEAR Y AHORA ROBAR EL DINERO
                clip = 'loop_bottle'
            },
        }) then
            TriggerServerEvent('pnt_atmRobbery:atmRobbed')
            TriggerServerEvent('pnt_atmRobbery:giveMoney', Config.moneyHacking)
        else 
        end
    end, Config.ThermiteGame.time, Config.ThermiteGame.gridSize, Config.ThermiteGame.incorrectBlocks)
end



function robMethod(method, entity)
    if method == 'hack' then
        startHacking(entity)
    elseif method == 'break' then 
        startBreaking(entity)
    end
end

CreateThread(function()
    exports['qb-target']:AddTargetModel(Config.atmModels, {
        options = {
            {
                icon = "fas fa-credit-card",
                label = "Robar ATM",
                action = function(entity)
                    selectOption(entity)
                end,
                canInteract = function()
                    local Player = QBCore.Functions.GetPlayerData()
                    if Player.job.name == 'police' then return false end 
                    return true
                end
            },
        },
        distance = 1.5,
    })
end)

