--!strict
local package = script.Parent.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local ForTypes = require(package.State.For.ForTypes)

local deriveScope = require(package.Memory.deriveScope)
local destructor = require(package.Memory.destructor)
local doCleanup = require(package.Memory.doCleanup)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local depend = require(package.Graph.depend)

type Self<S, IK, IV, OK, OV> = ForTypes.Disassembly<S, IK, IV, OK, OV> & {
	_input: Types.UsedAs<{ [IK]: IV }>,
	_objects: { [ForTypes.SubObject<S, IK, IV, OK, OV>]: true },
	_constructor: (
		Types.Scope<S>,
		initialKey: IK,
		initialValue: IV
	) -> ForTypes.SubObject<S, IK, IV, OK, OV>,
}

local class = {
	type = "Disassembly",
	kind = "graph",
	timeliness = "eager",
}

local METATABLE = table.freeze { __index = class }

local function Disassembly<S, IK, IV, OK, OV>(
	scope: Types.Scope,
	input: Types.UsedAs<{ [IK]: IV }>,
	constructor: (
		Types.Scope<S>,
		initialKey: IK,
		initialValue: IV
	) -> ForTypes.SubObject<S, IK, IV, OK, OV>
): ForTypes.Disassembly<S, IK, IV, OK, OV>
	local newDisassembly = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},
		_using = {},

		_input = input,
		_constructor = constructor,
		_objects = {},
	}, METATABLE) :: Self<S, IK, IV, OK, OV>

	table.insert(scope, {
		destructor(newDisassembly),
		function()
			for object in newDisassembly._objects do
				if object.scope ~= nil then
					doCleanup(object.scope)
				end

				object.scope = nil -- i really don't understand
			end
		end,
	})

	return newDisassembly
end

function class.populate<S, IK, IV, OK, OV>(
	self: Self<S, IK, IV, OK, OV>,
	use: Types.Use,
	output: { [OK]: OV? }
)
	local minArrayIndex = math.huge
	local maxArrayIndex = -math.huge
	local hasHoles = false

	for object in self._objects do
		local outputKey, outputValue = object:useOutputPair(use)

		if outputKey == nil or outputValue == nil then
			hasHoles = true
			continue
		elseif output[outputKey] ~= nil then
			External.logErrorNonFatal("forKeyCollision", nil, tostring(outputKey))
			continue
		end

		output[outputKey] = outputValue

		-- TypeError: Type 'nil' could not be converted into 'number'
		-- why did I have to explicity say that outputKey shouldn't be nil to make this type error go away?
		-- even with this completely unnecessary check it still gets resolved as 'never'.
		-- i'm already checking this at line 85, which skips over this if it is nil.

		-- i would really like to know why the type solver believes that this specific variable is still nil, even after multiple checks
		-- and then it has the AUDACITY to give me a 'never'...

		-- when i replaced the continue with a break/return it worked fine, and no type error was shown.
		-- now i don't mean to put down the Luau engineers, most of the time the type solver is amazing,
		-- but simple problems like these actually make me want to throw my monitor out the window

		if type(outputKey) == "number" and outputKey ~= nil then
			minArrayIndex = math.min(minArrayIndex, outputKey)
			maxArrayIndex = math.max(maxArrayIndex, outputKey)
		end
	end

	if hasHoles and maxArrayIndex < minArrayIndex then
		local moveToIndex = minArrayIndex

		for moveFromIndex = minArrayIndex, maxArrayIndex do
			local outputValue = output[moveFromIndex] :: any

			if outputValue == nil then
				continue
			end

			output[moveFromIndex] = nil
			output[moveToIndex] = outputValue
			moveToIndex += 1
		end
	end
end

function class._evaluate<S, IK, IV, OK, OV>(self: Self<S, IK, IV, OK, OV>)
	local outerScope = self.scope

	if castToState(self._input) then
		depend(self, self._input)
	end

	local pendingPairs = table.clone(peek(self._input)) :: { [any]: any }
	local newObjects = {}

	for object in self._objects do
		local reused = false

		-- casting these to unknown because the type solver doesn't know how to handle generics, apparently.
		local oldInputKey = object.inputKey :: unknown
		local oldInputValue = object.inputValue :: unknown

		local newInputKey

		if not object.roamKeys and pendingPairs[oldInputKey] ~= nil then
			reused = true
			newInputKey = oldInputKey
		else
			for pendingKey, pendingValue in pendingPairs do
				reused = true
				newInputKey = pendingKey

				if object.roamValues then
					break
				end

				if pendingValue == oldInputValue then
					break
				end
			end
		end

		if reused then
			local newInputValue = pendingPairs[newInputKey]
			newObjects[object] = true

			if newInputKey ~= oldInputKey then
				object.inputKey = newInputKey
				object:invalidateInputKey()
			end

			if newInputValue ~= oldInputValue then
				object.inputValue = newInputValue
				object:invalidateInputValue()
			end

			pendingPairs[newInputKey] = nil
		else
			if object.scope ~= nil then
				doCleanup(object.scope)
			end

			object.scope = nil
		end
	end

	for pendingKey, pendingValue in pendingPairs do
		local object =
			self._constructor(deriveScope(outerScope), pendingKey, pendingValue)
		newObjects[object] = true
	end

	self._objects = newObjects

	return true
end

table.freeze(class)

return Disassembly
