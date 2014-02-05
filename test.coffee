r = require './src/rehab'

console.log 'example/project1/src/'
r2 = new r 'example/project1/src/'
console.log r2.compile()
console.log '\nexample/project1/src/view/view1.coffee'
r1 = new r 'example/project1/src/view/view1.coffee'
console.log r1.compile()