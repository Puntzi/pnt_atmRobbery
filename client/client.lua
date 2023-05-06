local QBCore = exports['qb-core']:GetCoreObject()
local moneyDrop = {}

function selectOption(entity)
    exports['qb-menu']:openMenu({
        {
            header = '¿Como quieres robar el ATM?',
            icon = 'fas fa-code',
            isMenuHeader = true,
        },
        {
            header = 'Hackearlo',
            icon = 'fas fa-code-merge',
            params = {
                event = 'pnt_atmRobbery:robMethod',
                args = {
		            type = 'hack',
                    entity = entity,
                }
            }
        },  
        {
            header = 'Romper el ATM',
            icon = 'fas fa-code-pull-request',
            params = {
                event = 'pnt_atmRobbery:robMethod',
                args = {
                    type = 'break',
                    entity = entity,
                }
            }
        },
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
            
            print(atmHealth)

            if distance > 20 then
                for i = 1, #moneyDrop do
                    DeleteObject(moneyDrop[i])
                end
                return
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
            end
            Wait(300)
        end
    end)
end

function startHacking(entity)
    local haveItem, alreadyRobbed = lib.callback.await('pnt_atmRobbery:checkItem', false, Config.itemToHack, entity)

    if not haveItem then 
        TriggerEvent('QBCore:Notify', 'No tienes el ordenador', 'error')
        return
    end

    if alreadyRobbed then
        TriggerEvent('QBCore:Notify', 'Este atm ya está robado', 'error')
        return 
    end

    -- PONER ALGUNA ANIMACIÓN ANTES DE HACKEAR

    -- PONER ALGUNA ANIMACIÓN ANTES DE HACKEAR

    exports['ps-ui']:Thermite(function(success)
        if not success then 
            TriggerEvent('QBCore:Notify', 'Fallaste', 'error')
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




RegisterNetEvent('pnt_atmRobbery:robMethod', function(args)
    if args.type == 'hack' then
        startHacking(args.entity)
    elseif args.type == 'break' then 
        startBreaking(args.entity)
    end
end)

CreateThread(function()
    exports['qb-target']:AddTargetModel(Config.atmModels, {
        options = {
            {
                icon = "fas fa-credit-card",
                label = "Robar ATM",
                action = function(entity)
                    selectOption(entity)
                end,
            },
        },
        distance = 1.5,
    })
end)

