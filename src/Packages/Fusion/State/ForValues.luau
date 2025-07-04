local External = require "../External"
local Types = require "../Types"

local doCleanup = require "../Memory/doCleanup"

local Computed = require "./Computed"
local Value = require "./Value"

local For = require "./For"
local ForTypes = require "./For/ForTypes"

local parseError = require "../Logging/parseError"

local SUB_OBJECT_META = {
	__index = {
		roamKeys = false,
		roamValues = true,
		invalidateInputKey = function(_): ()
			-- do nothing
		end,
		invalidateInputValue = function(self): ()
			self._inputValueState:set(self.inputValue)
		end,
		useOutputPair = function(self, use)
			return self.inputKey, use(self._outputValueState)
		end,
	},
}

local function SubObject<S, IK, IV, OV>(
	scope: Types.Scope<S>,
	initialKey: IK,
	initialValue: IV,
	processor: (Types.Use, Types.Scope<S>, IK) -> OV
): ForTypes.SubObject<S, IK, IV, IK, OV>
	local object = setmetatable({
		scope = scope,
		inputKey = initialKey,
		inputValue = initialValue,

		_inputValueState = Value(scope, initialValue),
	}, SUB_OBJECT_META)

	object._outputValueState = Computed(scope, function(use, scope)
		local inputValue = use(object._inputValueState)
		local ok, outputValue = xpcall(processor, parseError, use, scope, inputValue)

		if ok then
			return outputValue
		end

		local error: Types.Error = outputValue
		External.logErrorNonFatal("callbackError", error)
		doCleanup(scope)
		table.clear(scope)

		return nil
	end)

	return object
end

local function ForValues<S, IK, IV, OV>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{ [IK]: IV }>,
	processor: (Types.Use, Types.Scope<S>, IK) -> OV
): Types.For<IK, OV>
	return For(scope, inputTable, function(scope, initialKey, initialValue)
		return SubObject(scope, initialKey, initialValue, processor)
	end)
end

return ForValues
