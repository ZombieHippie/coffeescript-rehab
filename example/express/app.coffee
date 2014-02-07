express = require 'express'
rehab = require '../../src/rehab'
app = express()

app.use express.static(__dirname + "/public")
app.use app.router

# Set up Stylus
app.use '/css', rehab.use './stylus/', 'styl'

# Set up CoffeeScript
app.use '/js', rehab.use './coffee/', 'coffee'

app.listen 3000
console.log "Express listening on port 3000"