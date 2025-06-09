local QBCore = exports['qb-core']:GetCoreObject()
local NotifyType = Config.CoreSettings.Notify.Type
local Zones = {}
local currentZone = nil
local timer = 0
local playerPed = PlayerPedId()

--client debug print
function CLDebug(msg)
    if not Config.CoreSettings.Debug.Prints then return end
    print(msg)
end


--client notification
function CLNotify(msg,type,time,title)
    if NotifyType == nil then print('^1| Lusty94_GreenZones | DEBUG | ERROR | NotifyType is nil!') return end
    if not title then title = 'Green Zone' end
    if not time then time = 5000 end
    if not type then type = 'success' end
    if not msg then msg = 'Notification sent with no message!' end
    if NotifyType == 'qb' then
        QBCore.Functions.Notify(msg,type,time)
    elseif NotifyType == 'okok' then
        exports['okokNotify']:Alert(title, msg, time, type, true)
    elseif NotifyType == 'mythic' then
        exports['mythic_notify']:DoHudText(type, msg)
    elseif NotifyType == 'ox' then
        lib.notify({ title = title, description = msg, position = 'top', type = type, duration = time})
    elseif NotifyType == 'qs' then
        exports['qs-interface']:AddNotify(msg, title, time, 'fa-solid fa-clipboard')
    elseif NotifyType == 'custom' then
        --insert your custom notification function here
    else
        print('^1| Lusty94_GreenZones | DEBUG | ERROR | Unknown Notify Type Set In Config.CoreSettings.Notify.Type! '..tostring(NotifyType))
    end
end


--lock inventory
function LockInventory(toggle)
	if toggle then
        LocalPlayer.state:set('inv_busy', true, true)
        CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Toggling Inventory Lock ON')
    else 
        LocalPlayer.state:set('inv_busy', false, true)
        CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Toggling Inventory Lock OFF')
    end
end


--check to ignore
function ignoreRestrictions(zoneName)
    local player = QBCore.Functions.GetPlayerData()
    if not player then return false end
    local ignore = Config.Greenzones.Zones[zoneName] and Config.Greenzones.Zones[zoneName].ignore
    if not ignore then return false end
    for _, job in pairs(ignore.jobs or {}) do
        if player.job and player.job.name == job then CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Ignoring Zone Restrictions | Job: '..job) return true end
    end
    for _, gang in pairs(ignore.gangs or {}) do
        if player.gang and player.gang.name == gang then CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Ignoring Zone Restrictions | Gang: '..gang) return true end
    end
    for _, perm in pairs(ignore.staff or {}) do
        if QBCore.Functions.HasPermission(perm) then CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Ignoring Zone Restrictions | Staff Perm: '..perm) return true end
    end
    return false
end


--enter zone
function enterZone(zoneName)
    if GetGameTimer() - timer < 1000 then return end
    timer = GetGameTimer()
    currentZone = zoneName
    TriggerServerEvent('lusty94_greenzone:enterZone', zoneName)
    local allowed = lib.callback.await('lusty94_greenzone:isInZone', false)
    if not allowed then resetZoneEffects() return end
    local zoneData = Zones[zoneName]
    applyStates(zoneData.states)
    if ignoreRestrictions(zoneName) then
        CLNotify(Config.Language.Notifications.Exempt, 'success')
        CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Player is exempt from restrictions in zone: '..zoneName)
        return
    end
    applyRestrictions(zoneData.restrictions)
    CLNotify(Config.Language.Notifications.EnteredZone, 'success')
    CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Player has entered zone: '..zoneName)
end


--exit zone
function exitZone(zoneName)
    currentZone = nil
    TriggerServerEvent('lusty94_greenzone:exitZone')
    resetZoneEffects()
    CLNotify(Config.Language.Notifications.LeftZone, 'success')
    CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Player has left zone: '..tostring(zoneName))
end


--apply player states
function applyStates(states)
    if states.invincible then SetEntityInvincible(playerPed, true) end
    if states.noRagdoll then SetPedCanRagdoll(playerPed, false) end
    if states.invisible then SetEntityVisible(playerPed, false, false) end
    if states.resetHealth then SetEntityHealth(playerPedId(), 100) end
    if states.resetStress then TriggerServerEvent(Config.CoreSettings.EventNames.Stress, 100) end
    CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | States applied '..json.encode(states))
end


--reset effects
function resetZoneEffects()
    SetEntityInvincible(playerPed, false)
    SetPedCanRagdoll(playerPed, true)
    SetEntityVisible(playerPed, true, false)
    for _, control in ipairs({24, 257, 69, 70, 92, 114, 331, 157, 158, 159, 160, 161, 162, 163, 164, 165}) do
        EnableControlAction(0, control, true)
    end
    LockInventory(false)
    CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Zone effects reset')
end


--apply restrictions
function applyRestrictions(restrictions)
    CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Restrictions applied '..json.encode(restrictions))
    if restrictions.lockInventory then LockInventory(true) end
    if restrictions.disarm then
        SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
        CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Player disarmed')
    end
end


--disable controls
CreateThread(function()
    while true do
        if currentZone then
            local restrictions = Zones[currentZone].restrictions
            if restrictions.melee then DisablePlayerFiring(playerPed, true) end
            if restrictions.shooting then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 257, true)
            end
            if restrictions.driveby then
                DisableControlAction(0, 69, true)
                DisableControlAction(0, 70, true)
                DisableControlAction(0, 92, true)
            end
            if restrictions.vehicleWeapons then
                DisableControlAction(0, 114, true)
                DisableControlAction(0, 331, true)
            end
            if restrictions.disarm then
                if GetSelectedPedWeapon(playerPed) ~= GetHashKey('WEAPON_UNARMED') then
                    SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
                end
                DisableControlAction(0, 157, true)
                DisableControlAction(0, 158, true)
                DisableControlAction(0, 159, true)
                DisableControlAction(0, 160, true)
                DisableControlAction(0, 161, true)
                DisableControlAction(0, 162, true)
                DisableControlAction(0, 163, true)
                DisableControlAction(0, 164, true)
                DisableControlAction(0, 165, true)
            end
        end
        Wait(0)
    end
end)


--create zones
CreateThread(function()
    for zoneName, data in pairs(Config.Greenzones.Zones) do
        Zones[zoneName] = {
            restrictions = data.restrictions or {},
            states = data.states or {},
            zone = lib.zones.sphere({
                coords = data.info.coords,
                radius = data.info.radius or 50,
                debug = data.info.debug or false,
                onEnter = function() enterZone(zoneName) end,
                onExit = function() exitZone(zoneName) end,
            })
        }
        --CLDebug('^3| Lusty94_GreenZones | DEBUG | INFO | Creating Zones | Name: '..zoneName:upper()..' | Coords: '..json.encode(data.info.coords)..' | Zone radius: '..data.info.radius)
        CLDebug(('^3| Lusty94_GreenZones | DEBUG | INFO | Creating Zones | Name %s | Coords %s | Zone Radius %s')):format(zoneName:upper(), json.encode(data.info.coords), data.info.radius)
    end
end)


-- Resource cleanup
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        for _, zoneData in pairs(Zones) do
            if zoneData.zone and zoneData.zone.remove then
                zoneData.zone:remove()
            end
        end
        Zones = {}
        if not currentZone then
            resetZoneEffects()
        end
        LockInventory(false)
        currentZone = nil
        print('^3| Lusty94_GreenZones | DEBUG | INFO | Resource stopped successfully!')
    end
end)