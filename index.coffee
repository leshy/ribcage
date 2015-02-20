path = require 'path'
CoffeeScript = require 'coffee-script'
logger = require 'logger2'
async = require 'async'
backbone = require 'backbone4000'
colors = require 'colors'
_ = require 'underscore'
helpers = require 'helpers'
pluggy = require 'pluggy'
fs = require 'fs'

exports.init = (options = {}, callback) ->
    env = options.env or {}

    env.root = path.dirname require.main.filename
    
    env.settings = loadSettings(env.root, env.settings)

    console.log 'settings', env.settings
    pluggy.loadPlugins
        dir: env.root
        prefix: 'ribcage'
        env: env
        , (err,data) ->
            console.log 'loadplugins res',err,data

loadSettings = (folder, settings = {})->
    # need to compile coffee?
    if fs.existsSync(settingsCoffee = helpers.path(folder, 'settings.coffee'))
        fs.writeFileSync helpers.path(folder, 'settings.js'), CoffeeScript.compile String(fs.readFileSync settingsCoffee)

    # load file
    if fs.existsSync(folder + '/settings.js') then _.extend settings, require('./settings').settings

    settings


exports.init()