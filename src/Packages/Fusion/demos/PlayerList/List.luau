local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local Children, Out = Fusion.Children, Fusion.Out
local peek = Fusion.peek
local Menu = require(script.Parent.Menu)
local Player = require(script.Parent.Player)
local Team = require(script.Parent.Team)

local LIST_BASE_WIDTH = 240
local LIST_TWEENINFO = TweenInfo.new(0.3, Enum.EasingStyle.Exponential)

local function List(
	scope: Fusion.Scope,
	props: {
		Players: Fusion.UsedAs<{ Player }>,
		Teams: Fusion.UsedAs<{ Team }>,
		IsVisible: Fusion.UsedAs<boolean>,
	}
)
	local innerScope = scope:innerScope { Player = Player, Team = Team, Menu = Menu }

	local menuPlayer = scope:Value(Players.LocalPlayer)
	local menuOpen = scope:Value(false)
	local menuPosition = scope:Value(UDim2.fromOffset(-4, 0))

	local offset = innerScope:Computed(function(use)
		if use(props.IsVisible) then
			return UDim2.fromScale(1, 0)
		end

		return UDim2.new(1, LIST_BASE_WIDTH, 0, 0)
	end)

	local playerLabels = innerScope:ForPairs(
		props.Players,
		function(_, scope: typeof(innerScope), index: number, player: Player)
			local newLabel = scope:Player {
				Player = player,
				Teams = props.Teams,

				ClickedCallback = function(frame: Frame)
					if peek(menuPlayer) == player and peek(menuOpen) then
						menuOpen:set(false)
					else
						menuOpen:set(true)
					end

					menuPosition:set(UDim2.fromOffset(-4, frame.AbsolutePosition.Y))
					menuPlayer:set(player)
				end,
			}

			return index, newLabel
		end
	)

	local teamLabels = innerScope:Computed(function(use, scope: typeof(innerScope))
		local labels = {}

		for index, team in use(props.Teams) do
			local name = scope:Value(team.Name)
			local color = scope:Value(team.TeamColor)

			name:bindToInstanceProperty(team, "Name")
			color:bindToInstanceProperty(team, "TeamColor")

			table.insert(
				labels,
				scope:Team {
					Name = name,
					Color = scope:Computed(function(use)
						return use(color).Color
					end),
					Order = index - 1,
				}
			)
		end

		if #labels > 0 then
			table.insert(
				labels,
				scope:Team {
					Name = "Neutral",
					Color = Color3.new(0.5, 0.5, 0.5),
					Order = #labels,
				}
			)
		end

		return labels
	end)

	local contentSize = innerScope:Value(Vector2.zero)
	local height = innerScope:Computed(function(use)
		return use(contentSize).Y
	end)

	return innerScope:New "Frame" {
		AnchorPoint = Vector2.new(1, 0),
		Position = innerScope:Tween(offset, LIST_TWEENINFO),
		Size = innerScope:Computed(function(use)
			return UDim2.fromOffset(LIST_BASE_WIDTH, math.min(use(height), 300) + 4)
		end),

		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,

		[Children] = {
			Menu = innerScope:Menu {
				Visible = innerScope:Computed(function(use)
					return use(props.IsVisible) and use(menuOpen)
				end),
				Player = menuPlayer,
				Position = menuPosition,
			},
			List = innerScope:New "ScrollingFrame" {
				Size = UDim2.fromScale(1, 1),
				CanvasSize = innerScope:Computed(function(use)
					return UDim2.fromOffset(0, use(height) + 4)
				end),
				BackgroundTransparency = 1,

				ScrollBarThickness = 0,

				[Children] = {
					innerScope:New "UIPadding" {
						PaddingTop = UDim.new(0, 2),
						PaddingBottom = UDim.new(0, 2),
					},

					innerScope:New "UICorner" {
						CornerRadius = UDim.new(0, 4),
					},

					innerScope:New "UIListLayout" {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,

						Padding = UDim.new(0, 0),

						[Out "AbsoluteContentSize"] = contentSize,
					},

					teamLabels,
					playerLabels,
				},
			},
		},
	}
end

return List
