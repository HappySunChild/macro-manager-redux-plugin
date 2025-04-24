--!strict

local package = script.Parent.Parent

local Types = require(package.Types)
local merge = require(package.Utility.merge)

local function scoped(
	base: Types.Scope<{ [unknown]: unknown }>,
	methods: { [unknown]: unknown }
): unknown
	local metatable = { __index = merge(false, {}, base, methods) }

	return setmetatable({}, metatable)
end

return scoped :: <B, M>(base: B, methods: M) -> B & M
