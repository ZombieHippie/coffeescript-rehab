coffee = require 'coffee-script'
stylus = require 'stylus'
nib = require 'nib'
module.exports = {
  coffee: (contents, options = {})->
    return coffee.compile contents, options
  styl: (contents, options = {})->
    return stylus(contents).use(nib()).render()
  ext: (ext)->
    switch ext.toLowerCase().replace '.', ''
      when 'js'
        return 'coffee'
      when 'css'
        return 'styl'
      else
        return null
}