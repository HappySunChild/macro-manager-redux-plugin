local Types = require "../Types"

local castToState = require "./castToState"
local evaluate = require "../Graph/evaluate"

local function peek<V>(target: Types.StateObject<V> | V): V
	if castToState(target) then
		evaluate(target)

		return target._internalValue :: V
	end

	return target :: V
end

return peek
