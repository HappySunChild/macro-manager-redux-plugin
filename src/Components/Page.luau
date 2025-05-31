local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)

local Fusion = require(pluginContainer.Packages.Fusion)

local Children = Fusion.Children

local function Page(
	scope: Fusion.Scope,
	props: {
		active: Fusion.UsedAs<boolean>,
		content: Fusion.Child?,
	}
)
	local inner = scope:innerScope()
	local alpha = inner:Tween(
		inner:Computed(function(use: Fusion.Use)
			return use(props.active) == true and 1 or 0
		end),
		Theme.TweenInfo.Page
	) :: Fusion.Animated<number>

	return inner:New "Frame" {
		Position = inner:Computed(function(use: Fusion.Use)
			local sign = use(props.active) and 1 or -1
			local value = 1 - use(alpha)

			local pos = value * sign

			return UDim2.fromScale(pos, 0)
		end),

		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		[Children] = {
			Fade = inner:New "Frame" {
				Size = UDim2.fromScale(1, 1),
				ZIndex = 100,

				BackgroundColor3 = Theme.Color.MainBackground,
				Transparency = alpha,
			},

			Content = props.content,
		},
	}
end

return Page
