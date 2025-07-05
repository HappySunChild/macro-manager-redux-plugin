--!strict
local Types = require "../Types"

local merge = require "../Utility/merge"

local function deriveScope<S>(
	existing: Types.Scope<S>,
	methods: { [unknown]: unknown }?
): unknown
	-- the plague !strict has brought upon me
	-- why? why must I bring unnecessary pain upon myself?
	local metatable = getmetatable(existing :: any)

	if methods ~= nil then
		metatable = table.clone(metatable) :: { [unknown]: unknown }
		metatable.__index = merge(true, {}, metatable.__index, merge(false, {}, methods))
	end

	return setmetatable({}, metatable)
end

return deriveScope :: <T, M>(existing: T, methods: M?) -> T & M
