local instances = require "./types"
local memory = require "../memory/types"

local External = require "../External"

local Hydrate = require "./Hydrate"

local function FromTemplate<InstanceT>(
	scope: memory.Scope,
	template: InstanceT
): (props: instances.Properties) -> InstanceT
	template = template :: Instance
	local newInstance = template:Clone()

	if not newInstance then
		External.logError("cannotCreateTemplate", nil, template:GetFullName())
	end

	return Hydrate(scope, template)
end

return FromTemplate
