local memory = require "../../memory/types"

local doCleanup = require "../../memory/doCleanup"

local SpecialKey = require "./SpecialKey"

return SpecialKey "OnRemoval" {
	stage = "observer",
	apply = function(
		scope: memory.Scope,
		applyTo: Instance,
		removalTask: memory.CleanupTask
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
