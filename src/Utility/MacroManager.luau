local PluginShared = require "@plugin/Shared"
local types = require "@plugin/types"

local t = require "@packages/t"

local ContainerManager = require "./ContainerManager"
local Logging = require "./Logging"

local LOADED_MACROS = {}
local LOADED_CUSTOM_CLASSES = {}

local _ACTIVE_MACROS = PluginShared.Scope:Value(LOADED_MACROS)

local function loadMacro(macroModule: ModuleScript, reference: Instance?)
	local macroReference: types.MacroReference =
		{ Module = macroModule, Document = reference }

	table.insert(LOADED_MACROS, macroReference)
end

local function loadCurrentContainer()
	local temp_container = ContainerManager.createTemporaryContainer()

	-- load classes
	local classes_folder = temp_container:FindFirstChild "MacroItemClasses"

	for _, class_module in classes_folder:GetChildren() do
		if not class_module:IsA "ModuleScript" then
			continue
		end

		local index = class_module.Name

		local constructor
		local ok, err = pcall(function()
			constructor = require(class_module) :: any
		end)
		if not ok then
			Logging.warn("classRequireError", err, index)

			continue
		end

		local ok = t.callback(constructor)
		if not ok then
			Logging.warn("classInvalidType", nil, index, type(constructor))

			continue
		end

		LOADED_CUSTOM_CLASSES[index] = constructor
	end

	-- load macros
	local container = ContainerManager.getCurrentContainer()
	local macros_folder = temp_container:FindFirstChild "Macros"

	for _, macro_module in macros_folder:GetChildren() do
		if not macro_module:IsA "ModuleScript" then
			continue
		end

		loadMacro(
			macro_module,
			container.Macros:FindFirstChild(macro_module.Name)
		)
	end

	temp_container.Parent = nil
end

local function _updateMacros()
	_ACTIVE_MACROS:set(LOADED_MACROS)
end

local function _refreshMacros()
	table.clear(LOADED_MACROS)

	loadCurrentContainer()
	_updateMacros()
end

return table.freeze {
	LoadedCustomClasses = LOADED_CUSTOM_CLASSES,
	LoadedMacros = _ACTIVE_MACROS,

	loadMacro = loadMacro,
	loadCurrentContainer = loadCurrentContainer,

	refreshMacros = _refreshMacros,
	updateMacros = _updateMacros,
}
