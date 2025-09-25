local types = require "@plugin/types"

local ConFusion = require "@packages/ConFusion"

local MacroManager = require "@utility/MacroManager"

local LOADED_BUILTIN_CLASSES = {}

local did_load = false

local function load()
	if did_load then
		return
	end

	did_load = true

	for _, module in script:GetChildren() do
		LOADED_BUILTIN_CLASSES[module.Name] = require(module)
	end
end

return table.freeze {
	getClass = function(
		name: string
	): ((ConFusion.Scope, types.MacroItem) -> GuiBase2d)?
		load()

		return MacroManager.LoadedCustomClasses[name]
			or LOADED_BUILTIN_CLASSES[name]
	end,
}
