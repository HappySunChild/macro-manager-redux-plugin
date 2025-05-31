--!strict

local package = script.Parent.Parent

local Types = require(package.Types)
local deriveScope = require(package.Memory.deriveScope)

local function innerScope<T>(
	existing: Types.Scope<T>,
	methods: { [unknown]: unknown }
): unknown
	local inner = deriveScope(existing, methods)

	table.insert(existing, inner)
	table.insert(inner, function()
		local index = table.find(existing, inner)

		if index then
			table.remove(existing, index)
		end
	end)

	return inner
end

return innerScope :: <T, M>(existing: T, methods: M?) -> T & M
