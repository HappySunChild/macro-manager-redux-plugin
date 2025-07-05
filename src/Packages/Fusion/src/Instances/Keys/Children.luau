local External = require "../../External"
local Types = require "../../Types"

local Observer = require "../../Graph/Observer"

local castToState = require "../../State/castToState"
local peek = require "../../State/peek"

local doCleanup = require "../../Memory/doCleanup"

local SpecialKey = require "./SpecialKey"

local Children = SpecialKey "Children" {
	stage = "descendants",
	apply = function(scope: Types.Scope, applyTo: Instance, children: Types.Child?)
		local newChildren, oldChildren = {}, {}
		local newScopes, oldScopes = {}, {}

		local function updateChildren()
			oldChildren, newChildren = newChildren, oldChildren
			oldScopes, newScopes = newScopes, oldScopes

			local function processChild(child: Types.Child, name: string?)
				local childType = typeof(child)

				if childType == "Instance" then
					newChildren[child] = true

					if not oldChildren[child] then
						if child.Parent == nil then
							child.Parent = applyTo
						end
					else
						oldChildren[child] = nil
					end

					if name and tonumber(name) == nil then
						child.Name = name
					end
				elseif childType == "function" then
					local childInstance = child(applyTo, name)

					if childInstance then
						processChild(childInstance, name)
					end
				elseif castToState(child) then
					local value = peek(child)

					if value ~= nil then
						processChild(value, name)
					end

					local childScope = oldScopes[child]

					if childScope == nil then
						childScope = {}
						Observer(childScope, child):onChange(updateChildren)
					else
						oldScopes[child] = nil
					end

					newScopes[child] = childScope
				elseif childType == "table" then
					for key, subChild in child do
						processChild(subChild, key)
					end
				else
					External.logErrorNonFatal(
						"invalidChildType",
						debug.traceback(nil, 2),
						childType
					)
				end
			end

			if children then
				processChild(children)
			end

			for instance in oldChildren do
				instance.Parent = nil
			end

			table.clear(oldChildren)

			for _, childScope in oldScopes do
				doCleanup(childScope)
			end

			table.clear(oldScopes)
		end

		table.insert(scope, function()
			children = nil

			updateChildren()
		end)

		updateChildren()
	end,
}

return Children
