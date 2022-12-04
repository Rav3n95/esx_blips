fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'ESX Blips'
repository ''
version '1.0.0'

shared_scripts {
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config.lua'
}

client_script 'blips_cl.lua'
server_script 'blips_sv.lua'

ui_page 'web/index.html'

files {
	'web/**',
}

dependency 'es_extended'