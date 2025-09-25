local types = require "@plugin/types"

local Logging = require "@utility/Logging"

local MAX_RECURSION_DEPTH = 8
local _RECURSION_DEPTH = {}

local function updateItemValue(
	macroItem: types.ValueMacroItem<any>,
	newValue: any
)
	local oldValue = macroItem.Value

	if oldValue == newValue then
		return
	end

	macroItem.Value = newValue

	if type(macroItem.Changed) == "function" then
		local currentDepth = macroItem[_RECURSION_DEPTH] or 0

		if currentDepth > MAX_RECURSION_DEPTH then
			Logging.warn "itemChangedInfiniteLoop"

			return
		end

		macroItem[_RECURSION_DEPTH] = currentDepth + 1
		macroItem:Changed(newValue, oldValue)
		macroItem[_RECURSION_DEPTH] = nil
	end
end

return updateItemValue
