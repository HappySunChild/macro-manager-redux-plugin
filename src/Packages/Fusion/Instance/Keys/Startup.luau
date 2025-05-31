local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local Startup: Types.SpecialKey = table.freeze {
	type = "Startup",
	kind = "key",
	stage = "observer",

	apply = function(_: Types.Scope, parent: Instance, callback: (Instance) -> ())
		callback(parent)
	end,
}

return Startup
