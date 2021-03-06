deppy = require 'deppy'
parser = require './parser'
compiler = require './compiler'
fs = require 'fs'
p = require 'path'

module.exports = class Rehab
  constructor: (path = "", @ext = null)->
    @failed = false
    # Resolve full path
    path = p.resolve path

    # Check if directory
    pathIsDirectory = p.extname(path) is ''

    @dep = deppy.create()

    @sources = []
    @unresolved = []

    # Set aside for caching and middleware usage
    @srcdir = if pathIsDirectory then path else p.dirname path

    if pathIsDirectory
      # Read directory of files and add to unresolved files
      for file in fs.readdirSync path
        fext = p.extname(file)
        # if directory
        continue if p.extname(file) is ''
        if @ext
          if p.extname(file).match ///#{@ext}$///
            @unresolved.push(p.resolve(path, file))
        else
          @unresolved.push(p.resolve(path, file))
      if @unresolved.length is 0
        console.log "[Rehab] Didn't find any files in directory: "+path
        @failed = true
        return
    else
      @unresolved.push path

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
    return null if @failed
    # resolve dependencies and filter out __MAIN__ node element
    @dep.resolve(@REQ_MAIN_NODE).filter (elem)=> elem isnt @REQ_MAIN_NODE
  compile: (options = {}) =>
    return null if @failed
    {path} = options
    ext = @ext
    if path?
      # attempt lookup of precompiled file
      ext = p.extname path

    else
      # for normal usage
      str = @concat()

    # Check if compiler for this filetype exists
    if fn = compiler[ext]
      return fn(str, options)
    else
      console.error "[Rehab] Can't compile files of type:"+@ext
      return null
  concat: =>
    return null if @failed
    code = ""
    for source in @listFiles()
      try
        code += '\n'+fs.readFileSync source
      catch err
        if err.code is 'ENOENT' then return else throw err
    code
  @process: (filePath) ->
    return new Rehab(filePath, 'coffee').listFiles()
  @use: (srcpath, ext) ->
    srcpath = p.resolve srcpath
    (req, res) ->
      path = req.url[1...] # Remove first /
        .replace /\.[a-zA-Z\.]+$/, '.'+ext # Replace extension
      res.write new Rehab(p.resolve srcpath, path).compile()
      res.end()