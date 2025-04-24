local package = script.Parent.Parent

local Types = require(package.Types)

local messages = require(package.Logging.messages)

local function formatError(
	messageId: string,
	errorOrTrace: Types.Error | string | nil,
	...: unknown
)
	local err = if typeof(errorOrTrace) == "table" then errorOrTrace else nil
	local trace = if typeof(errorOrTrace) == "table"
		then errorOrTrace.trace
		else errorOrTrace

	local message: string = messages[messageId] or messageId
	message = message:format(...)

	if err ~= nil then
		message = message:gsub("ERROR_MESSAGE", err.message)
	else
		message = message:gsub("ERROR_MESSAGE", messageId)
	end

	local errorText = `[Fusion] {message}\nId: {messageId}`

	if trace ~= nil then
		errorText ..= `\n---- Stack trace ----\n{trace}`
	end

	return errorText:gsub("\n", "\n\t")
end

return formatError
