RegisterCommand('spawnobject', function(source, args, rawCommand)
    if args[1] then
        local player = source
        local model = args[1]
        local x,y,z,rz = table.unpack(GetEntityCoords(GetPlayerPed(player), false))
        TriggerClientEvent('requestPlayerCoords', player, model, x, y, z, rz)
    end
end, false)

RegisterNetEvent('receivePlayerCoords')
AddEventHandler('receivePlayerCoords', function(model, x, y, z, rz)
    TriggerClientEvent('spawnProp', source, model, x, y, z, rz)
end)

RegisterNetEvent('savePropToDB')
AddEventHandler('savePropToDB', function(model, x, y, z, rx, ry, rz)
    exports.oxmysql:execute('INSERT INTO objects (model, x, y, z, rx, ry, rz) VALUES (@model, @x, @y, @z, @rx, @ry, @rz)', {
        ['@model'] = model,
        ['@x'] = x,
        ['@y'] = y,
        ['@z'] = z,
        ['@rx'] = rx,
        ['@ry'] = ry,
        ['@rz'] = rz
    })
end)

RegisterServerEvent('requestPropsOnStartup')
AddEventHandler('requestPropsOnStartup', function()
    local src = source
    exports.oxmysql:execute('SELECT * FROM objects', {}, function(result)
        if result then
            for i=1, #result do
                local propData = result[i]
                TriggerClientEvent('spawnExistingProp', src, propData.model, propData.x, propData.y, propData.z, propData.rx, propData.ry, propData.rz)
            end
        end
    end)
end)
