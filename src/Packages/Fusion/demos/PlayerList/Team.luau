local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local Children = Fusion.Children

local function Team(
	scope: Fusion.Scope,
	props: {
		Name: Fusion.UsedAs<string>,
		Color: Fusion.UsedAs<Color3>,
		Order: number,
	}
)
	local innerScope = scope:innerScope()

	return innerScope:New "TextLabel" {
		Name = scope:Computed(function(use)
			return "t_" .. use(props.Name)
		end),

		Text = props.Name,
		TextSize = 14,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamMedium,

		LayoutOrder = props.Order * 2,

		BackgroundTransparency = 0.5,
		BackgroundColor3 = props.Color,

		Size = UDim2.new(1, 0, 0, 20),

		[Children] = {
			innerScope:New "UIPadding" {
				PaddingLeft = UDim.new(0, 12),
			},
		},
	}
end

return Team
