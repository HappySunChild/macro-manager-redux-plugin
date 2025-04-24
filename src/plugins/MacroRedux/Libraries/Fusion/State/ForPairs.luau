local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local doCleanup = require(package.Memory.doCleanup)

local Computed = require(package.State.Computed)
local For = require(package.State.For)
local ForTypes = require(package.State.For.ForTypes)
local Value = require(package.State.Value)

local parseError = require(package.Logging.parseError)

local SUB_OBJECT_META = {
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
	scope: Types.Scope<S>,
	initialKey: IK,
	initialValue: IV,
	processor: (
		Types.Use,
		Types.Scope<S>,
		IK,
		IV
	) -> (OK, OV)
): ForTypes.SubObject<S, IK, IV, OK, OV>
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

		local error: Types.Error = outputKey
		External.logErrorNonFatal("callbackError", error)

		doCleanup(scope)
		table.clear(scope)

		return { key = nil, value = nil }
	end)

	return object
end

local function ForPairs<S, IK, IV, OK, OV>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{ [KI]: V }>,
	processor: (Types.Use, Types.Scope<S>, KI) -> KO
): Types.For<OK, OV>
	return For(scope, inputTable, function(scope, initialKey, initialValue)
		return SubObject(scope, initialKey, initialValue, processor)
	end)
end

return ForPairs
