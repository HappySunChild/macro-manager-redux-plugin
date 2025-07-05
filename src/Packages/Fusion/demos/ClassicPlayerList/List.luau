local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local Children, Out = Fusion.Children, Fusion.Out
local map = Fusion.map

-- Components
local Player = require(script.Parent.Player)
local Team = require(script.Parent.Team)

local function List(
	scope: Fusion.Scope,
	props: {
		Visible: Fusion.UsedAs<boolean>,
		Players: { Fusion.UsedAs<{ Player }> },
		Teams: { Fusion.UsedAs<{ Team }> },
	}
)
	local inner = scope:innerScope {
		Player = Player,
		Team = Team,
	}

	local players = props.Players
	local teams = props.Teams

	local playerLabels = inner:ForValues(
		players,
		function(_, scope: typeof(inner), player)
			return scope:Player { Player = player, Teams = teams }
		end
	)

	local teamLabels = inner:Computed(function(use, scope: typeof(inner))
		local labels = {}

		for index, team: Team in use(props.Teams) do
			local name = scope:Value(team.Name)
			local color = scope:Value(team.TeamColor)

			name:bindToInstanceProperty(team, "Name")
			color:bindToInstanceProperty(team, "TeamColor")

			table.insert(
				labels,
				scope:Team {
					Order = index,
					Name = name,
					Color = scope:Computed(function(use)
						return use(color).Color
					end),
				}
			)
		end

		if #labels > 0 then
			table.insert(
				labels,
				scope:Team {
					Name = "Neutral",
					Color = Color3.new(0.5, 0.5, 0.5),
					Order = #labels + 1,
				}
			)
		end

		return labels
	end)

	local contentSize = inner:Value(Vector2.zero)

	return inner:New "ScrollingFrame" {
		Visible = props.Visible,

		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 170, 0.5, 0),
		CanvasSize = map(contentSize, function(v: Vector2)
			return UDim2.new(0, 0, 0, v.Y)
		end),

		BackgroundTransparency = 1,
		ScrollBarThickness = 0,

		[Children] = {
			inner:New "UIListLayout" {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2),

				[Out "AbsoluteContentSize"] = contentSize,
			},

			playerLabels,
			teamLabels,
		},
	}
end

return List
