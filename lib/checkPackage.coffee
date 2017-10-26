Promise = require 'bluebird'
promiseBreak = require 'promise-break'
semver = require 'semver'
Path = require 'path'
fs = require 'fs-jetpack'
RANGE_IDENTIFIERS = ['>','<','=','^','~']
GITHUB_MODULE = /^github:.+?\//


isInstalled = (targetModule, options={})->
	options.cwd ?= process.cwd()
	targetModule = targetModule[0] if typeof targetModule is 'object'
	
	if (split=targetModule.split('@')) and split[0].length
		targetModule = split[0]
		targetVersion = split[1]

	if GITHUB_MODULE.test(targetModule)
		targetModule = targetModule.replace GITHUB_MODULE, ''
	
	pkgFile = Path.resolve(options.cwd,'node_modules',targetModule,'package.json')
	Promise.resolve()
		.then ()-> fs.existsAsync(pkgFile)
		.tap (exists)-> promiseBreak(exists) if not targetVersion? or not exists
		.then ()-> require('./readPackageFile')(pkgFile)
		.get('version')
		.then (currentVersion)-> compareVersion(currentVersion, targetVersion)
		.catch promiseBreak.end	


notInstalled = (targetModule, options)->
	Promise.resolve([targetModule, options])
		.spread isInstalled
		.then (installed)-> not installed


compareVersion = (currentVersion, targetVersion)-> switch
	when targetVersion[0] is '*'
		return true

	when GITHUB_MODULE.test(targetVersion)
		return true
	
	when RANGE_IDENTIFIERS.some((k)-> k is targetVersion[0])
		semver.satisfies(currentVersion, targetVersion)
	
	else
		semver.gte(currentVersion, targetVersion)



module.exports = isInstalled
module.exports.isInstalled = isInstalled
module.exports.notInstalled = notInstalled