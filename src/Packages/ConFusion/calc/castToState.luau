local kindof = require "../kindof"

local function castToState(target: unknown)
	if kindof(target) == "state" then
		return target
	end

	return nil
end

return castToState
