--!nocheck
-- O Nation, You Bleed From Glorious Bootstrapping, 2025

local ServerStorage = game:GetService "ServerStorage"

local pluginContainer = ServerStorage.Plugins.MacroRedux

local ALIASES = {
	plugin = pluginContainer,
	components = pluginContainer.Components,
	packages = pluginContainer.Packages,
	utility = pluginContainer.Utility,
}

local ignore = { pluginContainer.Packages.Fusion }

type GenericScript = Script | LocalScript | ModuleScript

local function getPluginScripts(): { GenericScript }
	local list = {}

	local function collect(target: Instance)
		if table.find(ignore, target) then
			return
		end

		for _, child in target:GetChildren() do
			collect(child)

			if child:IsA "LuaSourceContainer" then
				table.insert(list, child)
			end
		end
	end

	collect(pluginContainer)

	return list
end

local function getPluginPath(inst: Instance)
	local parts = { inst.Name }
	local current = inst

	while current ~= pluginContainer do
		current = current.Parent

		table.insert(parts, 1, current.Name)
	end

	return table.concat(parts, "/")
end

local function getRelativePath(fromPath: string, toPath: string)
	local fromParts = string.split(fromPath, "/")
	local toParts = string.split(toPath, "/")

	local common = 0
	for i = 1, math.min(#fromParts, #toParts) do
		if fromParts[i] ~= toParts[i] then
			break
		end

		common = i
	end

	local relativeParts = {}
	for _ = common + 1, #fromParts - 1 do
		table.insert(relativeParts, "..")
	end

	for i = common + 1, #toParts do
		table.insert(relativeParts, toParts[i])
	end

	if #relativeParts <= 1 and relativeParts[1] ~= ".." then -- must be a sibling
		table.insert(relativeParts, 1, ".")
	end

	return table.concat(relativeParts, "/")
end

local function aliasToRelative(alias: string, reference: Instance): string
	local aliasObj = ALIASES[alias] :: Instance?

	if not aliasObj then
		return "@" .. alias
	end

	local targetPath = getPluginPath(aliasObj)
	local referencePath = getPluginPath(reference)

	return getRelativePath(referencePath, targetPath)
end

local function convertAliases(document: GenericScript)
	local source = document.Source
	local formatted = string.gsub(source, "@(%w+)", function(alias)
		local path = aliasToRelative(alias, document)

		return path
	end)

	if formatted ~= source then
		document.Source = formatted

		return true
	end

	return false
end

local replaceButton = {
	Type = "Button",
	Text = "Replace Aliases",
}

function replaceButton:Activated()
	local scripts = getPluginScripts()
	local affected = {}

	for _, pluginScript in scripts do
		if convertAliases(pluginScript) then
			table.insert(affected, pluginScript)
		end
	end

	if #affected == 0 then
		warn "No documents were affected"

		return
	end

	warn "Affected documents:"

	for _, document in affected do
		print(document)
	end
end

return {
	Order = -10,
	Icon = "rbxassetid://100940149280313",
	Items = { replaceButton },
}
