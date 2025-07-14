fx_version 'cerulean'
game 'gta5'
use_fxv2_oal 'yes'

author 'Elevate'
description 'Nitro System for Elevate'
version '1.0.0'
lua54 'yes'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}

client_scripts {
    'client.lua',
    'utils.lua'
}
server_scripts {
  "@mysql-async/lib/MySQL.lua",
  'server.lua'
}

shared_scripts {
  "@ox_lib/init.lua",
  "@es_extended/imports.lua",
  "config.lua",
}