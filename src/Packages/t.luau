local function swap_values_keys(tab: { [any]: any })
	local swapped = {}

	for k, v in tab do
		swapped[v] = k
	end

	return swapped
end

type CheckCallback = (value: any?) -> (boolean, string?)

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

t.any = function(value: any?)
	if value ~= nil then
		return true
	end

	return false, "any expected, got nil"
end

t.nan = function(value: number)
	local numSuccess, numMessage = t.number(value)

	if numSuccess == false then
		return false, numMessage
	end

	if value == value then
		return false, `nan expected, got {value}`
	end

	return true
end
t.number_min = function(minimum: number)
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
t.number_max = function(maximum: number)
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
t.NumberRange = t.typeof "NumberRange"
t.NumberSequence = t.typeof "NumberSequence"
t.NumberSequenceKeypoint = t.typeof "NumberSequenceKeypoint"
t.ColorSequence = t.typeof "ColorSequence"
t.ColorSequenceKeypoint = t.typeof "ColorSequenceKeypoint"

t.InstanceIsA = function(className: string)
	assert(t.string(className))

	return function(value: Instance)
		local success, message = t.Instance(value)

		if success == false then
			return false, message
		end

		if not value:IsA(className) then
			return false, `{className} expected, got {value.ClassName}`
		end

		return true
	end
end

t.with_keys = function(keys: { any })
	assert(t.table(keys))

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
t.with_values = function(values: { any })
	assert(t.table(values))

	return function(tab: { [any]: any })
		local success, message = t.table(tab)

		if success == false then
			return false, message
		end

		local swapped = swap_values_keys(tab)

		for _, value in values do
			if swapped[value] == nil then
				return false,
					`expected value {tostring(value)} to be present in table`
			end
		end

		return true
	end
end
t.struct = function(struct: { [any]: CheckCallback })
	assert(t.table(struct))

	return function(tab: { [any]: any })
		local tabSuccess, tabMessage = t.table(tab)

		if tabSuccess == false then
			return false, tabMessage
		end

		for key, check in struct do
			local value = tab[key]
			local success, message = check(value)

			if success == false then
				return false,
					`invalid value assigned to key {tostring(key)}; {message}`
			end
		end

		return true
	end
end
t.set = function(valid: { any })
	return function(value: any)
		for _, v in valid do
			if value == v then
				return true
			end
		end

		return false, `expected value {tostring(value)} to be in set`
	end
end

t.union = function(...: CheckCallback)
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
t.optional = function(check: CheckCallback)
	assert(t.callback(check))

	return function(value: any?)
		if value == nil then
			return true
		end

		local success, message = check(value)

		if not success then
			return false, `(optional) {message}`
		end

		return true
	end
end
t.negate = function(check: CheckCallback)
	return function(value: any)
		local ok, message = check(value)

		if ok then
			return false, `(not) {message}`
		end

		return true
	end
end
t.literal = function(...: any)
	local count = select("#", ...)

	if count == 1 then
		local literal = ...

		return function(value: any)
			if value ~= literal then
				return false,
					`expected value to exactly equal {tostring(literal)}, got {tostring(
						value
					)}`
			end

			return true
		end
	end

	local literals = {}

	for i = 1, count do
		local literal = select(i, ...)

		literals[i] = t.literal(literal)
	end

	return t.union(unpack(literals))
end

t.default = function<V>(default: V, check: CheckCallback)
	return function(value: any): V
		local ok = check(value)

		if ok then
			return value
		end

		return default
	end
end
t.strict = function(check: CheckCallback)
	return function(...)
		assert(check(...))
	end
end

return t
