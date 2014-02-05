wrench = require('wrench')
fs = require('fs')
p = require('path')
deppy = require('deppy')

String::endsWith = (str) -> @match(/// #{str}$ ///)?
String::getDir = ->
  return if @endsWith '.coffee'
  then p.dirname @
  else @.toString()

module.exports = class Rehab
  constructor: (path=null)->
    if not path?
      console.warn "Path was not provided upon construction of new Rehab()"
      return
    @dep = deppy.create()

    sources = @getSourceFiles(path)
    sourceFolder = path.getDir()
    @sources = []
    @unresolved = []
    @processDependencies(sources, sourceFolder)
    while @unresolved.length
      toResolve = @unresolved[0]
      @processDependencies [p.basename toResolve], p.dirname toResolve
    @dep(@REQ_MAIN_NODE, @sources)
    #depGraph = @processDependencyGraph(filePath)

    #depGraph = @normalizeFilename(filePath.getDir(), depGraph)
    # create a list from a graph:
    # A.coffee -> B.coffee -> C.coffee
    #depList = @processDependencyList depGraph
    
    #depList.reverse() #yeah!
  listFiles: =>
    # resolve dependencies and filter out __MAIN__ node element
    #console.log listSources:@sources
    @dep.resolve(@REQ_MAIN_NODE).filter (elem)=> elem isnt @REQ_MAIN_NODE
  compile: =>
    coffee = require 'coffee-script'
    code = ""
    for source in @listFiles()
      try
        code += '\n'+fs.readFileSync source
      catch err
        if err.code is 'ENOENT' then return else throw err
    return coffee.compile code

  REQ_MAIN_NODE: "__MAIN__"
  REQ_LINE_REGEX: ///^
    \#_require           #TOKEN
    \s+
    (.+(?=coffee)coffee) #FILEPATH
  ///

  process: (filePath) ->
    return new Rehab(filePath).listFiles()

  processDependencies:(sources, folder) =>
    #console.log "process:", sources
    for fl in sources
      filePath = p.resolve(folder, fl)
      if filePath in @sources
        #already evaluated
        continue
      #parse dependencies
      deps = @parseFile fl, folder
      # add to dependency graph
      @dep(filePath, deps)
      @sources.push filePath
      for depend in deps
        if(depend not in @sources)and(depend not in @unresolved)
          #console.log {depend}
          @unresolved.push depend
      @unresolved = @unresolved.filter (elem)=>
        elem not in @sources
  normalizeCoffeeFile: (filename) ->
    if not filename.endsWith '.coffee'
      filename = filename + '.coffee'
    return filename
  getSourceFiles: (filePath) ->
    if filePath.endsWith '.coffee'
      return [p.basename filePath]
    else
      files = wrench.readdirSyncRecursive filePath 
      (file for file in files when file.endsWith '.coffee')
  parseFile: (file, folder) =>
    file = @normalizeCoffeeFile file
    filePath = p.resolve folder, file

    reqs = []
    #split content into separate lines
    content = fs.readFileSync(filePath, 'utf8')
    #lines are split and trimmed
    for line in content.split /\s*[\n\r]+\s*/
      if requiredFile = line.match @REQ_LINE_REGEX
        # get full path of file
        reqFile = p.resolve folder+'relchild', requiredFile[1]
        reqs.push reqFile
    #console.log {file, reqs}
    return reqs
  parseRequiredFile: (folder, basename) =>
    ##console.log {folder, file}
    filePath = p.join(folder, basename)
    reqs = [@REQ_MAIN_NODE] #every file depends on MAIN (a fake file)

    content = fs.readFileSync(filePath, 'utf8')
    for line in content.split /\s*[\n\r]+\s*/
      if requiredFile = @parseRequiredLine(line)
        reqs.push [requiredFile]
    @dep(filePath, reqs)