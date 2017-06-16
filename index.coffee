# autocompile

path = require 'path'
async = require 'async'
backbone = require 'backbone4000'
colors = require 'colors'
_ = require 'underscore'
h = require 'helpers'
lego = require 'lego'
fs = require 'fs'
util = require 'util'
LiveScript = require 'LiveScript'
CoffeeScript = require 'coffee-script'

exports.init = (env = {}, callback) ->
    _.extend env, {}

    # should do this better, avoids mocha errors, good for now, investigate later.
    rootCandidates = [
      path.dirname require.main.filename
      process.cwd() ]

    rootDir = _.find rootCandidates, (dir) -> fs.existsSync path.join(dir, 'node_modules')

    env.root = rootDir # figure out app root folder
    env.settings = loadSettings(env.root, env.settings) # load settings from root folder
#    console.log env.root
    if env.settings.verboseInit

      remPw = h.depthFirst env.settings, {}, (val,key) ->
          # not simply hiding the pass, just to be an asshole
          if h.strHas key, 'pass', 'secret', 'login' then return h.uuid(15 + h.randomInt 15)
          else return val

      console.log util.inspect remPw, colors: true, depth: 4

    getVersion = (callback) ->
        gitrev = require 'git-rev'
        gitrev.short (str) ->
            env.version = str
            callback()

    loadLegos = (callback) ->
        lego.loadLegos # load plugins from root folder node_modules
            verbose: env.settings.verboseInit
            dir: env.settings.rootDir or h.path env.root, 'node_modules'
            prefix: 'ribcage_'
            env: env
            , callback

    async.series [getVersion, loadLegos], (err,data) ->
      if process.env.NODE_ENV is "production" then env.env = "prod" else env.env = "dev"
      callback err, env

loadSettings = (folder, settings = {})->
    settingsFile = h.path(folder, 'settings')

    if fs.existsSync(settingsFile + ".js") or fs.existsSync(settingsFile + ".ls") or fs.existsSync(settingsFile + ".coffee")
      fileSettings = require(settingsFile)
      if fileSettings.settings? then fileSettings = fileSettings.settings
      settings = h.extend settings, fileSettings

    return settings
