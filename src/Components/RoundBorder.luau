local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local function Corners(
	scope: ConFusion.Scope,
	props: {
		roundness: ConFusion.UsedAs<UDim>?,
		color: ConFusion.UsedAs<Color3>?,
		thickness: number?,
	}
)
	local thickness = props.thickness or 1

	return {
		corner = scope:New "UICorner" {
			CornerRadius = props.roundness or Theme.Roundness,
		},
		border = if thickness > 0
			then scope:New "UIStroke" {
				Color = props.color,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = thickness,
			}
			else nil,
	}
end

return Corners
