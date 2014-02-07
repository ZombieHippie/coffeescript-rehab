module.exports = {
  coffee: (contents, options = {})->
    coffee = require 'coffee-script'
    return coffee.compile contents, options
  styl: (contents, options = {})->
    stylus = require 'stylus'
    return stylus.render(contents, options)
  ext: (ext)->
    switch ext.toLowerCase().replace '.', ''
      when 'js'
        return 'coffee'
      when 'css'
        return 'styl'
      else
        return null
}