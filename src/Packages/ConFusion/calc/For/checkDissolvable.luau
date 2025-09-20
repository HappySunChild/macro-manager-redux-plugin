local calc = require "../types"
local memory = require "../../memory/types"

local External = require "../../External"

local castToState = require "../castToState"

local doCleanup = require "../../memory/doCleanup"
local innerScope = require "../../memory/innerScope"

local dissolvingUse = require "../../use/dissolvingUse"

local function checkDissolvable<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	input: calc.UsedAs<{ [IK]: IV }>,
	processor: (
		calc.Use,
		memory.Scope<S>,
		IK,
		IV
	) -> (OK?, OV?)
): (boolean, { [OK]: OV }?)
	if castToState(input) then
		return false, nil
	end

	local dissolvingScope = innerScope(scope)
	local output = {}

	for key, value in input do
		local ok, outputKey, outputValue =
			pcall(processor, dissolvingUse, dissolvingScope, key, value)

		if not ok then
			doCleanup(dissolvingScope)

			return false, nil
		end

		if outputKey == nil or outputValue == nil then
			continue
		elseif output[outputKey] ~= nil then
			External.logErrorNonFatal("forKeyCollision", nil, tostring(outputKey))
			continue
		end

		output[outputKey] = outputValue
	end

	return true, output
end

return checkDissolvable
