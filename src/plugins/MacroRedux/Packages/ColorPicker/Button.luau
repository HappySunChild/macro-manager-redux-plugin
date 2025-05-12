local pluginContainer = script.Parent.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)

local Fusion = require(pluginContainer.Packages.Fusion)

local OnEvent, Out = Fusion.OnEvent, Fusion.Out

local function Button(
	scope: Fusion.Scope,
	props: {
		Position: UDim2,
		Size: UDim2,

		Text: string,
		Callback: () -> (),
	}
)
	local inner = scope:innerScope()
	local state = scope:Value(Enum.GuiState.Idle)
	local color = scope:Computed(function(use: Fusion.Use)
		local currentState = use(state)

		if currentState == Enum.GuiState.Hover then
			return use(Theme.Colors.ButtonHover)
		elseif currentState == Enum.GuiState.Press then
			return use(Theme.Colors.ButtonPressed)
		end

		return use(Theme.Colors.ButtonBackground)
	end)

	return inner:New "TextButton" {
		Position = props.Position,
		Size = props.Size,

		BackgroundColor3 = color,
		BorderColor3 = Theme.Colors.ButtonBorder,
		BorderSizePixel = 1,

		Text = props.Text,
		TextColor3 = Theme.Colors.ButtonText,
		TextSize = 16,

		[Out "GuiState"] = state,
		[OnEvent "MouseButton1Click"] = function()
			props.Callback()
		end,
	}
end

return Button
