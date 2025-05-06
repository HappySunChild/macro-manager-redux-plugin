local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)

local Fusion = require(pluginContainer.Packages.Fusion)

local function Corners(
	scope: Fusion.Scope,
	props: {
		Roundness: Fusion.UsedAs<UDim>?,
		Color: Fusion.UsedAs<Color3>?,
		Thickness: number?,
	}
)
	local thickness = props.Thickness or 1
	return {
		Corner = scope:New "UICorner" {
			CornerRadius = props.Roundness or Theme.Roundness,
		},
		Border = if thickness > 0
			then scope:New "UIStroke" {
				Color = props.Color,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = thickness,
			}
			else nil,
	}
end

return Corners
