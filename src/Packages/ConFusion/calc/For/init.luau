local calc = require "./types"
local memory = require "../memory/types"
local fort = require "@self/types"

local destructor = require "../memory/destructor"

local Disassembly = require "@self/Disassembly"

local castToState = require "./castToState"
local peek = require "../use/peek"

local depend = require "../graph/depend"

type Self<S, IK, IV, OK, OV> = calc.For<OK, OV> & {
	_disassembly: fort.Disassembly<S, IK, IV, OK, OV>,
}

local class = table.freeze {
	type = "For",
	kind = "state",
	timeliness = "lazy",

	_evaluate = function<S, IK, IV, OK, OV>(self: Self<S, IK, IV, OK, OV>)
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
	end,
}
local METATABLE = table.freeze { __index = class }

local function For<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	input: calc.UsedAs<{ [IK]: IV }>,
	constructor: (
		memory.Scope<S>,
		initialKey: IK,
		initialValue: IV
	) -> fort.SubObject<S, IK, IV, OK, OV>
): calc.For<OK, OV>
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

return For
