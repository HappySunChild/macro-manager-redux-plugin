local package = script.Parent.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local stageOrder = table.freeze {
	"self",
	"descendants",
	"properties",
	"ancestor",
	"observer",
}

local function sortKeys(a: Types.SpecialKey, b: Types.SpecialKey)
	local aIndex = table.find(stageOrder, a.stage)
	local bIndex = table.find(stageOrder, b.stage)

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
