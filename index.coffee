path = require 'path'
CoffeeScript = require 'coffee-script'
logger = require 'logger2'
async = require 'async'
backbone = require 'backbone4000'
colors = require 'colors'
_ = require 'underscore'
helpers = h = require 'helpers'
lego = require 'lego'
fs = require 'fs'

exports.init = (env = {}, callback) ->
    _.extend env, {}

    env.root = path.dirname require.main.filename # figure out app root folder
    
    env.settings = loadSettings(env.root, env.settings) # load settings from root folder

    lego.loadLegos # load plugins from root folder node_modules
        dir: h.path env.root, 'node_modules'
        prefix: 'ribcage_'
        env: env
        , (err,data) ->
            callback null, env

    

loadSettings = (folder, settings = {})->
    # need to compile coffee?
    if fs.existsSync(settingsCoffee = helpers.path(folder, 'settings.coffee'))
        fs.writeFileSync helpers.path(folder, 'settings.js'), CoffeeScript.compile String(fs.readFileSync settingsCoffee)
    # load file
    if fs.existsSync(folder + '/settings.js') then _.extend settings, require('./settings').settings
    return settings

