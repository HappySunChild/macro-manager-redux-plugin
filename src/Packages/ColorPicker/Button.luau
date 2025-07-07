local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local OnEvent, Out = ConFusion.OnEvent, ConFusion.Out

local function Button(
	scope: ConFusion.Scope,
	props: {
		position: UDim2,
		size: UDim2,

		text: string,
		callback: () -> (),
	}
)
	local inner = scope:innerScope()
	local state = scope:Value(Enum.GuiState.Idle)
	local color = scope:Computed(function(use: ConFusion.Use)
		local currentState = use(state)

		if currentState == Enum.GuiState.Hover then
			return use(Theme.Color.Button.HoverBackground)
		elseif currentState == Enum.GuiState.Press then
			return use(Theme.Color.Button.PressedBackground)
		end

		return use(Theme.Color.Button.Background)
	end)

	return inner:New "TextButton" {
		Position = props.position,
		Size = props.size,

		BackgroundColor3 = color,
		BorderColor3 = Theme.Color.Button.Border,
		BorderSizePixel = 1,

		Text = props.text,
		TextColor3 = Theme.Color.Button.Text,
		TextSize = 16,

		[Out "GuiState"] = state,
		[OnEvent "MouseButton1Click"] = props.callback,
	}
end

return Button
