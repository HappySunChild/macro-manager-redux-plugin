local ConFusion = require "@packages/ConFusion"

local Theme = require "@utility/Theme"

local OnEvent, Out = ConFusion.OnEvent, ConFusion.Out

local BUTTON_STYLE = Theme.ButtonStyle.Default

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
			return use(BUTTON_STYLE.HoverBackground)
		elseif currentState == Enum.GuiState.Press then
			return use(BUTTON_STYLE.PressedBackground)
		end

		return use(BUTTON_STYLE.Background)
	end)

	return inner:New "TextButton" {
		Position = props.position,
		Size = props.size,

		BackgroundColor3 = color,
		BorderColor3 = BUTTON_STYLE.Border,
		BorderSizePixel = 1,

		Text = props.text,
		TextColor3 = BUTTON_STYLE.Text,
		TextSize = 16,

		[Out "GuiState"] = state,
		[OnEvent "MouseButton1Click"] = props.callback,
	}
end

return Button
