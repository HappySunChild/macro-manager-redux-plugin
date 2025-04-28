local pluginContainer = script.Parent.Parent

local ContainerManager = require(pluginContainer.Utility.ContainerManager)
local PluginScope = require(pluginContainer.Plugin.Scope)

local MacroManager = {}
MacroManager.CustomItemClasses = {}

local loadedMacros = {}
MacroManager.ActiveMacros = PluginScope:Value(loadedMacros)

function MacroManager:LoadMacro(macroModule: ModuleScript, reference: Instance?)
	table.insert(loadedMacros, { Module = macroModule, Reference = reference })

	MacroManager:UpdateMacros()
end

function MacroManager:LoadCurrentContainer()
	local tempContainer = ContainerManager:CreateTemporaryContainer()

	if not tempContainer then
		return
	end

	local classesFolder = tempContainer:FindFirstChild "MacroItemClasses"

	for _, classModule in classesFolder:GetChildren() do
		if not classModule:IsA "ModuleScript" then
			continue
		end

		local index = classModule.Name

		local constructor
		local success, err = pcall(function()
			constructor = require(classModule) :: any
		end)

		if not success then
			warn(`Failed to load MacroItem class '{index}'; {err}`)

			continue
		end

		if type(constructor) ~= "function" then
			warn(
				`Failed to load MacroItem class '{index}'; Invalid return type: expected function, got {type(
					constructor
				)}.\n\tYou may have to remove or modify MacroItem classes from Defaultio's version!`
			)

			continue
		end

		MacroManager.CustomItemClasses[index] = constructor
	end

	local container = ContainerManager.CurrentContainer
	local macrosFolder = tempContainer:FindFirstChild "Macros"

	for _, macroModule in macrosFolder:GetChildren() do
		if not macroModule:IsA "ModuleScript" then
			continue
		end

		MacroManager:LoadMacro(
			macroModule,
			container.Macros:FindFirstChild(macroModule.Name)
		)
	end

	tempContainer.Parent = nil
end

function MacroManager:RefreshMacros()
	table.clear(loadedMacros)

	MacroManager:LoadCurrentContainer()
end

function MacroManager:UpdateMacros()
	MacroManager.ActiveMacros:set(loadedMacros)
end

return MacroManager
