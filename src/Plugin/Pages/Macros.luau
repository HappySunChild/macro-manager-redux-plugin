local Types = require "@plugin/Types"

local ConFusion = require "@packages/ConFusion"

local MacroManager = require "@utility/MacroManager"
local Theme = require "@utility/Theme"

local ElementGroup = require "@components/ElementGroup"
local MacroContainer = require "@components/MacroContainer"
local RoundBorder = require "@components/RoundBorder"
local TextButton = require "@components/TextButton"
local TextEntry = require "@components/TextEntry"

local Children = ConFusion.Children

local TOPBAR_HEIGHT = 24

local function MacrosPage(
	scope: ConFusion.Scope,
	props: {
		macros: ConFusion.UsedAs<{ Types.MacroReference }>,
	}
)
	local inner = scope:innerScope {
		MacroContainer = MacroContainer,
		TextButton = TextButton,
		TextEntry = TextEntry,
		ElementGroup = ElementGroup,
		RoundBorder = RoundBorder,
	}

	local filterAgainst = inner:Value ""

	return {
		padding = inner:New "UIPadding" {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		},

		topbar = inner:New "Frame" {
			Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT),
			BackgroundColor3 = Theme.Color.Macro.Background,

			[Children] = {
				padding = inner:New "UIPadding" {
					PaddingTop = UDim.new(0, 2),
					PaddingBottom = UDim.new(0, 2),
					PaddingLeft = UDim.new(0, 2),
					PaddingRight = UDim.new(0, 2),
				},
				border = inner:RoundBorder { thickness = 0 },

				container = inner:ElementGroup {
					size = UDim2.fromScale(1, 1),
					padding = UDim.new(0, 3),

					[Children] = {
						filter = inner:TextEntry {
							size = UDim2.new(1, -60, 1, 0),

							textSize = 16,
							textXAlignment = Enum.TextXAlignment.Left,
							placeholderText = "Filter...",

							typingCallback = function(text: string)
								filterAgainst:set(text:lower())
							end,

							layoutOrder = 1,
						},
						refresh = inner:TextButton {
							size = UDim2.new(0, 60, 1, 0),

							text = "Refresh",
							textSize = 16,

							callback = function()
								MacroManager.refreshMacros()
							end,

							layoutOrder = 2,
						},
					},
				},
			},
		},
		container = inner:New "Frame" {
			Size = UDim2.new(1, 0, 1, -TOPBAR_HEIGHT),
			Position = UDim2.new(0, 0, 0, TOPBAR_HEIGHT + 2),

			BackgroundTransparency = 1,

			[Children] = inner:MacroContainer {
				filter = filterAgainst,
				macros = props.macros,
			},
		},
	}
end

return MacrosPage
