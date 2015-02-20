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
    
    getVersion = (callback) ->
        gitrev = require 'git-rev'
        gitrev.short (str) ->
            env.version = str
            callback()

    loadLegos = (callback) -> 
        lego.loadLegos # load plugins from root folder node_modules
            dir: h.path env.root, 'node_modules'
            prefix: 'ribcage_'
            env: env
            , callback

    async.series [getVersion, loadLegos], (err,data) ->
        callback err, env

loadSettings = (folder, settings = {})->
    settingsJs = helpers.path(folder, 'settings.js')
    
    # need to compile coffee?
    if fs.existsSync(settingsCoffee = helpers.path(folder, 'settings.coffee'))
        fs.writeFileSync settingsJs, CoffeeScript.compile String(fs.readFileSync settingsCoffee)
    # load file
    console.log settingsJs
    if fs.existsSync(settingsJs) then _.extend settings, require(settingsJs).settings
    return settings

