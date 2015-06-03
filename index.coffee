path = require 'path'
CoffeeScript = require 'coffee-script'
async = require 'async'
backbone = require 'backbone4000'
colors = require 'colors'
_ = require 'underscore'
h = require 'helpers'
lego = require 'lego'
fs = require 'fs'
util = require 'util'

exports.init = (env = {}, callback) ->
    _.extend env, {}

    env.root = path.dirname require.main.filename # figure out app root folder
    env.settings = loadSettings(env.root, env.settings) # load settings from root folder

    if not env.verboseInit? or env.verboseInit

        remPw = h.depthFirst env.settings, {}, (val,key) ->
            # not simply hiding the pass, just to be an asshole
            if h.strHas key, 'pass', 'secret' then return h.uuid(15 + h.RandomInt(15))
            else return val

        console.log util.inspect remPw, colors: true

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
    settingsJs = h.path(folder, 'settings.js')

    # need to compile coffee?
    if fs.existsSync(settingsCoffee = h.path(folder, 'settings.coffee'))
        fs.writeFileSync settingsJs, CoffeeScript.compile String(fs.readFileSync settingsCoffee)
    # load file
    if fs.existsSync(settingsJs) then settings = h.extend settings, require(settingsJs).settings

    return settings
