local External = require "../../External"
local Types = require "../../Types"

local STAGE_ORDER = table.freeze {
	"self",
	"descendants",
	"properties",
	"ancestor",
	"observer",
	"last",
}

local function sortKeys(a: Types.SpecialKey, b: Types.SpecialKey)
	local aIndex = table.find(STAGE_ORDER, a.stage)
	local bIndex = table.find(STAGE_ORDER, b.stage)

	if not aIndex then
		External.logWarn(
			if a.stage == nil then "missingSpecialKeyStage" else "invalidSpecialKeyStage",
			a.type,
			a.stage
		)

		return true
	elseif not bIndex then
		External.logWarn(
			if b.stage == nil then "missingSpecialKeyStage" else "invalidSpecialKeyStage",
			b.type,
			b.stage
		)

		return false
	end

	return aIndex < bIndex
end

return sortKeys
