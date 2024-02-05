export type State = {
	key: string,

	onEntry: (() -> ())?,
	onLeave: (() -> ())?,
	-- TODO: figure out if onStep value type can be inferred
	onStep: ((value: unknown) -> unknown)?,

	-- TODO: figure out if value generic type can be inferred
	value: Value<unknown>?,

	transitions: { [number | string]: Transition },

	[string]: nil,
}

export type Transition = {
	key: string,

	-- TODO: figure out if guard value type can be inferred
	guard: ((value: unknown) -> boolean)?,
	onTransition: (() -> ())?,

	[string]: nil,
}

export type Value<T> = {
	initialValue: T,

	serialize: (value: T) -> string,
	deserialize: (serializedValue: string) -> T,

	[string]: nil,
}

return nil
