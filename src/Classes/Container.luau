local Types = require "@plugin/Types"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local Label = require "@components/Label"

local peek = ConFusion.peek
local Children, Ref = ConFusion.Children, ConFusion.Ref

local function ContainerMacroItem(
	scope: ConFusion.Scope,
	macroItem: Types.MacroItem
)
	local inner = scope:innerScope { Label = Label }
	local displayText = inner:Value(macroItem.Text or "Container")
	local containerRef = inner:Value()

	function macroItem:SetText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	function macroItem:Insert(object: Instance)
		assert(t.Instance(object))

		object.Parent = peek(containerRef)
	end

	function macroItem:Clear()
		local container = peek(containerRef) :: Frame?

		if not container then
			return
		end

		container:ClearAllChildren()
	end

	function macroItem:GetContainer()
		return peek(containerRef)
	end

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundTransparency = 1,

		[Children] = {
			padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},

			label = inner:Label {
				text = displayText,
				size = UDim2.new(0.5, 0, 0, 24),
			},
			container = inner:New "Frame" {
				Position = UDim2.fromOffset(0, 24),
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				BackgroundTransparency = 1,

				[Ref] = containerRef,
			},
		},
	}
end

return ContainerMacroItem
