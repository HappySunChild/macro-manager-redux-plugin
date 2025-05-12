local messages = {
	macroRequireError = "An error occured while requiring Macro '%s'",
	macroMethodError = "An error occured while running :%s for Macro '%s'",
	macroInvalidType = "Expected Macro '%s' to return value of type table, got %s.",

	itemConstructorError = "An error occured while adding MacroItem '%s'",
	itemAlreadyRendered = "MacroItem '%s' has already been rendered.",
	itemInvalidContainer = "Invalid return value for MacroItem class '%s';\n%s",

	classRequireError = "An error occured while loading MacroItem class '%s'",
	classInvalidType = "Expected MacroItem class '%s' to return value of type function, got %s.\nYou may have to remove/modify existing classes!",
	classCannotFind = "Unable to find MacroItem class '%s'.",
}

return messages
