export type CleanupTask = Instance | RBXScriptConnection | () -> () | { CleanupTask }
export type Scope<T = any> = { CleanupTask } & T
export type ScopedObject = {
	scope: Scope<unknown>?,
}

return nil
