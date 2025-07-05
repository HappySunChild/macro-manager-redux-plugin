local ContextActionService = game:GetService 'ContextActionService'
local Players = game:GetService 'Players'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local StarterGui = game:GetService 'StarterGui'

local player = Players.LocalPlayer

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local Hotbar = require(script.Parent.Hotbar)

local Fusion = require(ReplicatedStorage.Libraries.ConFusion)
local peek, Children = Fusion.peek, Fusion.Children

local keys = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Zero,
}

local scope = Fusion:scoped {
	Hotbar = Hotbar,
}

local items = scope:Table {}
local currentTool = nil

-- utility functions

local function find(tab, value)
	for k, v in tab do
		if v == value then
			return k
		end
	end

	return
end

local function getLowestAvailableIndex(tab)
	local index = 1

	while tab[index] do
		index += 1
	end

	return index
end

-- backpack functions

local function equipTool(index: number)
	local selectedTool = items:getKey(index)

	if not selectedTool then
		return
	end

	if currentTool and currentTool:IsDescendantOf(workspace) then
		local curTool = currentTool -- this is gross but it works

		currentTool.Parent = player.Backpack

		if selectedTool == curTool then
			return
		end
	end

	selectedTool.Parent = player.Character
end

local function removeTool(tool: Tool)
	local index = find(peek(items), tool)

	if index then
		items:setKey(index, nil)
	end
end

local function addTool(tool: Instance)
	if not tool:IsA 'Tool' then
		return
	end

	if find(peek(items), tool) then
		return
	end

	local connection
	connection = tool.AncestryChanged:Connect(function(_, parent)
		if parent == nil or parent ~= player.Backpack and parent ~= player.Character then
			connection:Disconnect()

			removeTool(tool)
		end
	end)

	items:setKey(getLowestAvailableIndex(peek(items)), tool)
end

-- event functions

local function characterAdded(character: Model)
	local backpack = player:WaitForChild 'Backpack'

	backpack.ChildAdded:Connect(addTool)

	for _, child in backpack:GetChildren() do
		addTool(child)
	end

	character.ChildAdded:Connect(function(child)
		addTool(child)

		if child:IsA 'Tool' then
			currentTool = child
		end
	end)
	character.ChildRemoved:Connect(function(child)
		if child == currentTool then
			currentTool = nil
		end
	end)
end

scope:New 'ScreenGui' {
	Name = 'InventoryHotbar',
	Parent = player.PlayerGui,

	[Children] = {
		Hotbar = scope:Hotbar {
			Height = 50,
			Padding = 5,

			Items = items,
			EquipCallback = equipTool,
		},
	},
}

ContextActionService:BindAction(
	'Equip',
	function(_, state: Enum.UserInputState, input: InputObject)
		if state ~= Enum.UserInputState.Begin then
			return
		end

		local index = table.find(keys, input.KeyCode)

		equipTool(index)
	end,
	false,
	unpack(keys)
)

characterAdded(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(characterAdded)
