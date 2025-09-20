local applyProperties = require "../applyProperties"

local SpecialKey = require "./SpecialKey"

local Passthrough = SpecialKey "Passthrough" {
	stage = "properties",
	apply = applyProperties,
}

return Passthrough
