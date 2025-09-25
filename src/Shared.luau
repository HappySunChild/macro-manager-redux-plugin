local types = require "@plugin/types"

local ConFusion = require "@packages/ConFusion"

return {
	settings = nil :: types.PluginSettingsObject?,
	scope = ConFusion:scoped(),
	plugin = nil :: Plugin?,
}
