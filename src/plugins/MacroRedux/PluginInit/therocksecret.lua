-- the rock with pancakes

-- silly and subtle reference to Defaultio's life changing plugin
-- https://create.roblox.com/store/asset/2463990477/The-Rock-With-Pancakes

local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local MacroManager = require(Libraries.MacroManager)
local PluginSettings = require(Libraries.Settings)

local therock = {}
therock.Ran = false

local source = [[
local TheRockPortrait = {
	Type = "Container",
	Name = "The Rock With Pancakes"
}

local TheRock = {}
TheRock.Items = {TheRockPortrait}
TheRock.Icon = "rbxassetid://465579702"

function TheRock:Init()
	print("The rock with pancakes")

	local image = Instance.new("ImageLabel")
	image.Size = UDim2.fromScale(1, 1)
	image.SizeConstraint = Enum.SizeConstraint.RelativeXX
	image.Image = "rbxassetid://465579702"
	
	TheRockPortrait:Insert(image)
end

return TheRock
]]

source = string.rep('-- THE ROCK WITH PANCAKES\n', 69) .. source

function therock:Run(plugin: Plugin, widget)
	if therock.Ran then
		return
	end
	
	therock.Ran = true
	
	local rockToolbar = plugin:CreateToolbar('The Rock')
	local button = rockToolbar:CreateButton('TheRock', 'with pancakes', 'rbxassetid://465579702', 'The Rock')
	
	local sound = Instance.new('Sound')
	sound.Name = 'rock'
	sound.Archivable = false
	sound.SoundId = 'rbxassetid://7188420724'
	sound.Volume = 0.1
	sound.Parent = widget
	
	button.Click:Connect(function()
		PluginSettings:Set('HasSeenRock', true)
		
		button:SetActive(true)
		button:SetActive(false)
		
		button.Enabled = false
		
		MacroManager:CreateMacro('TheRockWithPancakes', source)
		
		sound:Play()
	end)
end

return therock