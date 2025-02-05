-- Made by HappySunChild
-- https://create.roblox.com/store/asset/17234439838/Macro-Manager-Redux

assert(plugin, 'Must be ran in a PluginScript!')

local RunService = game:GetService('RunService')

-- don't initialize when play testing on client
-- testing on the server is fine, since it can access ServerScriptService
if not (RunService:IsRunning() and RunService:IsClient()) then
	local pluginMain = require(script.Plugin)
	
	pluginMain:Init(plugin)
end