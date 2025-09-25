local ConFusion = require "@packages/ConFusion"

local peek = ConFusion.peek

local function TheRockWithPancakes(
	scope: ConFusion.Scope,
	props: {
		navigate: (string) -> (),
		active: ConFusion.UsedAs<boolean>,
	}
)
	local navigate = props.navigate

	scope:observe(props.active, function()
		if peek(props.active) then
			task.delay(5, navigate, "Macros")
		end
	end)

	return scope:New "ImageLabel" {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,

		Image = "rbxassetid://465579702",

		BorderSizePixel = 0,
	}
end

return TheRockWithPancakes
