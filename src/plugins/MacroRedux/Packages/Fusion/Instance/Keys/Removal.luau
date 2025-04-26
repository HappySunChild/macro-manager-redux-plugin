local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local doCleanup = require(package.Memory.doCleanup)

local Removal: Types.SpecialKey = table.freeze {
	type = "Removal",
	kind = "key",
	stage = "observer",

	apply = function(scope: Types.Scope, applyTo: Instance, task: Types.CleanupTask)
		table.insert(
			scope,
			applyTo.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					doCleanup(task)
				end
			end)
		)
	end,
}

return Removal
