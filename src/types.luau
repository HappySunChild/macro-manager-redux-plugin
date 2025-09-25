export type MacroReference = {
	Module: ModuleScript,
	Document: LuaSourceContainer?,
}

export type Macro = {
	Name: string,
	Order: number?,
	Icon: string?,
	Items: { MacroItem }?,

	Setup: (Macro, Plugin) -> (),
	Init: (Macro, Plugin) -> (),
	Cleanup: (Macro, Plugin) -> (),

	SetVisible: (Macro, visible: boolean) -> (),
	SetMinimized: (Macro, minimized: boolean) -> (),
}

export type MacroItem = {
	Order: number?,
	Type: string,
	Text: string?,

	SetVisible: (MacroItem, visible: boolean) -> (),
}

export type ValueMacroItem<V> = MacroItem & {
	Value: V?,

	SetValue: (ValueMacroItem<V>, new: V) -> (),
	Changed: (ValueMacroItem<V>, new: V, old: V) -> (),
}

return nil
