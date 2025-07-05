local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local Children = Fusion.Children

local getDisplayName = require(script.Parent.getDisplayName)

local function Menu(
	scope: Fusion.Scope,
	props: {
		Visible: Fusion.UsedAs<boolean>,
		Position: Fusion.UsedAs<UDim2>,
		Player: Fusion.UsedAs<Player>,
	}
)
	local player = props.Player

	local offset = scope:Computed(function(use)
		if use(props.Visible) then
			return UDim2.fromScale(0, 0)
		end

		return UDim2.fromScale(1, 0)
	end)

	return scope:New "Frame" {
		Size = UDim2.fromOffset(270, 65),
		AnchorPoint = Vector2.new(1, 0),

		Position = props.Position,

		ClipsDescendants = true,
		BackgroundTransparency = 1,

		[Children] = {
			Content = scope:New "Frame" {
				Position = scope:Tween(
					offset,
					TweenInfo.new(
						0.3,
						Enum.EasingStyle.Exponential,
						Enum.EasingDirection.Out
					)
				),
				Size = UDim2.new(1, 0, 0, 65),

				BackgroundColor3 = Color3.fromRGB(22, 23, 26),
				BackgroundTransparency = 0.2,

				[Children] = {
					Round = scope:New "UICorner" {
						CornerRadius = UDim.new(0, 4),
					},

					AvatarImage = scope:New "ImageLabel" {
						Position = UDim2.fromOffset(10, 0),
						Size = UDim2.fromOffset(65, 65),

						BackgroundTransparency = 1,
						Image = scope:Eventual(function(use, become)
							become(
								Players:GetUserThumbnailAsync(
									use(player).UserId,
									Enum.ThumbnailType.HeadShot,
									Enum.ThumbnailSize.Size180x180
								)
							)
						end, ""),
					},

					TextContainer = scope:New "Frame" {
						Position = UDim2.fromOffset(100, 0),
						Size = UDim2.new(1, -100, 1, 0),

						BackgroundTransparency = 1,

						[Children] = {
							DisplayName = scope:New "TextLabel" {
								Size = UDim2.new(1, 0, 0, 22),
								Position = UDim2.fromOffset(0, 10),

								BackgroundTransparency = 1,

								Font = Enum.Font.BuilderSansBold,
								TextSize = 22,
								TextColor3 = Color3.new(1, 1, 1),
								TextXAlignment = Enum.TextXAlignment.Left,
								Text = scope:Computed(function(use)
									return getDisplayName(use(player))
								end),
							},
							Username = scope:New "TextLabel" {
								Size = UDim2.new(1, 0, 0, 22),
								Position = UDim2.fromOffset(0, 32),

								BackgroundTransparency = 1,

								Font = Enum.Font.BuilderSansMedium,
								TextSize = 15,
								TextColor3 = Color3.fromRGB(187, 190, 199),
								TextXAlignment = Enum.TextXAlignment.Left,
								Text = scope:Computed(function(use)
									return `@{use(player).Name}`
								end),
							},
						},
					},
				},
			},
		},
	}
end

return Menu
