--!strict

local package = script.Parent.Parent

local Types = require(package.Types)
local xkindof = require(package.Utility.xkindof)

local function castToState<T>(target: Types.UsedAs<T>): Types.StateObject<T>?
	if xkindof(target) == "state" then
		return target
	end

	return nil
end

return castToState
