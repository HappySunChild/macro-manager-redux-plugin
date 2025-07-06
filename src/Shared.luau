local ConFusion = require "@packages/ConFusion"

local PluginShared = {}
PluginShared.Scope = ConFusion:scoped()
PluginShared.Plugin = nil :: Plugin?

return PluginShared
