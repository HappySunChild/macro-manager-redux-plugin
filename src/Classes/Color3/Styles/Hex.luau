local ConFusion = require "@packages/ConFusion"

local ElementGroup = require "@components/ElementGroup"
local PickerDisplay = require "../PickerDisplay"
local TextEntry = require "@components/TextEntry"

local Children = ConFusion.Children

local function Hex(
	scope: ConFusion.Scope,
	props: {
		color: ConFusion.Value<Color3>,
		setColor: (Color3) -> (),
	}
)
	local inner = scope:innerScope {
		PickerDisplay = PickerDisplay,
		ElementGroup = ElementGroup,
		TextEntry = TextEntry,
	}

	local function getInputValue(text: string): Color3
		local value = Color3.new(0, 0, 0)

		pcall(function()
			value = Color3.fromHex(text)
		end)

		return value
	end

	return inner:ElementGroup {
		position = UDim2.fromScale(0.5, 0),
		size = UDim2.fromScale(0.5, 1),

		padding = UDim.new(0, 4),

		[Children] = {
			entry = inner:TextEntry {
				text = inner:Computed(function(use: ConFusion.Use)
					return `#{use(props.color):ToHex()}`
				end),
				placeholderText = "Hex",
				size = UDim2.fromScale(1, 1),

				callback = function(text: string)
					props.setColor(getInputValue(text))
				end,
			},
			display = inner:PickerDisplay(props),
		},
	}
end

return Hex
