local pluginContainer = script.Parent.Parent

local Theme = require(pluginContainer.Utility.Theme)
local Types = require(pluginContainer.Types)

local Fusion = require(pluginContainer.Packages.Fusion)
local t = require(pluginContainer.Packages.t)

local RoundBorder = require(pluginContainer.Components.RoundBorder)

local Children, Ref, OnEvent = Fusion.Children, Fusion.Ref, Fusion.OnEvent
local peek = Fusion.peek

local snapType = t.union(t.integer, t.numberMin(0))
local default = t.default(0, t.number)
local defaultSnap = t.default(0, snapType)

type SliderMacroItem = Types.ValueMacroItem<number> & {
	Minimum: number,
	Maximum: number,
	Snapping: number,
}

local function snap(value: number, resolution: number)
	if resolution <= 0 then
		return value
	end

	return math.round(value * resolution) / resolution
end

local function SliderTick(
	scope: Fusion.Scope,
	props: {
		Alpha: number,
	}
)
	return scope:New "Frame" {
		AnchorPoint = Vector2.new(props.Alpha, 0),
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.fromScale(props.Alpha, 0),

		BackgroundColor3 = Theme.Colors.SliderBorder,
	}
end

local function SliderMacroItem(scope: Fusion.Scope, macroItem: SliderMacroItem)
	macroItem.Minimum = default(macroItem.Minimum)
	macroItem.Maximum = default(macroItem.Maximum)
	macroItem.Snapping = defaultSnap(macroItem.Snapping)
	macroItem.Value = math.clamp(
		default(macroItem.Value),
		macroItem.Minimum,
		macroItem.Maximum
	)

	local inner =
		scope:innerScope { RoundBorder = RoundBorder, SliderTick = SliderTick }
	local displayText =
		inner:Value(macroItem.Text or macroItem.Name or "Slider")
	local valueState = inner:Value(macroItem.Value)

	local minimumState = inner:Value(macroItem.Minimum)
	local maximumState = inner:Value(macroItem.Maximum)
	local snappingState = inner:Value(macroItem.Snapping)

	local alphaState = inner:Computed(function(use: Types.Use)
		local min = use(minimumState) :: number
		local max = use(maximumState) :: number
		local current = use(valueState) :: number

		return snap((current - min) / (max - min), use(snappingState))
	end)

	-- messy...
	macroItem.Value =
		math.lerp(macroItem.Minimum, macroItem.Maximum, peek(alphaState))

	valueState:set(macroItem.Value)

	local isDraggingState = inner:Value(false)
	local barRef = inner:Value()

	local function setInternalValue(newValue: number)
		local oldValue = macroItem.Value
		macroItem.Value = newValue

		valueState:set(newValue)

		if type(macroItem.Changed) == "function" then
			macroItem:Changed(newValue, oldValue)
		end
	end

	function macroItem:UpdateText(newText: string)
		assert(t.string(newText))

		macroItem.Text = newText

		displayText:set(newText)
	end

	function macroItem:SetValue(newValue: number)
		assert(t.number(newValue))

		setInternalValue(newValue)
	end

	function macroItem:SetMaximum(newMax: number)
		assert(t.number(newMax))

		macroItem.Maximum = newMax

		maximumState:set(newMax)
	end

	function macroItem:SetMinumim(newMin: number)
		assert(t.number(newMin))

		macroItem.Minimum = newMin

		minimumState:set(newMin)
	end

	function macroItem:SetSnapping(newSnap: number)
		assert(snapType(newSnap))

		macroItem.Snapping = newSnap

		snappingState:set(newSnap)
	end

	macroItem.Set = macroItem.SetValue

	local snapTicks = inner:Computed(
		function(use: Fusion.Use, scope: typeof(inner))
			local snapping = math.floor(use(snappingState))

			if snapping < 2 then
				return
			end

			local ticks = {}

			for i = 1, snapping - 1 do
				table.insert(ticks, scope:SliderTick { Alpha = i / snapping })
			end

			return ticks
		end
	)

	local lastAlpha = peek(alphaState)

	return inner:New "Frame" {
		Size = UDim2.new(1, 0, 0, 40),

		BackgroundTransparency = 1,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},

			Label = inner:New "TextLabel" {
				Size = UDim2.fromOffset(0, 16),
				AutomaticSize = Enum.AutomaticSize.X,

				BackgroundTransparency = 1,

				Text = inner:Computed(function(use: Types.Use)
					return string.format(
						"%s: %.1f",
						use(displayText),
						use(valueState)
					)
				end),
				TextColor3 = Theme.Colors.BrightText,
				TextSize = 16,
				FontFace = Theme.Font,
			},
			Slider = inner:New "Frame" {
				Position = UDim2.fromOffset(0, 18),
				Size = UDim2.new(1, 0, 0, 16),

				BackgroundTransparency = 1,

				[OnEvent "InputBegan"] = function(input: InputObject)
					if
						input.UserInputType ~= Enum.UserInputType.MouseButton1
					then
						return
					end

					isDraggingState:set(true)
				end,
				[OnEvent "InputEnded"] = function(input: InputObject)
					if
						input.UserInputType ~= Enum.UserInputType.MouseButton1
					then
						return
					end

					isDraggingState:set(false)
				end,
				[OnEvent "InputChanged"] = function(input: InputObject)
					if not peek(isDraggingState) then
						return
					end

					if
						input.UserInputType ~= Enum.UserInputType.MouseMovement
					then
						return
					end

					local bar = peek(barRef) :: Frame

					if not bar then
						return
					end

					local newAlpha = math.clamp(
						(input.Position.X - bar.AbsolutePosition.X)
							/ bar.AbsoluteSize.X,
						0,
						1
					)

					newAlpha = snap(newAlpha, macroItem.Snapping)

					if newAlpha == lastAlpha then
						return
					end

					local newValue = math.lerp(
						macroItem.Minimum,
						macroItem.Maximum,
						newAlpha
					)

					setInternalValue(newValue)

					lastAlpha = newAlpha
				end,

				[Children] = {
					MinimumLabel = inner:New "TextLabel" {
						Size = UDim2.new(0, 35, 1, 0),

						BackgroundTransparency = 1,

						Text = inner:Computed(function(use: Fusion.Use)
							return string.format("%.1f", use(minimumState))
						end),
						TextSize = 16,
						TextColor3 = Theme.Colors.DimmedText,
						FontFace = Theme.Font,
					},
					MaximumLabel = inner:New "TextLabel" {
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.fromScale(1, 0),
						Size = UDim2.new(0, 35, 1, 0),

						BackgroundTransparency = 1,

						Text = inner:Computed(function(use: Fusion.Use)
							return string.format("%.1f", use(maximumState))
						end),
						TextSize = 16,
						TextColor3 = Theme.Colors.DimmedText,
						FontFace = Theme.Font,
					},
					Bar = inner:New "Frame" {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, -70, 0, 4),

						BackgroundColor3 = Theme.Colors.SliderBarBackground,

						[Ref] = barRef,
						[Children] = {
							Border = inner:RoundBorder {
								Color = Theme.Colors.SliderBorder,
							},

							Ticks = snapTicks,
							Handle = inner:New "Frame" {
								AnchorPoint = Vector2.new(0.5, 0.5),
								Size = UDim2.fromOffset(4, 16),
								Position = inner:Computed(
									function(use: Fusion.Use)
										return UDim2.fromScale(
											use(alphaState),
											0.5
										)
									end
								),

								ZIndex = 10,

								BackgroundColor3 = Theme.Colors.SliderHandleBackground,
								[Children] = {
									Border = inner:RoundBorder {
										Color = Theme.Colors.SliderBorder,
									},
								},
							},
						},
					},
				},
			},
		},
	}
end

return SliderMacroItem
