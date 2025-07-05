local Types = require "../../Types"

local xtypeof = require "../../Utility/xtypeof"

local SpecialKey = require "./SpecialKey"

local Ref = SpecialKey "Ref" {
	stage = "self",
	apply = function(_, applyTo: Instance, ref: Types.Value<Instance>)
		if xtypeof(ref) ~= "Value" then
			return error(`Invalid Ref type.`, 2)
		end

		ref:set(applyTo)

		return
	end,
}

return Ref
