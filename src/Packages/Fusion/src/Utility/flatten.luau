local Types = require "../Types"

local castToState = require "../State/castToState"

local function flatten<T>(use: Types.Use, target: Types.UsedAs<T>): T
	while castToState(target) do
		target = use(target)
	end

	return target
end

return flatten
