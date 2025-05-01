local pluginContainer = script.Parent.Parent

local Fusion = require(pluginContainer.Packages.Fusion)

local PluginShared = {}
PluginShared.Scope = Fusion:scoped()
PluginShared.Plugin = nil :: Plugin?

return PluginShared
