local calc = require "./types"
local fort = require "./For/types"
local log = require "../logging/types"
local memory = require "../memory/types"

local External = require "../External"

local checkArity = require "../memory/checkArity"
local doCleanup = require "../memory/doCleanup"

local Computed = require "./Computed"
local For = require "./For"
local Value = require "./Value"

local checkDissolvable = require "./For/checkDissolvable"

local parseError = require "../logging/parseError"

local SUB_OBJECT_META = table.freeze {
	__index = {
		roamKeys = false,
		roamValues = false,
		invalidateInputKey = function(self): ()
			self._inputKeyState:set(self.inputKey)
		end,
		invalidateInputValue = function(self): ()
			self._inputValueState:set(self.inputValue)
		end,
		useOutputPair = function(self, use)
			local pair = use(self._outputPairState)
			return pair.key, pair.value
		end,
	},
}

local function SubObject<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	initialKey: IK,
	initialValue: IV,
	processor: (
		calc.Use,
		memory.Scope<S>,
		IK,
		IV
	) -> (OK, OV)
): fort.SubObject<S, IK, IV, OK, OV>
	local object = setmetatable({
		scope = scope,
		inputKey = initialKey,
		inputValue = initialValue,

		_inputValueState = Value(scope, initialValue),
		_inputKeyState = Value(scope, initialKey),
	}, SUB_OBJECT_META)

	object._outputPairState = Computed(scope, function(use, scope)
		local inputKey = use(object._inputKeyState)
		local inputValue = use(object._inputValueState)
		local ok, outputKey, outputValue =
			xpcall(processor, parseError, use, scope, inputKey, inputValue)

		if ok then
			return { key = outputKey, value = outputValue }
		end

		local err: log.Error = outputKey
		External.logErrorNonFatal("callbackError", err)

		doCleanup(scope)
		table.clear(scope)

		return { key = nil, value = nil }
	end)

	return object
end

local function ForPairs<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	inputTable: calc.UsedAs<{ [IK]: IV }>,
	processor: (
		calc.Use,
		memory.Scope<S>,
		IK,
		IV
	) -> (OK, OV)
): calc.For<OK, OV> | { [OK]: OV }
	checkArity(processor)

	local canDissolve, constant = checkDissolvable(scope, inputTable, processor)

	if canDissolve then
		return constant
	end

	return For(scope, inputTable, function(scope, initialKey, initialValue)
		return SubObject(scope, initialKey, initialValue, processor)
	end)
end

return ForPairs
