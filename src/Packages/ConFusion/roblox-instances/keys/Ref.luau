local calc = require "../../calc/types"

local External = require "../../External"
local xtypeof = require "../../xtypeof"

local SpecialKey = require "./SpecialKey"

local Ref = SpecialKey "Ref" {
	stage = "self",
	apply = function(
		_,
		applyTo: Instance,
		refs: { calc.Value<Instance> } | calc.Value<Instance>
	)
		if xtypeof(refs) == "Value" then
			refs = refs :: calc.Value<Instance>
			refs:set(applyTo)

			return
		end

		refs = refs :: { calc.Value<Instance> }
		for _, ref in refs do
			if xtypeof(ref) ~= "Value" then
				External.logError("expectedType", nil, "Value", xtypeof(ref))
			end

			ref:set(applyTo)
		end
	end,
}

return Ref
