local calc = require "../calc/types"

local castToState = require "../calc/castToState"

local function flatten<T>(use: calc.Use, target: calc.UsedAs<T>): T
	while castToState(target) do
		target = use(target)
	end

	return target
end

return flatten
