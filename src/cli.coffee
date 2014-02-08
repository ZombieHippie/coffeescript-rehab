rehab = require './rehab'
p = require 'path'
fs = require 'fs'
pinfo = JSON.parse fs.readFileSync p.resolve __dirname + '/../package.json'

outputpath = null
write = (path,ext)->
  outputpath ?=  p.basename(path).replace /\.[a-zA-Z]+$/, ext
  fs.writeFileSync outputpath, (new rehab(path)).compile()
  console.log "Compiled file: #{outputpath} from: #{path}"

argv = process.argv[2..]
if argv.length is 2
  outputpath = argv[1]
switch argv.length
  when 1, 2
    path = p.resolve argv[0]
    ext = p.extname path
    switch ext.toLowerCase()
      when '.coffee'
        write path, '.js'
      when '.styl'
        write path, '.css'
      when ''
        write path, 'rehab.output'
  else
    console.log "Rehab2 v"+pinfo.version
    console.log """
      Usage:
        rehab filename.coffee
        rehab filename.styl
        rehab file.styl css/file.css
        rehab file.coffee js/file.js
      """