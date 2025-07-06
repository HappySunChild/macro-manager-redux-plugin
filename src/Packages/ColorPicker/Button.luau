local ConFusion = require "@packages/ConFusion"
local Theme = require "@utility/Theme"

local OnEvent, Out = ConFusion.OnEvent, ConFusion.Out

local function Button(
	scope: ConFusion.Scope,
	props: {
		Position: UDim2,
		Size: UDim2,

		Text: string,
		Callback: () -> (),
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
		Position = props.Position,
		Size = props.Size,

		BackgroundColor3 = color,
		BorderColor3 = Theme.Color.Button.Border,
		BorderSizePixel = 1,

		Text = props.Text,
		TextColor3 = Theme.Color.Button.Text,
		TextSize = 16,

		[Out "GuiState"] = state,
		[OnEvent "MouseButton1Click"] = function()
			props.Callback()
		end,
	}
end

return Button
