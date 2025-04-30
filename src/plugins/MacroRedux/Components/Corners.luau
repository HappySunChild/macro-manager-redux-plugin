local pluginContainer = script.Parent.Parent

local Fusion = require(pluginContainer.Packages.Fusion)

local function Corners(
	scope: Fusion.Scope,
	props: {
		Color: Fusion.UsedAs<Color3>,
		Roundness: Fusion.UsedAs<UDim>?,
	}
)
	return {
		Corner = scope:New "UICorner" {
			CornerRadius = props.Roundness or UDim.new(0, 4),
		},
		Border = scope:New "UIStroke" {
			Color = props.Color,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		},
	}
end

return Corners
