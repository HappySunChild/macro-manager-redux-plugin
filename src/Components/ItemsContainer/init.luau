local types = require "@plugin/types"

local ConFusion = require "@packages/ConFusion"

local Theme = require "@utility/Theme"

local Item = require "@self/Item"
local RoundBorder = require "@components/RoundBorder"

local Children = ConFusion.Children

local function ItemsContainer(
	scope: ConFusion.Scope,
	props: {
		items: { types.MacroItem },

		position: ConFusion.UsedAs<UDim2>?,
		size: ConFusion.UsedAs<UDim2>?,
		backgroundColor: ConFusion.UsedAs<Color3>?,
		backgroundTransparency: ConFusion.UsedAs<number>?,
		visible: ConFusion.UsedAs<boolean>?,
	}
)
	if props.items == nil or #props.items == 0 then
		return
	end

	local inner = scope:innerScope { Item = Item, RoundBorder = RoundBorder }
	local items = {}

	-- items are not dynamic, i don't plan on changing this
	-- it is definitely possible but there really is no need
	-- unless i feel like adding an :AddItem method to Section
	for ind, macroItem in props.items do
		macroItem.Order = macroItem.Order or ind

		local itemContents = inner:Item(macroItem)

		if not itemContents then
			continue
		end

		table.insert(items, itemContents)
	end

	return inner:New "Frame" {
		Position = props.position,
		Size = props.size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundColor3 = props.backgroundColor or Theme.Color.Item.Background,
		BackgroundTransparency = props.backgroundTransparency,
		-- ClipsDescendants = true,
		Visible = props.visible,

		[Children] = {
			layout = inner:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
			},
			border = inner:RoundBorder { thickness = 0 },

			items = items,
		},
	}
end

return ItemsContainer
