local package = script.Parent.Parent.Parent

local Types = require(package.Types)
local applyProperties = require(package.Instance.applyProperties)

local Apply: Types.SpecialKey = table.freeze {
	type = "Apply",
	kind = "key",
	stage = "properties",

	apply = applyProperties,
}

return Apply
