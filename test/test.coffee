Promise = require('bluebird').config longStackTraces:process.env.DEBUG
fs = require 'fs-jetpack'
Path = require 'path'
chai = require 'chai'
expect = chai.expect
packageInstall = require('../')
helpers = require './helpers'
silent = stdio:'ignore', silent:true


suite "package-install", ()->
	test "install packages if doesn't exist", ()->
		expectation = ()-> require 'leven'
		
		Promise.resolve()
			.then ()-> helpers.removePackage('leven')
			.then ()-> expect(expectation).to.throw()
			.then ()-> packageInstall('leven', silent)
			.then (installed)-> expect(installed).to.eql ['leven']
			.then ()-> expect(expectation).not.to.throw()



	test "will skip packages that already exist", ()->
		expectation = ()-> ['leven','batch','tuple'].map(require)
		
		Promise.resolve(['leven','batch','tuple'])
			.map helpers.removePackage
			.then ()-> expect(expectation).to.throw()
			.then ()-> packageInstall('leven', silent)
			.then (installed)-> expect(installed).to.eql ['leven']
			.then ()-> expect(expectation).to.throw()
			.then ()-> packageInstall(['leven','batch','tuple'], silent)
			.then (installed)-> expect(installed).to.eql ['batch','tuple']
			.then ()-> packageInstall(['leven','batch','tuple'], silent)
			.then (installed)-> expect(installed).to.eql []
			.then ()-> expect(expectation).not.to.throw()



	test "supports version tag (will install if current installed is lower than requested)", ()->
		expectation = ()-> require 'leven'
		
		Promise.resolve()
			.then ()-> helpers.removePackage('leven')
			.then ()-> expect(expectation).to.throw()
			
			.then ()-> packageInstall('leven@1.0.2', silent)
			.then (installed)-> expect(installed).to.eql ['leven@1.0.2']
			.then ()-> expect(expectation).not.to.throw()
			.then ()-> helpers.packageVersion('leven')
			.then (version)-> expect(version).to.equal '1.0.2'
			
			.then ()-> packageInstall('leven@1.0.1', silent)
			.then (installed)-> expect(installed).to.eql []
			.then ()-> helpers.packageVersion('leven')
			.then (version)-> expect(version).to.equal '1.0.2'
			
			.then ()-> packageInstall('leven@2.0.0', silent)
			.then (installed)-> expect(installed).to.eql ['leven@2.0.0']
			.then ()-> helpers.packageVersion('leven')
			.then (version)-> expect(version).to.equal '2.0.0'


	test "supports range version tags", ()->
		expectation = ()-> require 'leven'
		
		Promise.resolve()
			.then ()-> helpers.removePackage('leven')
			.then ()-> expect(expectation).to.throw()
			
			.then ()-> packageInstall('leven@1.0.1', silent)
			.then (installed)-> expect(installed).to.eql ['leven@1.0.1']
			.then ()-> expect(expectation).not.to.throw()
			.then ()-> helpers.packageVersion('leven')
			.then (version)-> expect(version).to.equal '1.0.1'
			
			.then ()-> packageInstall('leven@^1.0.0', silent)
			.then (installed)-> expect(installed).to.eql []
			.then ()-> helpers.packageVersion('leven')
			.then (version)-> expect(version).to.equal '1.0.1'
			
			.then ()-> packageInstall('leven@>2.0.0', silent)
			.then (installed)-> expect(installed).to.eql ['leven@>2.0.0']
			.then ()-> helpers.packageVersion('leven')
			.then (version)-> expect(version).to.equal '2.1.0'



	test "supports github repos", ()->
		expectation = ()-> require 'leven'
		
		Promise.resolve()
			.then ()-> helpers.removePackage('leven')
			.then ()-> expect(expectation).to.throw()
			.then ()-> packageInstall('github:sindresorhus/leven', silent)
			.then (installed)-> expect(installed).to.eql ['github:sindresorhus/leven']
			.then ()-> expect(expectation).not.to.throw()
			
			.then ()-> helpers.removePackage('leven')
			.then ()-> packageInstall('leven', silent)
			.then (installed)-> expect(installed).to.eql ['leven']
			.then ()-> packageInstall('github:sindresorhus/leven', silent)
			.then (installed)-> expect(installed).to.eql []
			
			.then ()-> helpers.removePackage('leven')
			.then ()-> packageInstall('level@github:sindresorhus/leven', silent)
			.then (installed)-> expect(installed).to.eql ['level@github:sindresorhus/leven']


	test "importing from package file", ()->
		Promise.resolve()
			.then ()-> fs.dirAsync './temp', empty:true
			.then ()-> fs.writeAsync './temp/package.json', 
				dependencies:
					'extend':'^3.0.0'
					'leven':'^2.0.0'
				devDependencies:
					'tuple':'*'
					'batch':'~0.3.0'

			.then ()-> packageInstall.fromPackage './temp', silent
			.then (installed)-> expect(installed).to.eql ['extend@^3.0.0','leven@^2.0.0','tuple@*','batch@~0.3.0']
			.then ()-> helpers.assertExists './temp/node_modules/leven'
			
			.then ()-> packageInstall.fromPackage './temp', silent
			.then (installed)-> expect(installed).to.eql []
			
			.return ['./temp/node_modules/extend', './temp/node_modules/batch']
			.map fs.removeAsync
			.then ()-> packageInstall.fromPackage './temp', silent
			.then (installed)-> expect(installed).to.eql ['extend@^3.0.0','batch@~0.3.0']

			.finally ()-> fs.remove './temp'





