export type Contextual<T> = {
	now: (Contextual<T>) -> T,
	executeWith: <T, R, A...>(Contextual<T>, (A...) -> R, A...) -> R,
}
export type ContextConstructor = <T>(default: T) -> Contextual<T>

return nil
