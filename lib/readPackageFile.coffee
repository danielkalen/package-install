memoize = require 'fast-memoize'
fs = require 'fs-jetpack'


readPackageFile = (target)->
	fs.readAsync(target, 'json')


module.exports = memoize(readPackageFile)