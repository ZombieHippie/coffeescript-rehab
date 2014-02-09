coffee = require 'coffee-script'
stylus = require 'stylus'
nib = require 'nib'
module.exports = {
  coffee: (contents, options = {})->
    return coffee.compile contents, options
  styl: (contents, options = {})->
    return stylus(contents).use(nib()).render()
  ext: (ext)->
    if not ext?
      return null
    switch ext.toLowerCase().replace '.', ''
      when 'coffee'
        return 'js'
      when 'styl'
        return 'css'
      else
        return null
}