local Types = require "@plugin/Types"

local ConFusion = require "@packages/ConFusion"

local MacroManager = require "@utility/MacroManager"
local Theme = require "@utility/Theme"

local ElementGroup = require "@components/ElementGroup"
local MacroContainer = require "@components/MacroContainer"
local RoundBorder = require "@components/RoundBorder"
local TextButton = require "@components/TextButton"

local Children = ConFusion.Children

local TOPBAR_HEIGHT = 24

local function MacrosPage(
	scope: ConFusion.Scope,
	props: {
		macros: ConFusion.UsedAs<{ Types.Macro }>,
	}
)
	local inner = scope:innerScope {
		MacroContainer = MacroContainer,
		TextButton = TextButton,
		ElementGroup = ElementGroup,
		RoundBorder = RoundBorder,
	}

	return {
		Padding = inner:New "UIPadding" {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		},
		Topbar = inner:New "Frame" {
			Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT),

			BackgroundColor3 = Theme.Color.Macro.Background,

			[Children] = {
				Padding = inner:New "UIPadding" {
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
					PaddingLeft = UDim.new(0, 2),
					PaddingRight = UDim.new(0, 2),
				},
				RoundBorder = inner:RoundBorder { Thickness = 0 },

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
							Size = UDim2.new(0, 60, 1, 0),

							Text = "Refresh",
							TextSize = 16,

							Callback = function()
								MacroManager:RefreshMacros()
							end,
						},
					},
				},
			},
		},
		Container = inner:New "Frame" {
			Size = UDim2.new(1, 0, 1, -TOPBAR_HEIGHT),
			Position = UDim2.new(0, 0, 0, TOPBAR_HEIGHT + 2),

			BackgroundTransparency = 1,

			[Children] = inner:MacroContainer { Macros = props.macros },
		},
	}
end

return MacrosPage
