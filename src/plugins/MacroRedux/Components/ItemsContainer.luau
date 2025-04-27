local PluginContainer = script.Parent.Parent

local Types = require(PluginContainer.Types)

local Fusion = require(PluginContainer.Packages.Fusion)
local Children = Fusion.Children

local Theme = require(PluginContainer.Components.Theme)

local function Item(scope: Fusion.Scope, macroItem: Types.MacroItem)
	-- TODO: Make this use class components

	return scope:New "TextLabel" {
		LayoutOrder = macroItem.Order,

		Size = UDim2.new(1, 0, 0, 20),
		Text = macroItem.Type,
	}
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
		macroItem.Order = macroItem.Order or ind

		table.insert(items, inner:Item(macroItem))
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
