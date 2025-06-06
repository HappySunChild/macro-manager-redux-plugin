local Fusion = require "@packages/Fusion"

local PluginShared = {}
PluginShared.Scope = Fusion:scoped()
PluginShared.Plugin = nil :: Plugin?

return PluginShared
