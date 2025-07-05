local ContextActionService = game:GetService "ContextActionService"
local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"
local StarterGui = game:GetService "StarterGui"
local Teams = game:GetService "Teams"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local Children = Fusion.Children
local peek = Fusion.peek

-- Components
local List = require(script.Parent.List)

local scope = Fusion:scoped { List = List }
local playerList = scope:Value(Players:GetPlayers())
local teamsList = scope:Value(Teams:GetChildren())
local visible = scope:Value(true)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

ContextActionService:BindAction("TogglePlayerList", function(_, state)
	if state == Enum.UserInputState.Begin then
		visible:set(not (peek(visible) :: boolean))
	end
end, false, Enum.KeyCode.Tab)

scope:New "ScreenGui" {
	Name = "ClassicPlayerList",
	Parent = Players.LocalPlayer.PlayerGui,

	[Children] = {
		scope:List { Players = playerList, Teams = teamsList, Visible = visible },
	},
}

local function updateTeams()
	teamsList:set(Teams:GetChildren())
end

local function updatePlayers()
	playerList:set(Players:GetChildren())
end

Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)

Teams.ChildAdded:Connect(updateTeams)
Teams.ChildRemoved:Connect(updateTeams)
