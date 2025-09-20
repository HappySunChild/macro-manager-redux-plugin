local External = require "../External"

local function checkArity(callback: (...unknown) -> ())
	local parameterCount, variadic = debug.info(callback, "a")

	-- unclear what to do here, i'm just gonna assume it's ok
	if variadic then
		return true
	end

	if parameterCount >= 2 then
		return true
	end

	External.logWarn("callbackNoScope", tostring(debug.info(2, "n")))

	return false
end

return checkArity
