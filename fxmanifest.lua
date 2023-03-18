fx_version 'cerulean'
lua54 'yes'
game 'gta5' 
use_experimental_fxv2_oal 'yes'
shared_script '@ox_lib/init.lua'
ui_page {
    'web/index.html',
}
client_scripts {
	'config.lua',
	'bridge/target/*.lua',
	'bridge/framework/client/*.lua',
	'bridge/inventory/client/*.lua',
	'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'bridge/framework/server/*.lua',
	'bridge/inventory/server/*.lua',
	'server/main.lua'
}

files {
	'web/index.html',
	'web/script.js',
	'web/style.css',
}