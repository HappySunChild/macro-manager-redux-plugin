local Types = require "@plugin/Types"

local ContainerManager = require "./ContainerManager"
local Logging = require "./Logging"

local PluginShared = require "@plugin/Shared"

local t = require "@packages/t"

local loadedMacros = {}
local customItemClasses = {}

local function loadMacro(macroModule: ModuleScript, reference: Instance?)
	local macroReference: Types.MacroReference =
		{ Module = macroModule, Document = reference }

	table.insert(loadedMacros, macroReference)
end

local function loadCurrentContainer()
	local tempContainer = ContainerManager.createTemporaryContainer()

	-- load custom classes
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

		customItemClasses[index] = constructor
	end

	-- load macros
	local container = ContainerManager.getCurrentContainer()
	local macrosFolder = tempContainer:FindFirstChild "Macros"

	for _, macroModule in macrosFolder:GetChildren() do
		if not macroModule:IsA "ModuleScript" then
			continue
		end

		loadMacro(
			macroModule,
			container.Macros:FindFirstChild(macroModule.Name)
		)
	end

	tempContainer.Parent = nil
end

local _activeMacros = PluginShared.Scope:Value(loadedMacros)

local function _updateMacros()
	_activeMacros:set(loadedMacros)
end

local function _refreshMacros()
	table.clear(loadedMacros)

	loadCurrentContainer()
	_updateMacros()
end

return table.freeze {
	CustomItemClasses = customItemClasses,
	ActiveMacros = _activeMacros,

	loadMacro = loadMacro,
	loadCurrentContainer = loadCurrentContainer,

	refreshMacros = _refreshMacros,
	updateMacros = _updateMacros,
}
