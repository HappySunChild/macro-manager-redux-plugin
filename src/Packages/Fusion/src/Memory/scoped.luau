--!strict
local Types = require "../Types"

local merge = require "../Utility/merge"

local function scoped(
	base: Types.Scope<{ [unknown]: unknown }>,
	methods: { [unknown]: unknown }
): unknown
	local metatable = { __index = merge(false, {}, base, methods) }

	return setmetatable({}, metatable)
end

return scoped :: <B, M>(base: B, methods: M) -> B & M
