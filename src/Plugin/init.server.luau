assert(plugin, "Must be ran in a PluginScript!")

local RunService = game:GetService "RunService"

if not (RunService:IsClient() and RunService:IsRunning()) then
	local Manager = require "@self/PluginManager"
	Manager:Initialize(plugin)
end
