local QBCore = exports['qb-core']:GetCoreObject()
local playerZones = {}

--server debug print
function SVDebug(msg)
    if not Config.CoreSettings.Debug.Prints then return end
    print(msg)
end


--get character name
function getCharacterName(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData and Player.PlayerData.charinfo then
        local info = Player.PlayerData.charinfo
        return (info.firstname or 'Unknown')..' '..(info.lastname or '')
    end
    return 'Unknown'
end


--send logs
function sendLog(source, logType, message, level)
    local logsEnabled = Config.CoreSettings.Security.Logs.Enabled
    if not logsEnabled then return end
    local name = getCharacterName(source)
    local logging = Config.CoreSettings.Security.Logs.Type
    if logging == 'discord' then
        local webhookURL = '' -- set your discord webhook URL here
        if webhookURL == '' then print('^1| Lusty94_GreenZones | DEBUG | ERROR | Logging method is set to Discord but WebhookURL is missing!') return end
        PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
            username = "Lusty94_GreenZones Logs",
            avatar_url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png",
            embeds = {{
                title = "**"..(logType or "Green Zones Log").."**",
                description = message or ("Log triggered by **%s** (ID: %s)"):format(name, source),
                color = level == "warning" and 16776960 or level == "error" and 16711680 or 65280,
                footer = {
                    text = "Lusty94_GreenZones Logs • "..os.date("%Y-%m-%d %H:%M:%S"),
                    icon_url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png"
                },
                thumbnail = {
                    url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png"
                },
                author = {
                    name = 'Lusty94_GreenZones Logs'
                }
            }}
        }), { ['Content-Type'] = 'application/json' })
    elseif logging == 'fm-logs' then
        if not GetResourceState('fm-logs') or GetResourceState('fm-logs') ~= 'started' then
            print('^1| Lusty94_GreenZones | DEBUG | ERROR | Unable to send log | fm-logs is not started!')
            return
        end
        exports['fm-logs']:createLog({
            LogType = logType or "Player",
            Message = message or 'Check Resource',
            Level = level or "info",
            Resource = GetCurrentResourceName(),
            Source = source,
        }, { Screenshot = false })
    end
end


--check player is in zone
lib.callback.register('lusty94_greenzone:isInZone', function(source)
    if playerZones[source] ~= nil then
        return true
    else
        SVDebug(('^1| Lusty94_GreenZones | DEBUG | WARNING | %s attempted to apply green zone effects without being in a valid zone'):format(getCharacterName(source)))
        if Config.CoreSettings.Security.DropPlayer then DropPlayer(source, 'Potential Exploiting Detected') end
        return false
    end
end)


--check staff perms
lib.callback.register('lusty94_greenzone:hasStaffPerm', function(source, perm)
    return QBCore.Functions.HasPermission(source, perm)
end)


--enter zone
RegisterNetEvent('lusty94_greenzone:enterZone', function(zoneName)
    playerZones[source] = zoneName
end)


--reset hunger and thirst
RegisterNetEvent('lusty94_greenzones:server:ResetNeeds', function(resetHunger, resetThirst)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    local currentZone = playerZones[source]
    if not currentZone then
        SVDebug(('^1| Lusty94_GreenZones | SECURITY | %s tried to reset hunger or thirst outside of a valid green zone'):format(getCharacterName(source)))
        sendLog(source, "Security", ("%s attempted to reset hunger or thirst without being in a valid green zone"):format(getCharacterName(source)), "warning")
        if Config.CoreSettings.Security.DropPlayer then DropPlayer(source, 'Potential Exploiting Detected') end
        return
    end
    local newHunger = Player.PlayerData.metadata['hunger']
    local newThirst = Player.PlayerData.metadata['thirst']
    if resetHunger then
        newHunger = 100
        Player.Functions.SetMetaData('hunger', newHunger)
    end
    if resetThirst then
        newThirst = 100
        Player.Functions.SetMetaData('thirst', newThirst)
    end
    TriggerClientEvent('hud:client:UpdateNeeds', source, newHunger, newThirst)
    SVDebug(('^3| Lusty94_GreenZones | DEBUG | INFO | Reset hunger and thirstfor %s in green zone %s'):format(getCharacterName(source), currentZone))
end)


--exit zone
RegisterNetEvent('lusty94_greenzone:exitZone', function()
    playerZones[source] = nil
end)


--cleanup
AddEventHandler('playerDropped', function()
    playerZones[source] = nil
end)


--cleanup
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        playerZones = {}
    end
end)


--version check
local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/Lusty94/UpdatedVersions/main/GreenZones/version.txt', function(err, newestVersion, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
        if not newestVersion then
            print('^1[Lusty94_GreenZones]^7: Unable to fetch the latest version.')
            return
        end
        newestVersion = newestVersion:gsub('%s+', '')
        currentVersion = currentVersion and currentVersion:gsub('%s+', '') or "Unknown"
        if newestVersion == currentVersion then
            print(string.format('^2[Lusty94_GreenZones]^7: ^6You are running the latest version.^7 (^2v%s^7)', currentVersion))
        else
            print(string.format('^2[Lusty94_GreenZones]^7: ^3Your version: ^1v%s^7 | ^2Latest version: ^2v%s^7\n^1Please update to the latest version | Changelogs can be found in the support discord.^7', currentVersion, newestVersion))
        end
    end)
end
CheckVersion()