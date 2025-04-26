local Selection = game:GetService "Selection"
local ServerStorage = game:GetService "ServerStorage"

local MacroManager = {}
MacroManager.ContainerName = "MACRO_PLUGIN" -- decided to go with Defaultio's original layout this time
MacroManager.CurrentContainer = nil :: Instance?

MacroManager.LoadedMacros = {}

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
end

function MacroManager:LoadMacro(macroModule: ModuleScript, reference: Instance?)
	table.insert(
		MacroManager.LoadedMacros,
		{ Module = macroModule, Reference = reference }
	)

	MacroManager:UpdateMacros()
end

function MacroManager:LoadMacrosFromContainer()
	if not MacroManager.CurrentContainer then
		return
	end
end

function MacroManager:RefreshMacros()
	print "refresh"

	table.clear(MacroManager.LoadedMacros)

	MacroManager:LoadMacrosFromContainer()
end

function MacroManager:UpdateMacros()
	print "update macros"
	
	-- TODO: make this update some shared Fusion Value to MacroManager.LoadedMacros
end

return MacroManager
