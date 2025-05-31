local Types = require "@plugin/Types"

local Fusion = require "@packages/Fusion"

local ElementGroup = require "@components/ElementGroup"
local MacroContainer = require "@components/MacroContainer"
local TextButton = require "@components/TextButton"

local Children = Fusion.Children

local TOPBAR_HEIGHT = 24

local function MacrosPage(
	scope: Fusion.Scope,
	props: {
		macros: Fusion.UsedAs<{ Types.Macro }>,
		navigate: (string) -> (),
	}
)
	local navigate = props.navigate
	local inner = scope:innerScope {
		MacroContainer = MacroContainer,
		TextButton = TextButton,
		ElementGroup = ElementGroup,
	}

	return {
		Topbar = inner:New "Frame" {
			Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT),

			BackgroundTransparency = 1,

			[Children] = {
				Padding = inner:New "UIPadding" {
					PaddingTop = UDim.new(0, 4),
					PaddingBottom = UDim.new(0, 2),
					PaddingLeft = UDim.new(0, 4),
					PaddingRight = UDim.new(0, 4),
				},
				Elements = inner:ElementGroup {
					Size = UDim2.fromScale(1, 1),

					Padding = UDim.new(0, 3),
					FlexAlignment = Enum.UIFlexAlignment.None,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,

					[Children] = {
						SettingsButton = inner:TextButton {
							Size = UDim2.new(0, 90, 1, 0),

							Text = "Open Settings",
							TextSize = 16,

							Callback = function()
								navigate "Settings"
							end,
						},
						RefreshButton = inner:TextButton {
							Size = UDim2.new(0, 90, 1, 0),

							Text = "Refresh",
							TextSize = 16,

							Callback = function() end,
						},
					},
				},
			},
		},
		Container = inner:New "Frame" {
			Size = UDim2.new(1, 0, 1, -TOPBAR_HEIGHT),
			Position = UDim2.new(0, 0, 0, TOPBAR_HEIGHT),

			BackgroundTransparency = 1,

			[Children] = inner:MacroContainer { Macros = props.macros },
		},
	}
end

return MacrosPage
