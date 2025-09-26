local ConFusion = require "@packages/ConFusion"

local ElementGroup = require "@components/ElementGroup"
local PickerDisplay = require "../PickerDisplay"
local TextEntry = require "@components/TextEntry"

local peek = ConFusion.peek
local Children = ConFusion.Children

local HSV_FIELD_LIMITS = table.freeze { 360, 100, 100 }

local function HSV(
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

	local hueFieldRef = inner:Value()
	local satFieldref = inner:Value()
	local valFieldRef = inner:Value()

	local function getInputValue()
		local hueField = peek(hueFieldRef) :: TextBox
		local satField = peek(satFieldref) :: TextBox
		local valField = peek(valFieldRef) :: TextBox

		local hue = tonumber(hueField.Text) or 0
		local sat = tonumber(satField.Text) or 0
		local val = tonumber(valField.Text) or 0

		return Color3.fromHSV(
			math.clamp(hue / HSV_FIELD_LIMITS[1], 0, 1),
			math.clamp(sat / HSV_FIELD_LIMITS[2], 0, 1),
			math.clamp(val / HSV_FIELD_LIMITS[3], 0, 1)
		)
	end

	return inner:ElementGroup {
		position = UDim2.fromScale(0.5, 0),
		size = UDim2.fromScale(0.5, 1),

		padding = UDim.new(0, 4),

		labels = { "H", "S", "V" },
		refs = { hueFieldRef, satFieldref, valFieldRef },
		render = function(scope: typeof(inner), index: number, label: string)
			local limit = HSV_FIELD_LIMITS[index]

			return scope:TextEntry {
				size = UDim2.fromScale(1, 1),

				text = inner:Computed(function(use: ConFusion.Use)
					local component =
						select(index, use(props.color):ToHSV()) :: number

					return math.floor(component * limit)
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

return HSV
