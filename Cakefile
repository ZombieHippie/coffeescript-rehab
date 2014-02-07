{exec, spawn} = require 'child_process'

build = ->
  console.log "Building project from src/*.coffee to lib/"
  
  output = "--output lib"
  compile_from_files = "--compile src/"
  exec "coffee #{output} #{compile_from_files}", (err, stdout, stderr) ->
    throw err if err

task 'build', 'Compile coffee files', build