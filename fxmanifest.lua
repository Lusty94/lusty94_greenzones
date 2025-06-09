fx_version 'cerulean'

game 'gta5'

author 'Lusty94'

name 'lusty94_greenzones'

description 'Green Zone Script QB Core'

version '1.0.0'

lua54 'yes'

client_script {
    'client/greenzones_client.lua',
}


server_scripts { 
    'server/greenzones_server.lua',
    '@oxmysql/lib/MySQL.lua',
}


shared_scripts { 
    'shared/config.lua',
    '@ox_lib/init.lua'
}

escrow_ignore {
    'shared/**.lua',
    'client/**.lua',
    'server/**.lua',
}