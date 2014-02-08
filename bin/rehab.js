#!/usr/bin/env node
require('coffee-script/register');
var path = require('path');
var fs   = require('fs');
var src  = path.join(path.dirname(fs.realpathSync(__filename)), '../src');

require(src + '/cli.coffee')