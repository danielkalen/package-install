extend = require 'extend'

module.exports = (packagePath)->
	packagePath += '/package.json' if not packagePath.endsWith('package.json')

	Promise.resolve(packagePath)
		.then require './readPackageFile'
		.then (pkg)-> extend {}, pkg.dependencies, pkg.devDependencies, pkg.peerDependencies
		.then (deps)-> Object.keys(deps).map (dep)-> "#{dep}@#{deps[dep]}"

