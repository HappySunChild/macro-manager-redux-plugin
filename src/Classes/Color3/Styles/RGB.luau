local ConFusion = require "@packages/ConFusion"

local ElementGroup = require "@components/ElementGroup"
local PickerDisplay = require "../PickerDisplay"
local TextEntry = require "@components/TextEntry"

local peek = ConFusion.peek
local Children = ConFusion.Children

local function RGB(
	scope: ConFusion.Scope,
	props: {
		color: ConFusion.UsedAs<Color3>,
		setColor: (Color3) -> (),
	}
)
	local inner = scope:innerScope {
		PickerDisplay = PickerDisplay,
		ElementGroup = ElementGroup,
		TextEntry = TextEntry,
	}

	local redFieldRef = inner:Value()
	local greenFieldRef = inner:Value()
	local blueFieldRef = inner:Value()

	local function getInputValue()
		local redField = peek(redFieldRef) :: TextBox
		local greenField = peek(greenFieldRef) :: TextBox
		local blueField = peek(blueFieldRef) :: TextBox

		return Color3.fromRGB(
			tonumber(redField.Text) or 0,
			tonumber(greenField.Text) or 0,
			tonumber(blueField.Text) or 0
		)
	end

	return inner:ElementGroup {
		position = UDim2.fromScale(0.5, 0),
		size = UDim2.fromScale(0.5, 1),

		padding = UDim.new(0, 4),

		labels = { "R", "G", "B" },
		refs = { redFieldRef, greenFieldRef, blueFieldRef },
		render = function(scope: typeof(inner), _, label: string)
			return scope:TextEntry {
				size = UDim2.fromScale(1, 1),

				text = inner:Computed(function(use: ConFusion.Use)
					local component = use(props.color)[label] :: number
					return math.floor(component * 255)
				end),
				placeholderText = label,

				callback = function()
					props.setColor(getInputValue())
				end,
			}
		end,

		[Children] = {
			display = inner:PickerDisplay(props),
		},
	}
end

return RGB
