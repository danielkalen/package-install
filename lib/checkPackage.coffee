Promise = require 'bluebird'
promiseBreak = require 'promise-break'
semver = require 'semver'
Path = require 'path'
fs = require 'fs-jetpack'


isInstalled = (targetModule)->
	targetModule = targetModule[0] if typeof targetModule is 'object'
	
	if (split=targetModule.split('@')) and split[0].length
		targetModule = split[0]
		targetVersion = split[1]

	if /^github:.+?\//.test(targetModule)
		targetModule = targetModule.replace /^github:.+?\//, ''
	
	pkgFile = Path.resolve('node_modules',targetModule,'package.json')
	Promise.resolve()
		.then ()-> fs.existsAsync(pkgFile)
		.tap (exists)-> promiseBreak(exists) if not targetVersion? or not exists
		.then ()-> require('./readPackageFile')(pkgFile)
		.get('version')
		.then (currentVersion)-> semver.gte(currentVersion, targetVersion)
		.catch promiseBreak.end	


notInstalled = (targetModule)->
	Promise.resolve(targetModule)
		.then isInstalled
		.then (installed)-> not installed



module.exports = isInstalled
module.exports.isInstalled = isInstalled
module.exports.notInstalled = notInstalled