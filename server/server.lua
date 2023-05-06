local QBCore = exports['qb-core']:GetCoreObject()
local alreadyRobbed = {}

lib.callback.register('pnt_atmRobbery:checkItem', function(source, item, atm)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local item = Player.Functions.GetItemByName(item)
    local robbed = alreadyRobbed[atm] == true 

    if item then 
        return true, robbed 
    end

    return false, robbed
end)

RegisterNetEvent('pnt_atmRobbery:atmRobbed', function(atm)
    alreadyRobbed[atm] = true

    SetTimeout(Config.resetAtm * 1000 * 60, function()
        alreadyRobbed[atm] = false
    end)
end)

RegisterNetEvent('pnt_atmRobbery:giveMoney', function(money)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    Player.Functions.AddMoney('cash', money)
end)