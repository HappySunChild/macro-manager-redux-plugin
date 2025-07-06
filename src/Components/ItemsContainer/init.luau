local Types = require "@plugin/Types"

local Theme = require "@utility/Theme"
local merge = require "@utility/merge"

local ConFusion = require "@packages/ConFusion"

local Item = require "@self/Item"
local RoundBorder = require "@components/RoundBorder"

local Children = ConFusion.Children

local function ItemsContainer(
	scope: ConFusion.Scope,
	props: {
		Items: { Types.MacroItem },
		ItemProperties: { [string]: any }?,

		Position: ConFusion.UsedAs<UDim2>?,
		Size: ConFusion.UsedAs<UDim2>?,
		BackgroundColor: ConFusion.UsedAs<Color3>?,
		BackgroundTransparency: ConFusion.UsedAs<number>?,
		Visible: ConFusion.UsedAs<boolean>?,
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

		BackgroundColor3 = props.BackgroundColor or Theme.Color.Item.Background,
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
