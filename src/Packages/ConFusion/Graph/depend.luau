local External = require "../External"
local Types = require "../Types"

local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"

local nameOf = require "../Utility/nameOf"

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
