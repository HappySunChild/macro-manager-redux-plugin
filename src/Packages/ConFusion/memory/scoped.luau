local memory = require "./types"
local merge = require "./merge"

local function scoped(
	base: memory.Scope<{ [unknown]: unknown }>,
	methods: { [unknown]: unknown }
): unknown
	local metatable = { __index = merge(false, {}, base, methods) }

	return setmetatable({}, metatable)
end

return scoped :: <B, M>(base: B, methods: M) -> B & M
