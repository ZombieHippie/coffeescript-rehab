deppy = require 'deppy'
wrench = require 'wrench'
parser = require './parser'
compiler = require './compiler'
fs = require 'fs'
p = require 'path'

module.exports = class Rehab
  constructor: (path=null, @ext = null)->
    if not path?
      console.warn "Path was not provided upon construction of new Rehab()"
      return
    @dep = deppy.create()

    @sources = []
    @unresolved = []

    # Check if directory
    if p.extname(path) is ''
      # Read directory of files and add to unresolved files
      for file in wrench.readdirSyncRecursive path
        if p.extname(file) isnt ''
          @unresolved.push(p.resolve(path, file)) 
    else
      @unresolved.push p.resolve path

    # Determine extension
    if not @ext?
      @ext = p.extname(@unresolved[0])[1...]
    @ext = @ext.toLowerCase()

    @resolveDependencies()

    # Make a route that can sort all dependencies
    @dep(@REQ_MAIN_NODE, @sources)

  resolveDependencies: =>
    while loose = @unresolved[0]
      # Parse file for dependencies
      data = fs.readFileSync(loose)

      # get extension ".COFFEE" and remove .
      ext = p.extname(loose)[1...]
      deps = parser data.toString(), ext

      # Resolve relative paths
      loosedir = p.dirname loose
      deps = (p.resolve(loosedir, dep+'.'+ext) for dep in deps)[...]

      @dep loose, deps
      @unresolved.shift()
      @sources.push loose

      for dependency in deps
        if(dependency not in @sources)
            @unresolved.push dependency

  listFiles: =>
    # resolve dependencies and filter out __MAIN__ node element
    @dep.resolve(@REQ_MAIN_NODE).filter (elem)=> elem isnt @REQ_MAIN_NODE
  compile: =>
    if fn = compiler[@ext]
      return fn(@concat())
    else
      console.error "Can't compile files of type:"+@ext
      return null
  concat: =>
    code = ""
    for source in @listFiles()
      try
        code += '\n'+fs.readFileSync source
      catch err
        if err.code is 'ENOENT' then return else throw err
    code
  process: (filePath) ->
    return new Rehab(filePath, 'coffee').listFiles()