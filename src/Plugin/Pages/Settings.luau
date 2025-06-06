local Fusion = require "@packages/Fusion"

local TextButton = require "@components/TextButton"

local function SettingsPage(
	scope: Fusion.Scope,
	props: { navigate: (string) -> () }
)
	local navigate = props.navigate
	local inner = scope:innerScope { TextButton = TextButton }

	return inner:TextButton {
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.fromOffset(100, 20),

		Text = "Back",
		TextSize = 16,

		Callback = function()
			navigate "Macros"
		end,
	}
end

return SettingsPage
