fx_version 'cerulean'
games { 'rdr3', 'gta5' }

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Ludwig Development'

shared_scripts {
    '@ox_lib/init.lua',
    'initconfig.lua',
    'shared/**',
    'lang/**'
}

client_scripts {
    'client/**'
}

server_scripts {
    'server/**'
}

ui_page {
    "frontend/dist/index.html"
}

files {
    "frontend/dist/index.html",
    "frontend/dist/assets/**",
}
