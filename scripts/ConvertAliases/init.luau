--!nocheck
-- O Nation, You Bleed From Glorious Bootstrapping, 2025

local ServerStorage = game:GetService "ServerStorage"

local AliasConverter = require "@self/AliasConverter"

local pluginFolder = ServerStorage.Plugins.MacroRedux

local packageAliasConverter = AliasConverter(ServerStorage)
packageAliasConverter:bulkRegisterAliases {
	plugin = pluginFolder,
	components = pluginFolder.Components,
	packages = pluginFolder.Packages,
	utility = pluginFolder.Utility,
}

local IGNORE = { pluginFolder.Packages.Fusion }

local function getPackageScripts(): { LuaSourceContainer }
	local sourceContainers = {}

	local function collect(instance: Instance)
		if table.find(IGNORE, instance) then
			return
		end

		for _, child in instance:GetChildren() do
			collect(child)

			if child:IsA "LuaSourceContainer" then
				table.insert(sourceContainers, child)
			end
		end
	end

	collect(pluginFolder)

	return sourceContainers
end

local Button = {
	Type = "Button",
	Text = "Convert Aliases",
	Activated = function()
		local sourceContainers = getPackageScripts()

		for _, container in sourceContainers do
			local oldSource = container.Source
			local newSource =
				packageAliasConverter:convertAliases(oldSource, container)

			if newSource ~= oldSource then
				print("Modified:", container)
			end

			container.Source = newSource
		end
	end,
}

return {
	Order = -20,
	Icon = "rbxassetid://100940149280313",
	Items = { Button },
}
