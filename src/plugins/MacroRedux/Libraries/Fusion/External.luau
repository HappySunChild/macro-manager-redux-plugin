--!strict

local package = script.Parent

local Types = require(package.Types)

local formatError = require(package.Logging.formatError)

local External = {}

local boundCallbacks = {}
local activeProvider: Types.ExternalProvider? = nil

function External.setProvider(newProvider: Types.ExternalProvider?)
	local oldProvider = activeProvider

	if oldProvider ~= nil then
		oldProvider.stopScheduler()
	end

	activeProvider = newProvider

	if newProvider then
		newProvider.startScheduler()
	end

	return oldProvider
end

function External.unbindAll()
	table.clear(boundCallbacks)
end

function External.bindToUpdate(callback: (now: number) -> ())
	local uniqueIdentifier = {}
	boundCallbacks[uniqueIdentifier] = callback

	return function()
		boundCallbacks[uniqueIdentifier] = nil
	end
end

local lastUpdateStep = os.clock()
local deltaTime = 0

function External.performUpdate()
	local now = os.clock()

	deltaTime = now - lastUpdateStep
	lastUpdateStep = now

	for _, callback in boundCallbacks do
		callback(now)
	end
end

function External.deltaTime(): number
	return deltaTime
end

function External.lastUpdateStep(): number
	return lastUpdateStep
end

function External.doTaskImmediate(resume: (...unknown) -> (), ...: unknown)
	if activeProvider then
		activeProvider.doTaskImmediate(resume, ...)
	end
end

function External.doTaskDeffered(resume: (...unknown) -> (), ...: unknown)
	if activeProvider then
		activeProvider.doTaskDeferred(resume, ...)
	end
end

function External.logError(messageId: string, err: Types.Error?, ...: unknown): never
	error(formatError(messageId, err, ...), 0)
end

function External.logErrorNonFatal(messageId: string, err: Types.Error?, ...: unknown)
	local message = formatError(messageId, err, ...)

	if activeProvider then
		activeProvider.logErrorNonFatal(message)
	else
		print(message)
	end
end

function External.logWarn(messageId: string, ...: unknown)
	local message = formatError(messageId, debug.traceback(nil, 2), ...)

	if activeProvider then
		activeProvider.logWarn(message)
	else
		print(message)
	end
end

return External
