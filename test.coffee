r = require './src/rehab'
r2 = new r 'example/coffee/src/'
console.log r2.compile()

r3 = new r 'example/styl/article.styl'
console.log r3.concat()

r1 = new r 'example/coffee/src/view/view1.coffee'
r1.compile()