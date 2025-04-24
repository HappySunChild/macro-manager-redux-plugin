local package = script.Parent.Parent

local Types = require(package.Types)

local Computed = require(package.State.Computed)
local castToState = require(package.State.castToState)

local function map<V, O>(value: Types.UsedAs<V>, callback: (V) -> O?): Types.Computed<O> | O
	if not castToState(value) then
		return callback(value)
	end

	return Computed(value.scope, function(use)
		return callback(use(value))
	end)
end

return map
