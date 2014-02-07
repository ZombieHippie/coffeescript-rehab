tokens = require './tokens'

# Parse various filetypes
module.exports = (string, ext)->
  lineRegex = tokens(ext)
  if not lineRegex?
    return []
  dependencies = []
  for line in string.split /\s*[\n\r]+\s*/
    if requiredFile = line.match lineRegex
      # requiredFile may have extension or may not
      requiredFile[1] = requiredFile[1].replace ///\.#{ext}$///i, ''
      dependencies.push requiredFile[1]
  return dependencies