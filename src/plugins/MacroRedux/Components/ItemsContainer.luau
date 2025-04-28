local pluginContainer = script.Parent.Parent
local ItemClasses = pluginContainer.Classes

local Types = require(pluginContainer.Types)

local MacroManager = require(pluginContainer.Utility.MacroManager)

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local Theme = require(pluginContainer.Components.Theme)

local function getMacroItemClass(name: string)
	local customClass = MacroManager.CustomItemClasses[name]

	if customClass then
		return customClass
	end

	local classModule = ItemClasses:FindFirstChild(name)

	if not classModule then
		return
	end

	return require(classModule) :: any
end

local function Item(scope: Fusion.Scope, macroItem: Types.MacroItem)
	-- TODO: Make this use class components

	local constructor = getMacroItemClass(macroItem.Type)

	if not constructor then
		warn(`Could not find MacroItem class for '{macroItem.Type}'`)

		return
	end

	local itemScope = scope:innerScope()

	local frame
	local success, err = pcall(function()
		frame = constructor(itemScope, macroItem)
	end)

	if not success then
		warn(`Error while adding MacroItem '{macroItem.Type}';\n\t{err}`)
	end

	return frame
end

local function ItemsContainer(
	scope: Fusion.Scope,
	props: { Items: { Types.MacroItem } }
)
	if props.Items == nil or #props.Items == 0 then
		return
	end

	local inner = scope:innerScope { Item = Item }

	local items = {}

	for ind, macroItem in props.Items do
		local frame = inner:Item(macroItem)

		if not frame then
			continue
		end

		macroItem.Order = macroItem.Order or ind

		table.insert(items, frame)
	end

	return scope:New "Frame" {
		Position = UDim2.fromOffset(0, 18),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundColor3 = Theme.Colors.ItemContainerBackground,

		[Children] = {
			Layout = inner:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				-- Padding = UDim.new(0, 0),
			},

			Items = items,
		},
	}
end

return ItemsContainer
