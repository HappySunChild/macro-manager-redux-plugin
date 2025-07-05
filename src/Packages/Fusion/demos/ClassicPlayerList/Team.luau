local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local Children = Fusion.Children
local map = Fusion.map

local function Team(
	scope: Fusion.Scope,
	props: {
		Name: Fusion.UsedAs<string>,
		Color: Fusion.UsedAs<Color3>,
		Order: number,
	}
)
	local inner = scope:innerScope()

	return inner:New "TextLabel" {
		Name = map(props.Name, function(v)
			return `t_{v}`
		end),

		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = (props.Order - 1) * 2,

		Text = props.Name,
		TextColor3 = Color3.new(1, 1, 1),
		TextStrokeTransparency = 0.75,
		TextXAlignment = Enum.TextXAlignment.Left,

		BackgroundTransparency = 0.5,
		BackgroundColor3 = props.Color,

		[Children] = {
			inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
			},
		},
	}
end

return Team
