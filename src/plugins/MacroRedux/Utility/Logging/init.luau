local formatError = require(script.formatError)

local Logging = {
	warn = function(
		messageId: formatError.MessageId,
		errorOrTrace: string?,
		...: string?
	)
		local message = formatError(messageId, errorOrTrace, ...)

		warn(message)
	end,

	error = function(
		messageId: formatError.MessageId,
		errorOrTrace: string?,
		...: string?
	)
		local message = formatError(messageId, errorOrTrace, ...)

		error(message)
	end,
	errorNonFatal = function(
		messageId: formatError.MessageId,
		errorOrTrace: string?,
		...: string?
	)
		local message = formatError(messageId, errorOrTrace, ...)

		task.spawn(error, message, 0)
	end,
}

return Logging
