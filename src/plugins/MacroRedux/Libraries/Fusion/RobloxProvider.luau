local HttpService = game:GetService 'HttpService'
local RunService = game:GetService 'RunService'

local package = script.Parent

local External = require(package.External)
local Types = require(package.Types)

local function performUpdateStep()
	External.performUpdate(os.clock())
end

local RobloxProvider: Types.ExternalProvider = {}

function RobloxProvider.doTaskImmediate(resume: (...any) -> (), ...)
	task.spawn(resume, ...)
end

function RobloxProvider.doTaskDeferred(resume: (...any) -> (), ...)
	task.defer(resume, ...)
end

local schedulerDisconnect

function RobloxProvider.startScheduler()
	if RunService:IsClient() then
		local id = 'FusionUpdateStep_' .. HttpService:GenerateGUID(false)

		RunService:BindToRenderStep(
			id,
			Enum.RenderPriority.First.Value,
			performUpdateStep
		)

		schedulerDisconnect = function()
			RunService:UnbindFromRenderStep(id)
		end
	else
		local connection = RunService.Heartbeat:Connect(performUpdateStep)

		schedulerDisconnect = function()
			connection:Disconnect()
		end
	end
end

function RobloxProvider.stopScheduler()
	if schedulerDisconnect ~= nil then
		schedulerDisconnect()
		schedulerDisconnect = nil
	end
end

function RobloxProvider.logErrorNonFatal(message: string)
	task.spawn(error, message, 0)
end

RobloxProvider.logWarn = warn

return RobloxProvider
