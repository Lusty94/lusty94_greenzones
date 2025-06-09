Config = {}

--
--██╗░░░░░██╗░░░██╗░██████╗████████╗██╗░░░██╗░█████╗░░░██╗██╗
--██║░░░░░██║░░░██║██╔════╝╚══██╔══╝╚██╗░██╔╝██╔══██╗░██╔╝██║
--██║░░░░░██║░░░██║╚█████╗░░░░██║░░░░╚████╔╝░╚██████║██╔╝░██║
--██║░░░░░██║░░░██║░╚═══██╗░░░██║░░░░░╚██╔╝░░░╚═══██║███████║
--███████╗╚██████╔╝██████╔╝░░░██║░░░░░░██║░░░░█████╔╝╚════██║
--╚══════╝░╚═════╝░╚═════╝░░░░╚═╝░░░░░░╚═╝░░░░╚════╝░░░░░░╚═╝
--

-- Thank you for downloading this script!

-- Below you can change multiple options to suit your server needs.

-- Extensive documentation detailing this script and how to confiure it correclty can be found here: https://lusty94-scripts.gitbook.io/documentation/free/green-zones


Config.CoreSettings = {
    Debug = {
        Prints = true, -- sends debug prints to f8 console and txadmin server console
        Zones = true, -- debug and display zones
    },
    Security = {
        Logs = true, -- send logs
        DropPlayer = true, -- set to true to kick the player if they fail security checks
        Logs = {
            Enabled = true, -- enable logs for events with detailed information
            Type = 'discord', -- type of logging, support for fm-logs(preferred) or discord webhook (not recommended)
            --use 'fm-logs' for fm-logs (if using this ensure you have setup the resource correctly and it is started before this script)
            --use 'discord' for discord webhooks (if using this make sure to set your webhook URL in the sendLog function in greenzones_server.lua)
        },
    },
    EventNames = {
        Stress = 'hud:server:RelieveStress', -- name of event to releive stress - default is 'hud:server:RelieveStress'
    }, 
    Notify = { -- notification type - support for qb-core notify okokNotify, mythic_notify, ox_lib notify and qs-notify (experimental not tested)
        --EDIT CLIENT/GREENZONES_CLIENT.LUA & SERVER/GREENZONES_SERVER.LUA TO ADD YOUR OWN NOTIFY SUPPORT
        Type = 'ox',
        --use 'qb' for default qb-core notify
        --use 'okok' for okokNotify
        --use 'mythic' for mythic_notify
        --use 'ox' for ox_lib notify
        --use 'qs' for qs-notify (experimental not tested) (qs-interface)  -- some logic might need adjusting
        --use 'custom' for custom notifications
    },
}



Config.Greenzones = {
    Zones = {
        ['pillbox_ems'] = { -- the key must be unique
            info = {-- zone info
                debug = true, -- debug zone
                coords = vector3(310.3, -590.55, 43.29), -- zone spawn coords
                thickness = 10, -- zone thickness
                radius = 65, -- zone radius
            },
            states = { -- define states in this zone
                resetHealth = false, -- resets the players health back to 100 in this zone
                resetStress = true, -- resets the players stress back to 0 in this zone
                invincible = false, -- makes the player invincible in this zone
                invisible = false, -- makes the player invisible in this zone
                noRagdoll = false, -- stops players ragdolling in this zone
            },
            restrictions = { -- define restrictions in this zone
                disarm = true, -- disarms the player in this zone if carrying a weapon
                melee = true, -- disable melee in this zone
                shooting = true, -- disable shooting in this zone
                driveby = true, -- disables drive by shooting in this zone
                vehicleWeapons = true, -- disables vehicle weapons in this zone
                lockInventory = false, -- locks the players inventory in this zone
            },
            ignore = { -- define ignore restrictions in this zone
                jobs = { -- ignore restrictions for jobs
                    --add jobs here or leave this empty
                    'ambulance',
                },
                gangs = {-- ignore restrictions for gangs
                    --add gangs here or leave this empty
                },
                staff = { -- ignore restrictions for permissions
                    --add permissions here or leave this empty
                    'admin',
                    'god',
                    'mod',
                },
            },
        },
        ['mission_row_police'] = { -- the key must be unique
            info = { -- zone info
                debug = true, -- debug zone
                coords = vector3(447.9, -987.77, 30.69), -- zone spawn coords
                thickness = 10, -- zone thickness
                radius = 50, -- zone radius
            },
            states = { -- define states in this zone
                resetHealth = false, -- resets the players health back to 100 in this zone
                resetStress = false, -- resets the players stress back to 0 in this zone
                invincible = true, -- makes the player invincible in this zone
                invisible = false, -- makes the player invisible in this zone
                noRagdoll = true, -- stops players ragdolling in this zone
            },
            restrictions = { -- define restrictions in this zone
                disarm = true, -- disarms the player in this zone if carrying a weapon
                melee = false, -- disable melee in this zone
                shooting = false, -- disable shooting in this zone
                driveby = true, -- disables drive by shooting in this zone
                vehicleWeapons = true, -- disables vehicle weapons in this zone
                lockInventory = false, -- locks the players inventory in this zone
            },
            ignore = { -- define ignore restrictions in this zone
                jobs = { -- ignore restrictions for jobs
                    --add jobs here or leave this empty
                    'ambulance',
                },
                gangs = {-- ignore restrictions for gangs
                    --add gangs here or leave this empty
                },
                staff = { -- ignore restrictions for permissions
                    --add permissions here or leave this empty
                    'admin',
                    'god',
                    'mod',
                },
            },
        },
        --add more zones as required
    }
}


Config.Language = {
    Notifications = {
        Exempt = 'You have entered a green zone but are exempt from restrictions',
        EnteredZone = 'You have entered a green zone!',
        LeftZone = 'You have left a green zone!',
    },
}