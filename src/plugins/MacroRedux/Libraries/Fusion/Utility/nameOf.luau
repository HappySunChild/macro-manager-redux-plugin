local package = script.Parent.Parent

local nicknames = require(package.Utility.nicknames)

local function nameOf(value: unknown, default: string)
	local name = default

	local nickname = nicknames[value]

	if typeof(nickname) == "string" then
		name = nickname
	end

	if typeof(value) == "table" then
		name = value.name or value.type or value.kind
	end

	return name
end

return nameOf
