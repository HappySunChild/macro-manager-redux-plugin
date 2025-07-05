--!nocheck
local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"
local TextService = game:GetService "TextService"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local OnEvent, Children = Fusion.OnEvent, Fusion.Children

local Foreground = Color3.fromRGB(245, 247, 234)
local ActiveForeground = Color3.fromRGB(225, 86, 63)
local Background = Color3.fromRGB(45, 48, 50)

local TooltipInfo = TweenInfo.new(0.2, Enum.EasingStyle.Exponential)

local function HotbarSlot(
	scope: Fusion.Scope,
	props: {
		Item: Tool,
		Index: number,
		Callback: () -> (),
		Cleanup: () -> (),
	}
)
	local slotScope = scope:innerScope()

	local currentBackpack = Players.LocalPlayer.Backpack

	local tool = props.Item :: Tool
	local index = props.Index
	local callback = props.Callback

	local toolName = slotScope:Value(tool.Name)
	local toolParent = slotScope:Value(tool.Parent)
	local toolTip = slotScope:Value(tool.ToolTip)
	local toolIcon = slotScope:Value(tool.TextureId)

	toolName:bindToInstanceProperty(tool, "Name")
	toolParent:bindToInstanceProperty(tool, "Parent")
	toolTip:bindToInstanceProperty(tool, "ToolTip")
	toolIcon:bindToInstanceProperty(tool, "TextureId")

	local isStartup = slotScope:Value(true)
	local isHovering = slotScope:Value(false)

	local isHeld = slotScope:Computed(function(use)
		return use(toolParent) ~= currentBackpack
	end)

	local toolTipWidth = slotScope:Computed(function(use)
		if not use(isHovering) then
			return 0
		end

		local bounds = TextService:GetTextSize(
			use(toolTip),
			14,
			Enum.Font.SourceSans,
			Vector2.new(math.huge, 16)
		)

		return bounds.X + 4
	end)

	local slotSize = slotScope:Computed(function(use)
		if use(isStartup) then
			return 0.5
		end

		if use(isHovering) or use(isHeld) then
			return 1.1
		end

		return 1
	end)

	return slotScope:New "TextButton" {
		Size = slotScope:Spring(
			slotScope:Computed(function(use)
				local size = use(slotSize)

				return UDim2.fromScale(size, size)
			end),
			30,
			1
		),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,

		LayoutOrder = index,

		BackgroundColor3 = Background,
		BackgroundTransparency = 0.4,

		Text = slotScope:Computed(function(use)
			if use(toolIcon) ~= "" then
				return ""
			end

			local text = use(toolName)

			return text
		end),
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextColor3 = Foreground,

		[OnEvent "InputBegan"] = function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if callback then
					callback(index)
				end
			end
		end,
		[OnEvent "MouseEnter"] = function()
			isHovering:set(true)
		end,
		[OnEvent "MouseLeave"] = function()
			isHovering:set(false)
		end,

		[Fusion.OnRemoval] = {
			slotScope,
			props.Cleanup,
		},
		[Fusion.OnStartup] = function()
			isStartup:set(false)
		end,

		[Children] = {
			Stroke = slotScope:New "UIStroke" {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 1,
				Color = scope:Computed(function(use)
					return if use(isHeld) then ActiveForeground else Foreground
				end),
			},
			Round = slotScope:New "UICorner" {
				CornerRadius = UDim.new(0, 2),
			},

			IconImage = slotScope:Computed(function(use)
				local icon = use(toolIcon)

				if icon ~= "" then
					return slotScope:New "ImageLabel" {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.8, 0.8),

						BackgroundTransparency = 1,
						Image = icon,
					}
				end

				return
			end),
			ToolTip = slotScope:New "TextLabel" {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 0, -5),
				Size = slotScope:Tween(
					slotScope:Computed(function(use)
						return UDim2.fromOffset(use(toolTipWidth), 16)
					end),
					TooltipInfo
				),

				Text = toolTip,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				TextColor3 = Foreground,

				ClipsDescendants = true,

				BackgroundTransparency = 0.5,
				BackgroundColor3 = Background,
			},
			IndexLabel = slotScope:New "TextLabel" {
				Size = UDim2.fromOffset(10, 10),
				BackgroundTransparency = 1,

				Text = tostring(index % 10),
				TextColor3 = Foreground,
				ZIndex = 10,
			},
		},
	}
end

return HotbarSlot
