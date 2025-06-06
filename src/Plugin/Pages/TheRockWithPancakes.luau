local Fusion = require "@packages/Fusion"

local peek = Fusion.peek
local observe = Fusion.observe

local function TheRockWithPancakes(
	scope: Fusion.Scope,
	props: {
		navigate: (string) -> (),
		active: Fusion.UsedAs<boolean>,
	}
)
	local navigate = props.navigate

	observe(props.active, function()
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
