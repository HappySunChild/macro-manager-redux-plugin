local ContextActionService = game:GetService "ContextActionService"
local Players = game:GetService "Players"
local ReplicatedStorage = game:GetService "ReplicatedStorage"
local StarterGui = game:GetService "StarterGui"
local Teams = game:GetService "Teams"

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local peek = Fusion.peek
local PlayerList = require(script.Parent.List)

local scoped = Fusion:scoped { PlayerList = PlayerList }

local isVisible = scoped:Value(true)
local playerList = scoped:Value(Players:GetPlayers())
local teamList = scoped:Value(Teams:GetChildren())

local function updateTeams()
	teamList:set(Teams:GetChildren())
end

local function updatePlayers()
	playerList:set(Players:GetPlayers())
end

Teams.ChildAdded:Connect(updateTeams)
Teams.ChildRemoved:Connect(updateTeams)

Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

ContextActionService:BindAction("TogglePlayerList", function(_, state)
	if state == Enum.UserInputState.Begin then
		isVisible:set(not peek(isVisible) :: boolean)
	end
end, false, Enum.KeyCode.Tab)

scoped:New "ScreenGui" {
	Name = "PlayerList",
	Parent = Players.LocalPlayer.PlayerGui,

	[Fusion.Children] = {
		scoped:PlayerList {
			IsVisible = isVisible,
			Players = playerList,
			Teams = teamList,
		},
	},
}
