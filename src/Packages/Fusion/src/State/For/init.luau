local Types = require "../Types"

local destructor = require "../Memory/destructor"

local Disassembly = require "@self/Disassembly"
local ForTypes = require "@self/ForTypes"

local castToState = require "./castToState"
local peek = require "./peek"

local depend = require "../Graph/depend"

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
	}, METATABLE) :: Self<S, IK, IV, OK, OV>

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
