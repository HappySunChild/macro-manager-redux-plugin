local function parseError(message: string)
	return {
		type = "Error",
		raw = message,
		message = message:gsub("^.+:%d+:%s*", ""),
		trace = debug.traceback(nil, 4),
	}
end

return parseError
