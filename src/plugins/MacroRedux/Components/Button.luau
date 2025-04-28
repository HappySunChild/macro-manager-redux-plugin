local pluginContainer = script.Parent.Parent

local Fusion = require(pluginContainer.Packages.Fusion)
local OnEvent, Out = Fusion.OnEvent, Fusion.Out

local Theme = require(pluginContainer.Components.Theme)

local function Button(
	scope: Fusion.Scope,
	props: {
		AnchorPoint: Fusion.UsedAs<Vector2>?,
		Size: Fusion.UsedAs<UDim2>?,
		SizeConstraint: Fusion.UsedAs<Enum.SizeConstraint>?,
		Position: Fusion.UsedAs<UDim2>?,

		Text: Fusion.UsedAs<string>?,
		TextSize: Fusion.UsedAs<number>?,
		Callback: () -> (),
	}
)
	local state = scope:Value(Enum.GuiState.Idle)
	local color = scope:Computed(function(use)
		local current = use(state) :: Enum.GuiState

		if current == Enum.GuiState.Hover then
			return use(Theme.Colors.ButtonHover)
		elseif current == Enum.GuiState.Press then
			return use(Theme.Colors.ButtonPress)
		end

		return use(Theme.Colors.Button)
	end)

	return scope:New "TextButton" {
		AnchorPoint = props.AnchorPoint,
		Size = props.Size,
		SizeConstraint = props.SizeConstraint,
		Position = props.Position,

		Text = props.Text,
		TextSize = props.TextSize,
		TextColor3 = Theme.Colors.ButtonText,
		FontFace = Theme.Font,

		AutoButtonColor = false,
		BackgroundColor3 = color,
		BorderColor3 = Theme.Colors.ButtonBorder,
		BorderSizePixel = 1,

		[Out "GuiState"] = state,
		[OnEvent "MouseButton1Click"] = function()
			props.Callback()
		end,
	}
end

return Button
