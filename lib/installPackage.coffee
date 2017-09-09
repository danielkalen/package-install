Promise = require 'bluebird'
execa = require 'execa'
chalk = require 'chalk'


module.exports = (options={}, targetModules)->
	targetModules = [targetModules] if typeof targetModules is 'string'
	options.silent ?= false
	options.stdio ?= 'inherit'
	
	unless options?.silent
		console.log "#{chalk.yellow('Installing')} #{chalk.dim targetModules.join ', '}"

	Promise.resolve()
		.then ()-> execa('npm', ['install', '--no-save', '--no-purne', targetModules...], options)