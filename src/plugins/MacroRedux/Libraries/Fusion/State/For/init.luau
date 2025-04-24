local package = script.Parent.Parent

local Types = require(package.Types)

local destructor = require(package.Memory.destructor)

local Disassembly = require(package.State.For.Disassembly)
local ForTypes = require(package.State.For.ForTypes)
local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local depend = require(package.Graph.depend)

type Self<S, IK, IV, OK, OV> = Types.For<OK, OV> & {
	_disassembly: ForTypes.Disassembly<S, IK, IV, OK, OV>,
}

local class = {
	type = "For",
	kind = "state",
	timeliness = "lazy",
}

local METATABLE = table.freeze { __index = class }

local function For<S, IK, IV, OK, OV>(
	scope: Types.Scope<S>,
	input: Types.UsedAs<{ [IK]: IV }>,
	constructor: (
		Types.Scope<S>,
		initialKey: IK,
		initialValue: IV
	) -> ForTypes.SubObject<S, IK, IV, OK, OV>
): Types.For<OK, OV>
	local newFor = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = {},

		_using = {},
		_users = {},

		_disassembly = Disassembly(scope, input, constructor),
	}, METATABLE)

	table.insert(scope, destructor(newFor))

	return newFor
end

function class._evaluate<S, IK, IV, OK, OV>(self: Self<S, IK, IV, OK, OV>)
	if self.scope == nil then
		return false
	end

	local output = self._internalValue
	local disassembly = self._disassembly

	depend(self, disassembly)

	table.clear(output)

	disassembly:populate(function(target)
		if castToState(target) then
			depend(self, target)
		end

		return peek(target)
	end, output)

	return true
end

table.freeze(class)

return For
