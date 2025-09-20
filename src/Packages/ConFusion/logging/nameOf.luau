local nicknames = require "./nicknames"

local function nameOf(x: unknown, default: string)
	local nickname = nicknames[x]

	if type(nickname) == "string" then
		return nickname
	end

	if type(x) == "table" then
		x = x :: { [any]: any }

		if type(x.name) == "string" then
			return x.name
		elseif type(x.type) == "string" then
			return x.type
		elseif type(x.kind) == "string" then
			return x.kind
		end
	end

	return default
end

return nameOf
