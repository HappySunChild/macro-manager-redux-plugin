local calc = require "../calc/types"

local castToState = require "../calc/castToState"

local function dissolvingUse<T>(target: calc.UsedAs<T>): T
	if castToState(target) then
		error "not-dissolvable"
	end

	return target
end

return dissolvingUse
