local package = script.Parent.Parent

local Types = require(package.Types)

local castToState = require(script.Parent.castToState)
local evaluate = require(package.Graph.evaluate)

local function peek<V>(target: Types.StateObject<V> | V): V
	if castToState(target) then
		evaluate(target)

		return target._internalValue :: V
	end

	return target :: V
end

return peek
