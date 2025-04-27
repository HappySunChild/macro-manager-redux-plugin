local Selection = game:GetService "Selection"
local ServerStorage = game:GetService "ServerStorage"

local PluginContainer = script.Parent.Parent
local PluginScope = require(PluginContainer.Plugin.Scope)

local MacroManager = {}
MacroManager.ContainerName = "MACRO_PLUGIN" -- decided to go with Defaultio's original layout this time
MacroManager.CurrentContainer = nil :: Instance?
MacroManager.ActiveTempContainer = nil :: Instance?

local loadedMacros = {}
MacroManager.ActiveMacros = PluginScope:Value(loadedMacros)

function MacroManager:SetupContainer()
	local container = ServerStorage:FindFirstChild(MacroManager.ContainerName)

	if not container then
		container = Instance.new "Folder"
		container.Name = MacroManager.ContainerName
		container.Parent = ServerStorage

		Selection:Set { container }
	end

	if not container:FindFirstChild "Macros" then
		local macrosFolder = Instance.new "Folder"
		macrosFolder.Name = "Macros"
		macrosFolder.Parent = container
	end

	MacroManager.CurrentContainer = container

	return container
end

function MacroManager:LoadMacro(macroModule: ModuleScript, reference: Instance?)
	table.insert(loadedMacros, { Module = macroModule, Reference = reference })

	MacroManager:UpdateMacros()
end

function MacroManager:LoadMacrosFromContainer()
	local container = MacroManager.CurrentContainer
		or MacroManager:SetupContainer()

	if not container then
		return
	end

	local tempContainer = container:Clone()
	tempContainer.Archivable = false
	tempContainer.Name ..= ".tmp"
	tempContainer.Parent = container.Parent

	local macrosFolder = tempContainer:FindFirstChild "Macros"

	if not macrosFolder then
		warn(
			`Can't load macros; No 'Macros' folder in '{container:GetFullName()}'`
		)

		tempContainer:Destroy()

		return
	end

	for _, macro in macrosFolder:GetChildren() do
		if not macro:IsA "ModuleScript" then
			continue
		end

		MacroManager:LoadMacro(
			macro,
			container.Macros:FindFirstChild(macro.Name)
		)
	end

	task.defer(function()
		tempContainer.Parent = nil
	end)
end

function MacroManager:RefreshMacros()
	table.clear(loadedMacros)

	MacroManager:LoadMacrosFromContainer()
end

function MacroManager:UpdateMacros()
	MacroManager.ActiveMacros:set(loadedMacros)
end

return MacroManager
