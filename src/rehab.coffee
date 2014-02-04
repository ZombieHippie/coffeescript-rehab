#_require ./tsort


wrench = require('wrench')
fs = require('fs')
path = require('path')

module.exports = class Rehab

  String::beginsWith = (str) -> @match(/// ^#{str} ///)?
  String::endsWith = (str) -> @match(/// #{str}$ ///)?

  REQ_TOKEN: "#_require"
  REQ_MAIN_NODE: "__MAIN__"

  process: (folder) ->
    # create a graph from a folder name: 
    # src/C <- A -> B.coffee -> C
    depGraph = @processDependencyGraph(folder)
    #console.log "1: processDependencyGraph", depGraph

    # normalize filenames: 
    # src/C.coffee <- src/A.coffee -> src/B.coffee -> src/C.coffee
    depGraph = @normalizeFilename(folder, depGraph)
    #console.log "2: normalizeFilename", depGraph

    # create a list from a graph: 
    # A.coffee -> B.coffee -> C.coffee
    depList = @processDependencyList depGraph
    #console.log "3: processDependencyList", depList

    depList.reverse() #yeah!

  processDependencyGraph: (folder) ->
    depGraph = []
    for f in (@getSourceFiles folder)
      @parseRequiredFile folder, f, depGraph
    depGraph
  
  normalizeFilename: (folder, depGraph) ->
    for edge in depGraph
      continue if edge[1] == @REQ_MAIN_NODE

      fileDep = @normalizeCoffeeFilename(edge[0])
      file = @normalizeCoffeeFilename(edge[1])
      
      fullPath = path.resolve path.dirname(fileDep), file
      file = path.join(folder, path.relative(folder, fullPath))
      edge[0..1] = [fileDep, file]
    depGraph

  normalizeCoffeeFilename: (file) ->
    file = "#{file}.coffee" unless file.endsWith ".coffee"
    path.normalize file

  processDependencyList: (depGraph) ->
    depList = tsort(depGraph)
    depList.filter (i) => not i.beginsWith @REQ_MAIN_NODE

  getSourceFiles: (folder) -> 
    files = wrench.readdirSyncRecursive folder 
    (file for file in files when file.endsWith '.coffee')

  parseRequiredLine: (line) ->
    match = line.match ///^#{@REQ_TOKEN}\s+([\w\-\.]\.coffee)///
    return if match? then match[1] else null
  parseRequiredFile: (folder, file, depGraph) ->
    filePath = path.join(folder, file)
    depGraph.push [filePath, @REQ_MAIN_NODE] #every file depends on MAIN (a fake file)

    content = fs.readFileSync(filePath, 'utf8')
    for line in content.split /\s*[\n\r]+\s*/
      if depFileName = @parseRequiredLine(line)
        depGraph.push [filePath, depFileName]