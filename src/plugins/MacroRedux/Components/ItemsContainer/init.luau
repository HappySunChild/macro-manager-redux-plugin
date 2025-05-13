local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Theme = require(pluginContainer.Utility.Theme)
local merge = require(pluginContainer.Utility.merge)

local Fusion = require(pluginContainer.Packages.Fusion)
local Children = Fusion.Children

local Item = require(script.Item)
local RoundBorder = require(pluginContainer.Components.RoundBorder)

local function ItemsContainer(
	scope: Fusion.Scope,
	props: {
		Items: { Types.MacroItem },
		ItemProperties: { [string]: any }?,

		Position: Fusion.UsedAs<UDim2>?,
		Size: Fusion.UsedAs<UDim2>?,
		BackgroundColor: Fusion.UsedAs<Color3>?,
		BackgroundTransparency: Fusion.UsedAs<number>?,
		Visible: Fusion.UsedAs<boolean>?,
	}
)
	if props.Items == nil or #props.Items == 0 then
		return
	end

	local inner = scope:innerScope { Item = Item, RoundBorder = RoundBorder }
	local items = {}

	-- items are not dynamic, i don't plan on changing this
	-- it is definitely possible but there really is no need
	-- unless i feel like adding an :AddItem method to Section
	for ind, macroItem in props.Items do
		macroItem.Order = macroItem.Order or ind

		if props.ItemProperties then
			merge(macroItem, props.ItemProperties)
		end

		local itemContents = inner:Item(macroItem)

		if not itemContents then
			continue
		end

		table.insert(items, itemContents)
	end

	return inner:New "Frame" {
		Position = props.Position,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundColor3 = props.BackgroundColor or Theme.Colors.ItemBackground,
		BackgroundTransparency = props.BackgroundTransparency,
		-- ClipsDescendants = true,
		Visible = props.Visible,

		[Children] = {
			Layout = inner:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			Padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
			},

			RoundBorder = inner:RoundBorder { Thickness = 0 },

			Items = items,
		},
	}
end

return ItemsContainer
