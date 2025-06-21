local Fusion = require "@packages/Fusion"
local Theme = require "@utility/Theme"

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
