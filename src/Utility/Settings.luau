local PluginShared = require "@plugin/Shared"
local types = require "@plugin/types"

local SETTINGS_KEY = "HappySunChild_MacroManager"
local DEFAULT_SETTINGS_OBJECT: types.PluginSettingsObject = {
	macro_settings = {},
}

return table.freeze {
	load = function()
		local plugin = assert(PluginShared.plugin, "Missing plugin")

		PluginShared.settings = plugin:GetSetting(SETTINGS_KEY)
			or DEFAULT_SETTINGS_OBJECT
	end,
	save = function()
		local plugin = assert(PluginShared.plugin, "Missing plugin")

		plugin:SetSetting(SETTINGS_KEY, PluginShared.settings)
	end,
}
