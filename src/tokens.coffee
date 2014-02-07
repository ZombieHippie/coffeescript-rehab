pathMatch= (ext)->
  return "\\s*_require\\s+(.+)\\s*"
token=(ext)->
  ///
    ^\s*
    #{cm[ext].open}
    #{pathMatch(ext)}
    #{cm[ext].close}
    \s*$
  ///i

module.exports = (ext)->
  ext = ext.toUpperCase()
  if not cm[ext]?
    console.error "Cannot parse files of type:"+ext
    return null
  else
    return token ext

type = {
  # Slash Asterick
  sa:
    open: '/\\*'  # /*
    close: '\\*/' # */
  # Double Slash
  ds:
    open: '//'
    close: ''
  # Hash
  hash:
    open: '#'
    close: ''
}

cm = {
  #Style files
  "STYL": type.ds
  "CSS":  type.ds
  "LESS": type.ds
  "SASS": type.ds

  #Script files
  "RB":   type.hash
  "JS":   type.ds
  "COFFEE": type.hash
}