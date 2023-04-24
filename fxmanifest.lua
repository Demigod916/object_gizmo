fx_version 'cerulean'
game 'gta5'
lua54 'yes'

ui_page 'web/dist/index.html'

client_scripts {
	"client/*.lua"
}

shared_scripts {
	'@ox_lib/init.lua'
}


files {
	'web/dist/index.html',
	'web/dist/**/*',
}

dependencies {
	'ox_lib'
}
