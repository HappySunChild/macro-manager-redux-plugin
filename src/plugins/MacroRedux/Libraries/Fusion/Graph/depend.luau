local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local castToGraph = require(package.Graph.castToGraph)
local evaluate = require(package.Graph.evaluate)

local nameOf = require(package.Utility.nameOf)

local function depend(user: Types.GraphObject, dependency: Types.GraphObject)
	if castToGraph(dependency) then
		evaluate(dependency)

		if table.isfrozen(user._using) or table.isfrozen(dependency._users) then
			return External.logError(
				"cannotDepend",
				nil,
				nameOf(user, "User"),
				table.isfrozen(user._using) and "FROZEN" or "NOT FROZEN",
				nameOf(dependency, "Dependency"),
				table.isfrozen(dependency._users) and "FROZEN" or "NOT FROZEN"
			)
		end

		user._using[dependency] = true
		dependency._users[user] = true
	end

	return dependency
end

return depend
