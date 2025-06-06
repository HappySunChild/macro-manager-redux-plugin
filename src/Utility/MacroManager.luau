local ContainerManager = require "./ContainerManager"
local Logging = require "./Logging"

local PluginShared = require "@plugin/Shared"

local t = require "@packages/t"

local MacroManager = {}
MacroManager.CustomItemClasses = {}

local loadedMacros = {}
MacroManager.ActiveMacros = PluginShared.Scope:Value(loadedMacros)

function MacroManager:LoadMacro(macroModule: ModuleScript, reference: Instance?)
	table.insert(loadedMacros, { Module = macroModule, Reference = reference })
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
			Logging.warn("classRequireError", err, index)

			continue
		end

		local typeOk = t.callback(constructor)

		if not typeOk then
			Logging.warn("classInvalidType", nil, index, type(constructor))

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
	MacroManager:UpdateMacros()
end

function MacroManager:UpdateMacros()
	MacroManager.ActiveMacros:set(loadedMacros)
end

return MacroManager
