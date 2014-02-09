rehab = require './rehab'
compiler = require './compiler'
p = require 'path'
fs = require 'fs'
pinfo = JSON.parse fs.readFileSync p.resolve __dirname + '/../package.json'

outputpath = null
write = (path,ext = null)->
  r = new rehab(path)
  ext ?= compiler.ext r.ext
  if p.extname(path) is '' # Source is directory
    outputpath ?= p.basename(path) + '.' + ext
  else
    outputpath ?= p.basename(path).replace /\.[a-zA-Z]+$/, ext

  if compiled = r.compile()
    fs.writeFileSync outputpath, compiled
    console.log "[Rehab] Compiled file: #{outputpath} from: #{path}"
  else
    console.log "[Rehab] Could not compile from specified path: "+path
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
        write path
  else
    console.log "Rehab2 v"+pinfo.version
    console.log """
      Usage:
        rehab filename.coffee
        rehab filename.styl
        rehab file.styl css/file.css
        rehab file.coffee js/file.js
      """