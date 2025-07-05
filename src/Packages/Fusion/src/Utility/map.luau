local Types = require "../Types"

local Computed = require "../State/Computed"
local castToState = require "../State/castToState"

-- TODO: maybe add support for mapping multiple values?

local function map<V, O>(value: Types.UsedAs<V>, callback: (V) -> O?): Types.Computed<O> | O
	if not castToState(value) then
		return callback(value)
	end

	return Computed(value.scope, function(use)
		return callback(use(value))
	end)
end

return map
