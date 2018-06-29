extend = require 'extend'

module.exports = (packagePath)->
	packagePath += '/package.json' if not packagePath.endsWith('package.json')

	Promise.resolve(packagePath)
		.then require './readPackageFile'
		.then extractDeps
		.then (deps)-> Object.keys(deps).map (dep)-> "#{dep}@#{deps[dep]}"


extractDeps = (pkg)->
	deps = extend {}, pkg.dependencies, pkg.peerDependencies
	deps = extend deps, pkg.devDependencies unless process.env.NODE_ENV is 'production'
	return deps
