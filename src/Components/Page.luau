local ConFusion = require "@packages/ConFusion"

local Theme = require "@utility/Theme"

local Children = ConFusion.Children

local function Page(
	scope: ConFusion.Scope,
	props: {
		active: ConFusion.UsedAs<boolean>,
		content: ConFusion.Child?,
	}
)
	local inner = scope:innerScope()
	local alpha = inner:Tween(
		inner:Computed(function(use: ConFusion.Use)
			return use(props.active) == true and 1 or 0
		end),
		Theme.TweenInfo.Page
	) :: ConFusion.Animated<number>

	return inner:New "Frame" {
		Position = inner:Computed(function(use: ConFusion.Use)
			local sign = use(props.active) and 1 or -1
			local value = 1 - use(alpha)

			local pos = value * sign

			return UDim2.fromScale(pos, 0)
		end),

		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Children] = {
			fade = inner:New "Frame" {
				Size = UDim2.fromScale(1, 1),
				ZIndex = 100,

				BackgroundColor3 = Theme.Color.MainBackground,
				Transparency = alpha,
			},

			content = props.content,
		},
	}
end

return Page
