Promise = require 'bluebird'
promiseBreak = require 'promise-break'
fs = require 'fs-jetpack'

module.exports = (targets, options)->
	targets = [targets] if typeof targets is 'string'
	installed = []
	return installed if not Array.isArray(targets)
	
	Promise.resolve(targets)
		.filter (module)-> require('./checkPackage').notInstalled(module, options)
		.filter (module)-> if typeof module is 'string' then true else module[1]()
		.map (module)-> if typeof module is 'string' then module else module[0]
		.tap (targetModules)-> promiseBreak() if targetModules.length is 0
		.tap (targetModules)-> installed.push(targetModules...)
		.then require('./installPackage').bind(null, options)
		.catch promiseBreak.end
		.return installed

