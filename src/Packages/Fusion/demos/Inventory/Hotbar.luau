local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local Children = Fusion.Children
local HotbarSlot = require(script.Parent.HotbarSlot)

local function Hotbar(
	scope: Fusion.Scope,
	props: {
		Items: { [number]: Tool },
		Height: number,
		Padding: number,
		EquipCallback: () -> (),
	}
)
	local hotbarScope = scope:innerScope {
		HotbarSlot = HotbarSlot,
	}

	local slots = hotbarScope:ForPairs(props.Items, function(_, inner, index, tool: Tool)
		local slot = inner:HotbarSlot {
			Item = tool,
			Index = index,
			Callback = props.EquipCallback,
		}

		return index, slot
	end)

	local height = props.Height
	local padding = props.Padding

	return hotbarScope:New "Frame" {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -5),
		Size = UDim2.fromOffset(0, height),

		BackgroundTransparency = 1,

		[Children] = {
			List = hotbarScope:New "UIListLayout" {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, padding),
			},

			Slots = slots,
		},
	}
end

return Hotbar
