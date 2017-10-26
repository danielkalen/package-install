Promise = require 'bluebird'
Path = require 'path'
fs = require 'fs-jetpack'


exports.resolvePackage = (target)->
	Path.resolve('node_modules',target,'package.json')

exports.resolveModule = (target)->
	Path.resolve('node_modules',target)

exports.removeFromCache = (target)->
	delete require.cache[require.resolve(target)]

exports.removePackage = (target)->
	Promise.resolve(target)
		.then exports.resolveModule
		.then fs.existsAsync
		.tap (exists)-> if exists then exports.removeFromCache(target)
		.tap (exists)-> if exists then fs.removeAsync(exports.resolveModule target)


exports.packageVersion = (target)->
	Promise.resolve(target)
		.then exports.resolvePackage
		.then (pkgFile)-> fs.readAsync(pkgFile,'json')
		.get 'version'


exports.assertExists = (target)->
	Promise.resolve()
		.then ()-> fs.existsAsync(target)
		.then (exists)-> require('chai').assert.ok exists, "#{target} exists"

