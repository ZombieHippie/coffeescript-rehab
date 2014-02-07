module.exports = {
  coffee: (contents)->
    coffee = require 'coffee-script'
    return coffee.compile contents
}