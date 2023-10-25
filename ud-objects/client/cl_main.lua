local isRotating = false
local isPlacing = false
local currentProp = nil

Citizen.CreateThread(function()
    Wait(5000)
    TriggerServerEvent('requestPropsOnStartup')
end)

RegisterNetEvent('spawnProp')
AddEventHandler('spawnProp', function(model, x, y, z)
    local hash = GetHashKey(model)
    RequestModel(hash)
    
    while not HasModelLoaded(hash) do
        Wait(500)
    end
    
    if currentProp ~= nil then
        DeleteObject(currentProp)
    end
    
    currentProp = CreateObject(hash, x, y, z, false, false, true)
    SetEntityHeading(currentProp, 0.0)
    SetEntityHasGravity(currentProp, false)
    FreezeEntityPosition(currentProp, true)
    SetEntityCollision(currentProp, true, true)
    Wait(500) 

    isPlacing = true
    Citizen.CreateThread(function()
        while isPlacing do
            Citizen.Wait(0)
            
            local speed = 0.05
            local rotationSpeed = 1.0
            local forward = 0.0
            local right = 0.0
            local up = 0.0
            local rx, ry, rz = 0.0, 0.0, 0.0
            
            -- Movement Controls
            if IsControlPressed(0, 173) then -- Down Arrow Key
                forward = -speed
            elseif IsControlPressed(0, 172) then -- Up Arrow Key
                forward = speed
            elseif IsControlPressed(0, 174) then -- Left Arrow Key
                right = -speed
            elseif IsControlPressed(0, 175) then -- Right Arrow Key
                right = speed
            elseif IsControlPressed(0, 44) then -- 'Q' Key
                up = -speed
            elseif IsControlPressed(0, 38) then -- 'E' Key
                up = speed
            end

            -- Rotation Controls
            if IsControlPressed(0, 34) then -- 'A' Key
                rz = -rotationSpeed
            elseif IsControlPressed(0, 35) then -- 'D' Key
                rz = rotationSpeed
            end

            local x,y,z = table.unpack(GetEntityCoords(currentProp, false))
            local currRx, currRy, currRz = table.unpack(GetEntityRotation(currentProp, 2))

            SetEntityCoordsNoOffset(currentProp, x + right, y + forward, z + up, true, true, true)
            SetEntityRotation(currentProp, currRx + rx, currRy + ry, currRz + rz, 2, true)

            if IsControlJustReleased(0, 191) then -- Enter Key
                isPlacing = false
                SetEntityHasGravity(currentProp, true)
                FreezeEntityPosition(currentProp, true)

                local finalX, finalY, finalZ = table.unpack(GetEntityCoords(currentProp, false))
                local finalRx, finalRy, finalRz = table.unpack(GetEntityRotation(currentProp, 2))
                TriggerServerEvent('savePropToDB', model, finalX, finalY, finalZ, finalRx, finalRy, finalRz)
            end
        end
    end)
end)

RegisterNetEvent('spawnExistingProp')
AddEventHandler('spawnExistingProp', function(model, x, y, z, rx, ry, rz)
    local hash = GetHashKey(model)
    RequestModel(hash)
    
    while not HasModelLoaded(hash) do
        Wait(500)
    end
    
    local prop = CreateObject(hash, x, y, z, true, false, true)
    SetEntityRotation(prop, rx, ry, rz, 2, true)
    FreezeEntityPosition(prop, true)
end)

RegisterNetEvent('requestPlayerCoords')
AddEventHandler('requestPlayerCoords', function(model)
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1), false))
    TriggerServerEvent('receivePlayerCoords', model, x, y, z)
end)
