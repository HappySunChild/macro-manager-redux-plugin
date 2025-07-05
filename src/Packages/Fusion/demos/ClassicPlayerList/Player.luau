local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local Children = Fusion.Children
local map = Fusion.map

local ICONS = {
	Developer = "rbxasset://textures/ui/icon_placeowner.png",
	Friends = "rbxasset://textures/ui/icon_friends_16.png",
	Premium = "rbxasset://textures/ui/icon_premium-16.png",
	Verified = "rbxasset://textures/ui/icon_star-16.png",
	Admin = "rbxasset://textures/ui/icon_admin-16.png",
}

local function determineIcon(player: Player)
	if player.UserId == game.CreatorId then
		return ICONS.Developer
	elseif Players.LocalPlayer:IsFriendsWith(player.UserId) then
		return ICONS.Friends
	elseif player.UserId == 1 or player:IsInGroup(1200769) then
		return ICONS.Admin
	elseif player.HasVerifiedBadge then
		return ICONS.Verified
	elseif player.MembershipType ~= nil then
		return ICONS.Premium
	end

	return nil
end

local function getLayoutOrder(currentTeam: Team, teams: { Team })
	local index = table.find(teams, currentTeam) or (#teams + 1)

	return (index - 1) * 2 + 1
end

local function Player(
	scope: Fusion.Scope,
	props: { Player: Player, Teams: Fusion.UsedAs<{ Teams }> }
)
	local inner = scope:innerScope()
	local player = props.Player

	local icon = determineIcon(player)

	local currentTeam = inner:Value(player.Team)
	currentTeam:bindToInstanceProperty(player, "Team")

	return inner:New "TextButton" {
		Name = map(props.Player, function(v: Player)
			return `p_{v.UserId}`
		end),

		Size = UDim2.new(1, 0, 0, 24),
		LayoutOrder = inner:Computed(function(use)
			return getLayoutOrder(use(currentTeam), use(props.Teams))
		end),

		BackgroundTransparency = 0.75,
		BackgroundColor3 = Color3.new(0, 0, 0),

		Text = "",
		AutoButtonColor = true,

		[Children] = {
			Padding = inner:New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},

			Icon = if icon ~= nil
				then inner:New "ImageLabel" {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromOffset(16, 16),

					BackgroundTransparency = 1,

					Image = icon,
					ImageRectSize = Vector2.new(16, 16),
				}
				else nil,
			PlayerName = inner:New "TextLabel" {
				Position = UDim2.fromOffset(19, 0),
				Size = UDim2.new(1, -19, 1, 0),

				BackgroundTransparency = 1,

				Text = player.DisplayName,
				TextStrokeTransparency = 0.75,
				TextColor3 = Color3.new(1, 1, 1),
				TextXAlignment = Enum.TextXAlignment.Left,
			},
		},
	}
end

return Player
