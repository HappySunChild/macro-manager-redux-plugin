local instances = require "../types"

local External = require "../../External"

local STAGE_ORDER = table.freeze {
	"self",
	"descendants",
	"properties",
	"ancestor",
	"observer",
	"last",
}

local function sortKeys(a: instances.SpecialKey, b: instances.SpecialKey)
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
