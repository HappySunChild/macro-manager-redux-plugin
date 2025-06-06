local formatError = require "@self/formatError"
local parseError = require "@self/parseError"

local Logging = {
	format = formatError,
	parse = parseError,

	warn = function(
		messageId: formatError.MessageId,
		errorOrTrace: (formatError.Error | string)?,
		...: string?
	)
		local message = formatError(messageId, errorOrTrace, ...)

		warn(message)
	end,

	error = function(
		messageId: formatError.MessageId,
		errorOrTrace: (formatError.Error | string)?,
		...: string?
	)
		local message = formatError(messageId, errorOrTrace, ...)

		error(message)
	end,
	errorNonFatal = function(
		messageId: formatError.MessageId,
		errorOrTrace: (formatError.Error | string)?,
		...: string?
	)
		local message = formatError(messageId, errorOrTrace, ...)

		task.spawn(error, message, 0)
	end,
}

return Logging
