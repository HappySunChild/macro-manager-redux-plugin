local package = script.Parent.Parent

local Types = require(package.Types)

local nameOf = require(package.Utility.nameOf)
local nicknames = require(package.Utility.nicknames)

local function destroy<V>(target: Types.GraphObject)
	target.scope = nil
	target._observers = nil

	local using = target._using

	if using then
		for dependency in using do
			dependency._users[target] = nil
			using[dependency] = nil
		end
	end

	local users = target._users

	if users then
		for user in users do
			user._using[target] = nil
			users[user] = nil
		end
	end
end

local function destructor(target: Types.GraphObject)
	local destruct = function()
		destroy(target)
	end

	nicknames[destruct] = nameOf(target, "unknown") .. "-destructor"

	return destruct
end

return destructor
