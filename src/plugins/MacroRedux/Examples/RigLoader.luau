local Players = game:GetService('Players')

local usernameBox = {
	Type = 'String',
	Value = '',
	Name = 'Username'
}

local generate = {
	Type = 'ButtonGroup',
	Buttons = {'Spawn R6', 'Spawn R15'}
}

local rigMacro = {}
rigMacro.Icon = 'rbxassetid://130821347287694'
rigMacro.CurrentId = nil

function rigMacro:Init()
	local camera = workspace.CurrentCamera
	
	function usernameBox:Changed(username: string)
		local success, userId = pcall(Players.GetUserIdFromNameAsync, Players, username)
		
		if not success then
			warn(`User '{username}' does not exist.`)
			
			return
		end
		
		rigMacro.CurrentId = userId
	end
	
	function generate:Activated(index: number)
		local rigType = index == 1 and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
		
		local description = Players:GetHumanoidDescriptionFromUserId(rigMacro.CurrentId)
		local rig = Players:CreateHumanoidModelFromDescription(description, rigType)
		rig.PrimaryPart = rig.HumanoidRootPart
		
		local location = CFrame.new(camera.CFrame.Position + camera.CFrame.LookVector * 15)
		
		rig.Name = Players:GetNameFromUserIdAsync(rigMacro.CurrentId)
		rig:PivotTo(location)
		
		rig.Parent = workspace
	end
	
	usernameBox:SetValue('Roblox')
end

rigMacro.Items = {usernameBox, generate}

return rigMacro