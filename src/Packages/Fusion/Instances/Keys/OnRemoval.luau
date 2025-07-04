local Types = require "../../Types"

local doCleanup = require "../../Memory/doCleanup"

local SpecialKey = require "./SpecialKey"

return SpecialKey "OnRemoval" {
	stage = "observer",
	apply = function(
		scope: Types.Scope,
		applyTo: Instance,
		removalTask: Types.CleanupTask
	)
		table.insert(
			scope,
			applyTo.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					doCleanup(removalTask)
				end
			end)
		)
	end,
}
