--!strict

local xkindof = require "../Utility/xkindof"

local function castToState(target: unknown)
	if xkindof(target) == "state" then
		return target
	end

	return nil
end

return castToState
