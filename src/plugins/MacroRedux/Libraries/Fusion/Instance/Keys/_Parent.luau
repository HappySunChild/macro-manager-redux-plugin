local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local observe = require(package.Graph.observe)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local function setParent(instance: Instance, parent: Instance?)
	local success, err = pcall(function()
		instance.Parent = parent
	end)

	if not success then
		warn(err)
	end
end

local Parent = table.freeze {
	type = "Parent",
	kind = "key",
	stage = "ancestor",

	apply = function(_: Types.Scope, applyTo: Instance, parent: Types.UsedAs<Instance?>)
		if castToState(parent) then
			observe(parent, function(new)
				setParent(applyTo, new)
			end)
		end

		setParent(applyTo, peek(parent))
	end,
}

return Parent
