local ChangeHistoryService = game:GetService('ChangeHistoryService')
local ScriptEditorService = game:GetService('ScriptEditorService')
local Selection = game:GetService('Selection')
local ServerStorage = game:GetService('ServerStorage')

local pluginFolder = script.Parent.Parent

local Libraries = pluginFolder.Libraries
local Classes = pluginFolder.Classes

local PluginShared = require(Libraries.Shared)

local function absoluteCopy(instance: Instance)
	local original = {}
	local copy = nil
	
	for _, descendant in instance:GetDescendants() do
		original[descendant] = descendant.Archivable
		
		descendant.Archivable = true
	end
	
	original[instance] = instance.Archivable
	instance.Archivable = true
	
	copy = instance:Clone()
	
	for child, archivable in original do
		child.Archivable = archivable
	end
	
	return copy
end

local function generateDebugSource()
	local classList = {}
	
	for _, module in Classes:GetChildren() do
		table.insert(classList, module.Name)
	end
	
	table.sort(classList, function(a: string, b: string)
		return a:lower() < b:lower()
	end)
	
	local itemDefinitions = {}
	local macroItems = {}
	local remappings = {}
	
	for _, className in classList do
		local variableName = className .. 'Item'
		table.insert(macroItems, variableName)
		
		local definition = string.format('local %-16s = {Type = "%s"}', variableName, className)
		table.insert(itemDefinitions, definition)
	end
	
	for new, original in PluginShared.ITEM_REMAP do
		table.insert(remappings, string.format('-- %-10s => %s', new, original))
	end
	
	table.sort(remappings, function(a: string, b: string) -- sort based off of what it maps to
		return a:match('=> (.+)'):lower() < b:match('=> (.+)'):lower()
	end)
	
	local itemsList = string.format('return {Items = {%s}}', table.concat(macroItems, ', '))
	local source = `-- Automatically generated debug macro to test every item class type.\n-- Contains {#macroItems} macro items.\n\n-- There are {#remappings} remappings.\n{table.concat(remappings, '\n')}\n\n{table.concat(itemDefinitions, '\n')}\n\n{itemsList}`
	
	return source
end

local defaultMacroSource = [[local MACRO = {}
MACRO.Items = {}

function MACRO:Init(plugin, macroSettings)
	print("MACRO initiated")
end

return MACRO]]

local upgradeNames = {
	'MacroStorage'
}

local macroManager = {}
macroManager.FolderName = 'MACRO_STORAGE'
macroManager.SearchFolder = nil
macroManager.Macros = {}

function macroManager:UpdateMacros()
	PluginShared:Publish('UpdateMacroApp', self.Macros)
end


function macroManager:UpgradeOldFolders()
	-- Defaultio's plugin folder upgrading
	local defaultioFolder = ServerStorage:FindFirstChild('MACRO_PLUGIN')
	
	if defaultioFolder then
		local macros = defaultioFolder:FindFirstChild('Macros')
		local util = defaultioFolder:FindFirstChild('Util')
		
		if macros then
			local newFolder = macros:Clone()
			newFolder.Name = self.FolderName
			newFolder.Parent = ServerStorage
			
			local targets = {newFolder}
			
			if util then
				local cloneUtil = util:Clone()
				local existingUtil = ServerStorage:FindFirstChild('Util')
				
				if existingUtil then -- add children
					for _, child in cloneUtil:GetChildren() do
						if existingUtil:FindFirstChild(child.Name) then
							continue
						end
						
						child.Parent = existingUtil
					end
				else
					-- really want to put this inside newFolder but currently with how it is set up
					-- they have to be one parent above to be compatible with old macros made with Defaultio's version.
					-- of course the user could always move this into the folder and modify the old macros to use the new path if they so wish.
					cloneUtil.Parent = ServerStorage
					
					table.insert(targets, cloneUtil)
				end
			end
			
			Selection:Set(targets)
			
			-- im not sure about this, seems a little too destructive.
			-- it will remain there and it will be up to the user to remove.
			-- defaultioFolder:Destroy()
			
			print('Macros from Defaultio\'s version have been migrated.')
			
			return newFolder
		end
	end
	
	
	for _, name in upgradeNames do
		local folder = ServerStorage:FindFirstChild(name)
		
		if not folder then
			continue
		end
		
		folder.Name = self.FolderName
		
		return folder
	end
end

function macroManager:SetupMacroFolder()
	local folder = ServerStorage:FindFirstChild(self.FolderName) or self:UpgradeOldFolders()
	
	-- folder creation
	if not folder then
		folder = Instance.new('Folder')
		folder.Name = self.FolderName
		folder.Parent = ServerStorage
		
		Selection:Set({folder})
	end
	
	folder.AncestryChanged:Connect(function(_, parent)
		if parent ~= ServerStorage then
			if parent ~= nil then
				folder:Destroy()
			end
			
			self:SetupMacroFolder()
		end
	end)
	
	self.SearchFolder = folder
end


function macroManager:ClearMacros()
	self.Macros = {}
	
	self:UpdateMacros()
	--App:updateMacros(self.Macros)
end

function macroManager:AddMacro(module: ModuleScript, reference: ModuleScript?)
	if not module or not module:IsA('ModuleScript') then
		return
	end
	
	table.insert(self.Macros, {
		Module = module,
		Reference = reference
	})
	
	self:UpdateMacros()
	--App:updateMacros(self.Macros)
end

function macroManager:AddMacros(originalFolder: Folder)
	if not originalFolder then
		warn('Search folder is undefined!')
		
		return
	end
	
	local copyFolder = absoluteCopy(originalFolder)
	
	-- i've settled on this, it still allows for 'script' to be used in macro modulescripts
	-- and rojo integration, as it isn't deleting the original folder.
	-- it still seems a *little* bit messy but it works perfectly fine
	copyFolder.Archivable = false
	copyFolder.Name = originalFolder.Name .. '.tmp'
	copyFolder.Parent = originalFolder.Parent
	
	for _, child in copyFolder:GetChildren() do
		if not child:IsA('ModuleScript') then
			continue
		end
		
		self:AddMacro(child, originalFolder:FindFirstChild(child.Name))
	end
	
	-- set back to nil
	task.defer(function()
		copyFolder.Parent = nil
	end)
end

function macroManager:CreateMacro(rawName: string, customSource: string?)
	if not self.SearchFolder then
		return
	end
	
	local formattedName = rawName:gsub('%s+(.?)', function(l)
		return string.upper(l)
	end)
	
	if self.SearchFolder:FindFirstChild(formattedName) then
		warn(`Macro with name '{formattedName}' already exists!`)
		
		return
	end
	
	local scriptSafeName = formattedName:gsub('%p', '')
	
	if rawName == 'Debug' then
		customSource = generateDebugSource()
	end
	
	local recordingId = ChangeHistoryService:TryBeginRecording('Create Macro', `Create Macro ({formattedName})`)
	
	if not recordingId then
		return
	end
	
	local source = customSource or defaultMacroSource:gsub('MACRO', scriptSafeName)
	source = '--!nocheck\n' .. source
	
	local newModule = Instance.new('ModuleScript')
	newModule.Name = formattedName
	newModule.Source = source
	newModule.Parent = self.SearchFolder
	
	ChangeHistoryService:FinishRecording(recordingId, Enum.FinishRecordingOperation.Commit)
	
	self:RefereshMacros()
	
	ScriptEditorService:OpenScriptDocumentAsync(newModule)
	Selection:Set({newModule})
end


function macroManager:RefereshMacros()
	self:ClearMacros()
	self:AddMacros(self.SearchFolder)
end

return macroManager