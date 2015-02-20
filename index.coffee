path = require 'path'
CoffeeScript = require 'coffee-script'
logger = require 'logger2'
async = require 'async'
_ = require 'underscore'

exports.init = (settings, callback) ->
    if settings.constructor is Function then callback = settings; settings = {}
    env = { settings: settings }
    env.root = path.dirname require.main.filename
    
    if fs.existsSync(env.root + '/settings.coffee')
        coffee = fs.readFileSync env.root + '/settings.coffee'
        fs.writeFileSync envroot + '/settings.js', CoffeeScript.compile coffee
        
    if fs.existsSync(env.root + '/settings.js') then _.extend settings, require('./settings').settings

    