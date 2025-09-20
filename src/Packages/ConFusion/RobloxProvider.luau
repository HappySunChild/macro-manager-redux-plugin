local HttpService = game:GetService "HttpService"
local RunService = game:GetService "RunService"

local External = require "./External"

local function performUpdateStep()
	External.performUpdateStep()
end

local schedulerDisconnect

local RobloxProvider: External.ExternalProvider = table.freeze {
	doTaskImmediate = function<A...>(resume: (A...) -> () | thread, ...: A...)
		return task.spawn(resume, ...)
	end,
	doTaskDeferred = function<A...>(resume: (A...) -> () | thread, ...: A...)
		return task.defer(resume, ...)
	end,
	doTaskDelayed = function<A...>(sec: number, resume: (A...) -> () | thread, ...: A...)
		return task.delay(sec, resume)
	end,
	cancelTask = function(thread: thread)
		local success = pcall(task.cancel, thread)

		return success
	end,

	startScheduler = function()
		if RunService:IsClient() then
			local id = "FusionUpdateStep_" .. HttpService:GenerateGUID(false)

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
	end,
	stopScheduler = function()
		if schedulerDisconnect ~= nil then
			schedulerDisconnect()
			schedulerDisconnect = nil
		end
	end,

	logErrorNonFatal = function(message: string)
		task.spawn(error, message, 0)
	end,
	logWarn = warn,
}

return RobloxProvider
