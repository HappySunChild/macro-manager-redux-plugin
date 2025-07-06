local Types = require "@plugin/Types"

local Theme = require "@utility/Theme"
local updateItemValue = require "@utility/updateItemValue"

local Assets = require "@plugin/Assets"

local ConFusion = require "@packages/ConFusion"
local t = require "@packages/t"

local Label = require "@components/Label"
local RoundBorder = require "@components/RoundBorder"
local ScrollingFrame = require "@components/ScrollingFrame"
local TextButton = require "@components/TextButton"

local Children = ConFusion.Children
local OnEvent, Out = ConFusion.OnEvent, ConFusion.Out
local peek = ConFusion.peek

local default = t.default({ "Default" }, t.table)
local tostring = function(value: any)
	if typeof(value) == "EnumItem" then
		return `(Enum) {value.Name}`
	elseif typeof(value) == "Instance" then
		return `(Instance) {value.Name}`
	end

	return tostring(value)
end

type DropdownMacroItem = {
	Items: { any },
} & Types.ValueMacroItem<any>

local function ItemButton(
	scope: ConFusion.Scope,
	props: { Index: number, Text: string, Callback: () -> () }
)
	local baseColor = if props.Index % 2 == 0
		then Theme.Color.DropdownItem.Background
		else Theme.Color.DropdownItem.BackgroundAlt

	local state = scope:Value(Enum.GuiState.Idle)
	local color = scope:Computed(function(use: ConFusion.Scope)
		local currentState = use(state)
		-- local outputColor = use(baseColor)

		if currentState == Enum.GuiState.Hover then
			-- outputColor = outputColor:Lerp(Color3.new(0, 0, 0), 0.3)
			return use(Theme.Color.Button.HoverBackground)
		elseif currentState == Enum.GuiState.Press then
			return use(Theme.Color.Button.PressedBackground)
		end

		return use(baseColor)
	end)

	return scope:New "TextButton" {
		Size = UDim2.new(1, 0, 0, 18),
		LayoutOrder = props.Index,
		ZIndex = 110,

		BackgroundColor3 = color,

		Text = props.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.Color.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		FontFace = Theme.Font.Regular,

		[OnEvent "MouseButton1Click"] = props.Callback,
		[Out "GuiState"] = state,
		[Children] = {
			Padding = scope:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},
		},
	}
end

local function Dropdown(
	scope: ConFusion.Scope,
	props: {
		Position: UDim2,
		Size: UDim2,

		Value: ConFusion.UsedAs<any>,
		Items: ConFusion.UsedAs<{ any }>,
		SelectedCallback: (any) -> (),
	}
)
	local inner = scope:innerScope {
		TextButton = TextButton,
		ItemButton = ItemButton,
		RoundBorder = RoundBorder,
		ScrollingFrame = ScrollingFrame,
	}

	local open = inner:Value(false)
	local items = inner:ForPairs(
		props.Items,
		function(_, scope: typeof(inner), index: number, value: any)
			return index,
				scope:ItemButton {
					Index = index,
					Text = tostring(value),

					Callback = function()
						open:set(false)
						props.SelectedCallback(value)
					end,
				}
		end
	)

	return inner:New "Frame" {
		Position = props.Position,
		Size = props.Size,

		BackgroundTransparency = 1,

		[Children] = {
			Button = inner:TextButton {
				Size = UDim2.fromScale(1, 1),

				Text = inner:Computed(function(use: ConFusion.Use)
					return tostring(use(props.Value))
				end),
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,

				Callback = function()
					open:set(not peek(open))
				end,
			},
			Arrow = inner:New "ImageLabel" {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -6, 0.5, 0),
				Size = UDim2.fromOffset(8, 8),

				BackgroundTransparency = 1,

				Image = Assets.Images.Dropdown.Arrow,
				ImageColor3 = Theme.Color.Text,

				Rotation = inner:Tween(
					inner:Computed(function(use: ConFusion.Use)
						return if use(open) then 90 else 180
					end),
					Theme.TweenInfo.DropdownRotation
				),
			},
			Items = inner:ScrollingFrame {
				Position = UDim2.new(0, 0, 1, 3),
				Size = inner:Computed(function(use: ConFusion.Use)
					return UDim2.new(
						1,
						0,
						0,
						math.min(#use(props.Items), 8) * 18 + 8
					)
				end),
				ZIndex = 100,

				CanvasSize = UDim2.fromScale(0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,

				BackgroundColor3 = Theme.Color.Button.Background,

				Visible = open,

				[Children] = {
					Border = inner:RoundBorder {
						Color = Theme.Color.Button.Border,
					},
					Padding = inner:New "UIPadding" {
						PaddingTop = UDim.new(0, 4),
						PaddingBottom = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4),
					},
					Layout = inner:New "UIListLayout" {
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0, 0),
					},

					Items = items,
				},
			},
		},
	}
end

local function DropdownMacroItem(
	scope: ConFusion.Scope,
	macroItem: DropdownMacroItem
)
	macroItem.Items = default(macroItem.Items)
	macroItem.Value = if macroItem.Value == nil
		then macroItem.Items[1]
		else macroItem.Value

	local inner = scope:innerScope { Dropdown = Dropdown, Label = Label }
	local displayText = inner:Value(macroItem.Text or "Dropdown")
	local items = inner:Value(macroItem.Items)
	local value = inner:Value(macroItem.Value)

	local function setValueInternal(newValue: any)
		value:set(newValue)

		updateItemValue(macroItem, newValue)
	end

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	function macroItem:SetItems(newItems: { any })
		assert(t.table(newItems))

		macroItem.Items = newItems

		items:set(newItems)
	end

	function macroItem:AddItem(newValue: any)
		assert(t.any(newValue))

		table.insert(macroItem.Items, newValue)

		items:set(macroItem.Items)
	end

	function macroItem:SetValue(newValue: any)
		setValueInternal(newValue)
	end

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 24),

		BackgroundTransparency = 1,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},

			Label = inner:Label {
				Size = UDim2.fromScale(0.5, 1),
				Text = displayText,
			},
			Dropdown = inner:Dropdown {
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.5, 1),

				Items = items,
				Value = value,

				SelectedCallback = setValueInternal,
			},
		},
	}
end

return DropdownMacroItem
