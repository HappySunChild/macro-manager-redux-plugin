assert(plugin, "Must be ran in a PluginScript!")

local RunService = game:GetService "RunService"

if RunService:IsClient() and RunService:IsRunning() then
	return
end

local pluginStartup = require "@self/startup"
pluginStartup(plugin)
