local function swap(tab: { [any]: any })
	local swapped = {}

	for k, v in tab do
		swapped[v] = k
	end

	return swapped
end

local t = {}

t.type = function(expected: string)
	return function(value: any): (boolean, string?)
		local valueType = type(value)

		if valueType == expected then
			return true
		end

		return false, `{expected} expected, got {valueType}`
	end
end

t.typeof = function(expected: string)
	return function(value: any): (boolean, string?)
		local valueType = typeof(value)

		if valueType == expected then
			return true
		end

		return false, `{expected} expected, got {valueType}`
	end
end

t.numberMin = function(minimum: number)
	return function(value: number)
		local numSuccess, numMessage = t.number(value)

		if numSuccess == false then
			return false, numMessage
		end

		if value >= minimum then
			return false, `number >= {minimum} expected, got {value}`
		end

		return true
	end
end
t.numberMax = function(maximum: number)
	return function(value: number)
		local numSuccess, numMessage = t.number(value)

		if numSuccess == false then
			return false, numMessage
		end

		if value >= maximum then
			return false, `number <= {maximum} expected, got {value}`
		end

		return true
	end
end

t.any = function(value: any?)
	if value ~= nil then
		return true
	end

	return false, "any expected, got nil"
end
t.integer = function(value: number)
	local success, message = t.number(value)

	if success == false then
		return false, message
	end

	if value % 1 ~= 0 then
		return false, `integer expected, got {value}`
	end

	return true
end

t.boolean = t.type "boolean"
t.string = t.type "string"
t.number = t.type "number"
t.table = t.type "table"
t.userdata = t.type "userdata"
t.none = t.type "nil"

t.callback = t.type "function"
t.thread = t.type "thread"
t.buffer = t.type "buffer"
t.vector = t.type "vector"

t.Instance = t.typeof "Instance"
t.Color3 = t.typeof "Color3"
t.BrickColor = t.typeof "BrickColor"
t.Enums = t.typeof "Enums"
t.Enum = t.typeof "Enum"
t.EnumItem = t.typeof "EnumItem"

t.Vector2 = t.typeof "Vector2"
t.Vector3 = t.typeof "Vector3"

t.withKeys = function(keys: { any })
	return function(tab: { [any]: any })
		local success, message = t.table(tab)

		if success == false then
			return false, message
		end

		for _, key in keys do
			if tab[key] == nil then
				return false,
					`expected {tostring(key)} key in table to be not nil`
			end
		end

		return true
	end
end
t.withValues = function(values: { any })
	return function(tab: { [any]: any })
		local success, message = t.table(tab)

		if success == false then
			return false, message
		end

		local swapped = swap(tab)

		for _, value in values do
			if swapped[value] == nil then
				return false,
					`expected {tostring(value)} value in table to be present`
			end
		end

		return true
	end
end

t.default = function<V>(default: V, check: (any) -> boolean)
	return function(value: any): V
		local ok = check(value)

		if ok then
			return value
		end

		return default
	end
end

t.union = function(...: (any) -> (boolean, string?))
	local checks = { ... }

	return function(value: any)
		local ok, failMessage = false, ""

		for _, callback in checks do
			local success, message = callback(value)

			if success then
				ok = true
			else
				message = message
			end
		end

		return ok, failMessage
	end
end

t.strict = function(check)
	return function(...)
		assert(check(...))
	end
end

return t
