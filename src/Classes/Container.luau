local pluginContainer = script.Parent.Parent

local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local Label = require(pluginContainer.Components.Label)

local peek = Fusion.peek
local Children, Ref = Fusion.Children, Fusion.Ref

local function ContainerMacroItem(
	scope: Fusion.Scope,
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
			Padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},
			Label = inner:Label {
				Text = displayText,
				Size = UDim2.new(0.5, 0, 0, 24),
			},

			Contents = inner:New "Frame" {
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
