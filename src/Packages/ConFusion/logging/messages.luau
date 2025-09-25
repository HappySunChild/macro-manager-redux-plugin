return {
	infiniteLoop = "Detected an infinite loop. Consider adding an explicit breakpoint to your code to prevent a cyclic dependency.",

	callbackError = "Error in callback:\nERROR_MESSAGE",

	destroyedTwice = "`doCleanup()` was given something that it is already cleaning up. Unclear how to proceed.",

	animatedInvalidGoal = "An Animated was given a NaN goal. Ensure NaN isn't being passed anywhere!\nGoal: '%*'",
	animatedInvalidMotion = "An Animated encountered NaN during motion. Ensure NaN/inf isn't being passed anywhere!\nCurrent: '%*'\nGoal: '%*'",

	awaitNonGraph = "Can't await non-graph values.",

	missingChild = "Could not find child '%s' in '%s'.",
	missingChildClass = "Could not find child of class '%s' in '%s'.",
	missingDescendant = "Could not find descendant '%s' in '%s'.",
	missingDescendantClass = "Could not find descendant of class '%s' in '%s'.",

	invalidChildType = "Invalid child type '%s'.",
	invalidObserveType = "Can't observe non-state value, got '%s'.",
	invalidChangeType = "Can't change non-state value, got '%s'.",
	invalidEvaluateType = "Invalid evaluate argument, got '%s'.",

	propertyInvalidType = "'%s.%s' expected a '%s' type, but got a '%s' type.",
	propertyCannotAssign = "The %s class has no assignable property '%s'.",
	propertyAssignError = "Error while setting property:\nERROR_MESSAGE",

	cannotDepend = "%s (%s) cannot depend on %s (%s).",
	cannotCreateClass = "Unable to create instance of type '%s'.",
	cannotCreateTemplate = "Unable to create template of instance '%s'.",
	cannotConnectChange = "The %s class doesn't have a property called '%s'.",
	cannotConnectEvent = "The %s class doesn't have a event called '%s'.",

	forKeyCollision = "The key '%s' was returned multiple times simultaneously, which is not allowed in `For` objects.",

	missingSpecialKeyStage = "The SpecialKey '%s' is missing a stage property.",
	invalidSpecialKeyStage = "The SpecialKey '%s' has an invalid stage '%s'.",

	expectedType = "Expected a %s, got %s.",
}
