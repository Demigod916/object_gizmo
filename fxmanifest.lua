fx_version 'cerulean'
game 'gta5'
lua54 'yes'

version '2.0.2'

client_scripts {
	"client/gizmo.lua",
	'client/test.lua'
}

shared_scripts {
	'@ox_lib/init.lua'
}

files {
	'client/dataview.lua',
}

server_script 'version.lua'

dependencies {
	'ox_lib'
}
