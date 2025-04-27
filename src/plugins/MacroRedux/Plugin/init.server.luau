assert(plugin, "Must be ran in a PluginScript!")

local RunService = game:GetService "RunService"

if RunService:IsServer() then
	local Manager = require(script.Manager)
	Manager:Initialize(plugin)
end
