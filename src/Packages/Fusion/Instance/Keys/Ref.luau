local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local xtypeof = require(package.Utility.xtypeof)

local Ref: Types.SpecialKey = table.freeze {
	type = "Ref",
	kind = "key",
	stage = "self",

	apply = function(_: Types.Scope, applyTo: Instance, ref: Types.Value<Instance>)
		if xtypeof(ref) ~= "Value" then
			return error(`Invalid Ref type.`, 2)
		end

		ref:set(applyTo)

		return
	end,
}

return Ref
